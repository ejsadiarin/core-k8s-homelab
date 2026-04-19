## Context

The cloudflared deployment was recently migrated from DaemonSet to Deployment (2026-02-23). The current configuration has basic security hardening but lacks observability integration and has configuration hygiene issues.

Comparison with reference k8s-gitops implementation revealed:
- Missing metrics Service for Prometheus scraping
- No automatic restart on credential changes (Reloader annotation)
- Missing pod labels for common network policy patterns
- Duplicate headers in config.yaml
- Higher resource allocation than needed

Current resource usage shows cloudflared typically uses <50m CPU and ~100Mi memory, suggesting current limits are over-provisioned.

## Goals / Non-Goals

**Goals:**
- Add metrics Service for Prometheus observability
- Enable automatic pod restart on credential secret changes
- Add pod labels for network policy integration
- Add explicit CiliumNetworkPolicy for egress control
- Fix duplicate headers in config.yaml
- Optimize resource allocation to match actual usage
- Add sysctl for ICMP proxy support

**Non-Goals:**
- Changes to the tunnel configuration or ingress rules
- Changes to other networking components (Gateway, HTTPRoutes)
- High-availability configuration (multiple replicas)

## Decisions

### 1. Metrics Service on Port 2000

**Decision:** Create a Service exposing port 2000 targeting the cloudflared metrics endpoint.

**Rationale:** Cloudflared exposes metrics at `0.0.0.0:2000/metrics` by default. A Service enables Prometheus to discover and scrape these metrics.

**Alternative considered:** None - standard pattern for metrics exposure.

### 2. Reloader Annotation

**Decision:** Add `reloader.stakater.com/auto: "true"` annotation to the Deployment.

**Rationale:** When tunnel credentials are rotated, the pod automatically restarts to pick up the new secret. This is critical for tunnel availability.

**Alternative considered:** Manual pod restart — rejected due to operational burden and potential downtime.

### 3. CiliumNetworkPolicy for Explicit Egress

**Decision:** Create CiliumNetworkPolicy allowing egress to:
- Gateway service (cilium-gateway-gateway-external.gateway.svc.cluster.local:443)
- Cloudflare edge IPs (via DNS resolution to *.cloudflare.com)
- kube-dns for DNS resolution

**Rationale:** Default namespace policies may not cover cloudflared's specific needs. Explicit policy provides defense in depth.

**Alternative considered:** Rely on namespace-level policies only — rejected for explicit security posture.

### 4. Resource Optimization

**Decision:** Reduce CPU requests to 50m and limits to 200m.

**Rationale:** Monitoring shows actual usage is well below current allocation (100m/500m). Reference implementation uses 50m/200m which has proven stable.

**Trade-off:** Less headroom for traffic spikes. Mitigation: HPA could be added if needed, but single tunnel typically doesn't need it.

### 5. Sysctl for ICMP Proxy

**Decision:** Add `net.ipv4.ping_group_range: "65532 65532"` sysctl.

**Rationale:** Enables cloudflared's ICMP proxy feature for better health checking through the tunnel. The sysctl allows the unprivileged user (65532) to send ICMP packets.

**Alternative considered:** Skip ICMP proxy — rejected as this is a useful feature for tunnel health visibility.

## Risks / Trade-offs

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Lower CPU limits cause throttling under load | Low | Medium | Monitor metrics; increase if needed |
| Network policy blocks required traffic | Low | High | Policy allows all necessary egress; test after deploy |
| Config changes break tunnel connectivity | Low | High | Changes are additive; rollback via git revert |

## Migration Plan

### Phase 1: Additive Changes (Low Risk)

1. Add metrics Service
2. Add Reloader annotation
3. Add pod labels
4. Add sysctl
5. Add readOnly to config volumeMount
6. Fix duplicate headers in config.yaml

These changes are additive and won't disrupt the running tunnel.

### Phase 2: Resource Changes (Requires Pod Restart)

1. Update resource requests/limits
2. Add CiliumNetworkPolicy

Pod will be recreated by ArgoCD sync. Brief tunnel disconnection expected (< 30 seconds).

### Rollback

All changes are in git. Rollback via:
```bash
git revert <commit>
git push origin cluster
```

ArgoCD will sync to previous state within 3 minutes.

## Open Questions

None — all decisions are resolved based on reference implementation analysis.
