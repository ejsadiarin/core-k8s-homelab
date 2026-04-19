## Why

All public services on `*.ejsadiarin.com` were returning 403/Access Denied since 2026-02-17. Cloudflared was configured to connect to Cilium Gateway via HTTPS with a wildcard SNI (`*.ejsadiarin.com`), but Cilium Gateway's Envoy proxy uses SNI-based TLS routing and rejects the literal wildcard string — it expects concrete hostnames. Additionally, HTTPRoutes were bound exclusively to the `https` gateway listener via `sectionName`, leaving the HTTP listener with no routes, which meant even if cloudflared switched to HTTP it would get 404s. A secondary issue — a SealedSecret ownership conflict — kept ArgoCD reporting cloudflared as Degraded for 6 days.

## What Changes

- **Cloudflared config**: Switch service URLs from `https://<gateway>:443` to `http://<gateway>:80`, remove `noTLSVerify` and `originServerName` fields
- **CiliumNetworkPolicy**: Update cloudflared egress to gateway from port 443 to port 80
- **HTTPRoutes**: Remove `sectionName: https` from all HTTPRoutes (external and internal) so they bind to both HTTP and HTTPS gateway listeners
- **SealedSecret fix**: Delete unmanaged `tunnel-credentials` secret so the SealedSecret controller can recreate it with proper ownership (runtime fix, no git change needed)

## Capabilities

### New Capabilities

- `cloudflared-gateway-routing`: requirements for how cloudflared connects to the Cilium Gateway and how HTTPRoutes bind to gateway listeners

### Modified Capabilities

- `cloudflared-deployment`: cloudflared now connects to the gateway over HTTP instead of HTTPS, removing TLS-related origin configuration

## Impact

- **10 files changed** across `cluster/infrastructure/networking/cloudflared/`, `cluster/apps/`, and `cluster/monitoring/`
- All public services restored (cloudflared tunnel → HTTP:80 → gateway → backends)
- ArgoCD cloudflared application health transitioned from Degraded to Healthy
- No breaking changes — TLS termination still happens at Cloudflare edge; internal cluster traffic between cloudflared and gateway is now plaintext HTTP (acceptable since it's intra-cluster)
