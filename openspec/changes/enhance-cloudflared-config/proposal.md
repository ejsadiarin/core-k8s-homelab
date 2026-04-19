## Why

The cloudflared deployment configuration was recently migrated from DaemonSet to Deployment with basic security hardening. Comparison with the reference k8s-gitops implementation reveals several gaps in observability, network policy integration, and configuration hygiene that should be addressed for production readiness.

Key gaps:
- No metrics Service for Prometheus scraping
- No Reloader annotation for automatic pod restart on secret changes
- Missing pod labels for common network policy patterns
- Duplicate headers in config.yaml (CF-IPCountry, CF-Ray appear twice)
- Missing CiliumNetworkPolicy for explicit egress control
- Missing standard Kubernetes labels in kustomization

## What Changes

### Deployment Enhancements
- Add `reloader.stakater.com/auto: "true"` annotation for automatic restart on credential changes
- Add pod labels: `netpol.cilium.io/egress-to-cloudflare: "true"`, `netpol.cilium.io/egress-to-kube-dns: "true"`
- Add `readOnly: true` to config volumeMount
- Add sysctl `net.ipv4.ping_group_range: "65532 65532"` for ICMP proxy support
- Optimize CPU resources: requests 50m (was 100m), limits 200m (was 500m)

### New Resources
- Add `cloudflared-metrics` Service on port 2000 for metrics scraping
- Add `CiliumNetworkPolicy` for explicit egress allowlist to gateway services

### Config Fixes
- Remove duplicate headers (CF-IPCountry, CF-Ray)
- Clean up header list for consistency

### Kustomization
- Add standard `app.kubernetes.io/*` labels
- Include common Cilium network policies reference

## Capabilities

### New Capabilities

- `cloudflared-observability`: Metrics service for Prometheus scraping and network policy integration for explicit traffic control

### Modified Capabilities

- `cloudflared-deployment`: Add Reloader annotation, pod labels for netpol integration, sysctl for ICMP, readOnly config volume, optimized resources, and configuration fixes

## Impact

| File | Change |
|------|--------|
| `cluster/infrastructure/networking/cloudflared/deployment.yaml` | Add annotations, labels, sysctl, readOnly, resource adjustments |
| `cluster/infrastructure/networking/cloudflared/service.yaml` | New file - metrics service |
| `cluster/infrastructure/networking/cloudflared/cilium-netpol.yaml` | New file - explicit egress policy |
| `cluster/infrastructure/networking/cloudflared/config.yaml` | Remove duplicate headers |
| `cluster/infrastructure/networking/cloudflared/kustomization.yaml` | Add labels, include new resources |
