## Context

Cloudflared connects to Cloudflare's edge network and proxies incoming requests to backend services inside the Kubernetes cluster. The traffic path is:

```
Internet → Cloudflare Edge (TLS termination) → Cloudflare Tunnel → cloudflared pod
  → Cilium Gateway (Envoy) → Backend Service
```

Cilium Gateway API implements TLS via SNI-based routing. The gateway's Envoy proxy has a `filterChainMatch` with `serverNames: ['*.ejsadiarin.com']` for HTTPS traffic. When cloudflared connected via HTTPS, it sent the literal string `*.ejsadiarin.com` as the TLS SNI value (configured via `originServerName`). Envoy requires concrete hostnames for SNI matching and rejected the wildcard, causing TCP connection resets.

Cloudflared does not support dynamic per-request SNI — `originServerName` is a static value per ingress rule. This makes HTTPS with SNI-based gateways fundamentally incompatible unless each hostname gets its own ingress rule with a matching `originServerName`.

Additionally, all HTTPRoutes had `sectionName: https` in their `parentRefs`, binding them exclusively to the HTTPS gateway listener. The HTTP listener (`listener-insecure` on port 80) had zero virtual hosts configured, so any HTTP request returned 404.

A secondary issue: the `tunnel-credentials` Kubernetes Secret was created before the SealedSecret resource, so the sealed-secrets controller couldn't take ownership, leaving ArgoCD's health assessment stuck at "Degraded" since 2026-02-17.

## Goals / Non-Goals

**Goals:**
- Restore public access to all `*.ejsadiarin.com` services via Cloudflare Tunnel
- Fix cloudflared ArgoCD application health from Degraded to Healthy
- Ensure HTTPRoutes are accessible on both HTTP and HTTPS gateway listeners

**Non-Goals:**
- End-to-end TLS between cloudflared and gateway (TLS is terminated at Cloudflare edge; intra-cluster HTTP is acceptable)
- Changing Cloudflare Access/WAF policies (403s from Cloudflare Access are expected for protected services)
- Modifying the Cilium Gateway or its TLS certificate configuration

## Decisions

### 1. Switch cloudflared → gateway from HTTPS to HTTP

**Decision:** Change cloudflared's service URL from `https://<gateway>:443` to `http://<gateway>:80`.

**Rationale:** Cloudflared's `originServerName` is static per ingress rule and cannot send per-request SNI matching the actual hostname. Cilium Gateway's Envoy requires concrete SNI for TLS routing. HTTP bypasses SNI entirely.

**Alternatives considered:**
- *Per-hostname ingress rules with matching originServerName*: Would work but requires N ingress rules for N hostnames, creating maintenance burden and config duplication.
- *Disable SNI verification on gateway*: Not possible with Cilium Gateway API — SNI matching is how TLS listeners route traffic.
- *Use a single concrete hostname as originServerName*: Would only work for one service, breaking all others.

**Trade-off:** Traffic between cloudflared and gateway is now plaintext HTTP within the cluster. This is acceptable because TLS is terminated at Cloudflare's edge, and the cluster network is trusted (Cilium CNI with network policies).

### 2. Remove sectionName from all HTTPRoutes

**Decision:** Remove `sectionName: https` from all HTTPRoutes so they bind to both the `http` and `https` gateway listeners.

**Rationale:** With cloudflared now connecting via HTTP, the HTTP listener needs routes configured. Removing `sectionName` binds to all listeners, which is the pattern already used by ArgoCD and Longhorn HTTPRoutes.

**Alternatives considered:**
- *Only remove sectionName from external routes*: Would fix the immediate issue, but internal routes would still be HTTPS-only, creating inconsistency.
- *Add duplicate HTTPRoutes for HTTP listener*: Unnecessary complexity — a single route without sectionName binds to both.

### 3. Fix SealedSecret ownership via secret deletion

**Decision:** Delete the unmanaged `tunnel-credentials` secret and let the SealedSecret controller recreate it with proper ownership.

**Rationale:** The sealed-secrets controller checks for `sealedsecrets.bitnami.com/managed` annotation and ownerReferences. Adding the annotation alone wasn't sufficient — the controller only evaluates ownership during secret creation, not on annotation changes.

## Risks / Trade-offs

| Risk | Impact | Mitigation |
|------|--------|------------|
| Intra-cluster HTTP is plaintext | Low — cluster network is trusted, CiliumNetworkPolicies restrict traffic | Acceptable for homelab; production would use mTLS via service mesh |
| Deleting tunnel-credentials causes brief tunnel disconnect | Low — secret is cached in pod's mounted volume | Pod continues running; SealedSecret recreates secret within seconds |
| HTTPRoutes on HTTP listener accept unencrypted external traffic | None — external traffic goes through Cloudflare which always uses HTTPS; direct HTTP access requires cluster network access | Gateway only exposed via Cloudflare Tunnel, not NodePort/LoadBalancer |
