## Why

ArgoCD shows several applications as "Degraded" or "OutOfSync" even though the underlying Kubernetes resources are healthy. This investigation aims to:

1. Document and track fixes for ArgoCD sync/health issues
2. Fix actual degraded resources (Grafana crash loop)
3. Optimize cloudflared from DaemonSet to Deployment (single tunnel instance is sufficient)
4. Maintain documentation of previously fixed issues for future reference

This is critical for maintaining reliable GitOps observability and preventing alert fatigue from false warnings.

## What Changes

### Previously Fixed (Completed 2026-02-17)

- ✅ **ArgoCD Controller Crash**: Fixed malformed `resource.customizations` in argocd-cm ConfigMap
  - Removed incompatible format that caused controller CrashLoopBackOff
  - Moved ignoreDifferences to ApplicationSet templates instead
- ✅ **HTTPRoute OutOfSync**: Added jqPathExpressions for Gateway API normalization
  - Gateway API controllers add default `group`/`kind` to parentRefs and backendRefs
  - Added to all ApplicationSet templates
- ✅ **Reloader Chart**: Fixed chart version from non-existent 1.0.0 to 2.2.8
- ✅ **Velero Config**: Removed deprecated `enableRestic` and `restic` keys
  - Velero chart 8.x uses `deployNodeAgent`/`nodeAgent` instead
- ✅ **Velero kubectl Image**: Fixed bitnami/kubectl:1.33 → 1.32 (1.33 doesn't exist)
- ✅ **Longhorn Application**: Removed orphaned application (excluded from AppSet but still existed)

### In Progress

- **cloudflared**: Convert from DaemonSet to Deployment with security hardening
  - Current: DaemonSet (runs on every node, overkill for single tunnel)
  - New: Deployment with 1 replica, proper security context, resource limits
- **kube-prometheus-stack**: Fix Grafana crash loop
  - Current: Grafana pods failing liveness/readiness probes (HTTP 503)
  - New: Investigate and fix the root cause
- **ArgoCD Health Assessment**: Document and potentially fix stale health status caching

## Capabilities

### New Capabilities

- `cloudflared-deployment`: Single-replica deployment pattern for cloudflared tunnel with security hardening
- `argocd-resource-customizations`: Proper ignoreDifferences configuration at ApplicationSet level with jqPathExpressions

### Modified Capabilities

- `kube-prometheus-stack`: Fix Grafana deployment configuration to resolve crash loop

## Impact

| Application | Current Status | Root Cause | Fix |
|-------------|---------------|------------|-----|
| cloudflared | Degraded (false positive) | Stale ArgoCD health cache + DaemonSet overkill | Convert to Deployment |
| kube-prometheus-stack | Degraded (real) | Grafana crash loop (probe failures) | Investigate config issue |
| nginx | Progressing (false positive) | Stale ArgoCD health cache | Fix cache issue |

**Affected systems:**
- `cluster/infrastructure/networking/cloudflared/` - Deployment restructuring
- `cluster/monitoring/kube-prometheus-stack/` - Grafana configuration
- ArgoCD health assessment behavior (potential ConfigMap changes)
