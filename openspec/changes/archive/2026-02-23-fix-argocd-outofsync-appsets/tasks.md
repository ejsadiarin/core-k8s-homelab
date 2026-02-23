## 1. Infrastructure ApplicationSet Updates

- [x] 1.1 Add `allowEmpty: false` to infrastructure-components-appset.yaml syncPolicy.automated
- [x] 1.2 Add ignoreDifferences block for webhook CA bundles (ValidatingWebhookConfiguration, MutatingWebhookConfiguration)
- [x] 1.3 Add ignoreDifferences for CRD preserveUnknownFields
- [x] 1.4 Add ignoreDifferences for HTTPRoute status and parentRefs (weight, kind, group)
- [x] 1.5 Add ignoreDifferences for StatefulSet volumeClaimTemplates (apiVersion, kind via jqPathExpressions)
- [x] 1.6 Add `info` section with Description field to template.spec
- [x] 1.7 Update syncOptions order (move ApplyOutOfSyncOnly before RespectIgnoreDifferences)

## 2. Monitoring ApplicationSet Updates

- [x] 2.1 Add `allowEmpty: false` to monitoring-components-appset.yaml syncPolicy.automated
- [x] 2.2 Add ignoreDifferences for Prometheus CRD status (Prometheus, Alertmanager, PrometheusRule)
- [x] 2.3 Add ignoreDifferences for ServiceMonitor spec.endpoints
- [x] 2.4 Add ignoreDifferences for Secret data fields
- [x] 2.5 Add ignoreDifferences for HTTPRoute status and parentRefs
- [x] 2.6 Add `info` section with Description field to template.spec
- [x] 2.7 Update syncOptions order (move ApplyOutOfSyncOnly before RespectIgnoreDifferences)

## 3. Applications ApplicationSet Updates

- [x] 3.1 Add `allowEmpty: false` to myapplications-appset.yaml syncPolicy.automated
- [x] 3.2 Add ignoreDifferences for HTTPRoute status and parentRefs (weight, kind, group)
- [x] 3.3 Add ignoreDifferences for Deployment container/initContainer resources
- [x] 3.4 Add ignoreDifferences for PersistentVolumeClaim status
- [x] 3.5 Add ignoreDifferences for Service status
- [x] 3.6 Add `info` section with Description field to template.spec
- [x] 3.7 Update syncOptions order (move ApplyOutOfSyncOnly before RespectIgnoreDifferences)

## 4. Longhorn ApplicationSet Creation

- [x] 4.1 Create new file infrastructure/longhorn-components-appset.yaml
- [x] 4.2 Add ApplicationSet metadata with sync-wave: "1" annotation
- [x] 4.3 Configure git generator for cluster/infrastructure/storage/longhorn path
- [x] 4.4 Add ignoreDifferences for webhook CA bundles
- [x] 4.5 Add ignoreDifferences for all Longhorn CRDs (Volume, Node, Setting, Engine, Replica)
- [x] 4.6 Add ignoreDifferences for HTTPRoute status
- [x] 4.7 Configure extended retry settings (limit: 10, maxDuration: 5m)
- [x] 4.8 Add `info` section with Description field

## 5. ArgoCD Configuration Updates

- [x] 5.1 Add Application health check Lua script for proper sync wave ordering
- [x] 5.2 Simplify global ignoreDifferences (remove duplicates now handled at ApplicationSet level)
- [x] 5.3 Keep minimal global fallbacks for HTTPRoute and ServiceMonitor
- [x] 5.4 Fix resource.customizations.health syntax (remove duplicate key)

## 6. Verification and Testing

- [x] 6.1 Apply ArgoCD config changes and sync ArgoCD app
- [x] 6.2 Apply new Longhorn ApplicationSet
- [x] 6.3 Verify infrastructure apps sync status (should show Synced)
- [x] 6.4 Verify monitoring apps sync status (should show Synced)
- [x] 6.5 Verify user apps sync status (nginx, glance, hello-world should show Synced)
- [x] 6.6 Verify Longhorn app sync status (should show Synced)
- [x] 6.7 Check cloudflared status (may still be Degraded - separate issue)
- [x] 6.8 Document any remaining OutOfSync issues

**Verification Results (2026-02-23):**

| Application | Status |
|-------------|--------|
| argocd | Synced/Healthy |
| cert-manager | Synced/Healthy |
| cilium | Synced/Healthy |
| gateway | Synced/Healthy |
| local-path-provisioner | Synced/Healthy |
| reloader | Synced/Healthy |
| sealed-secrets | Synced/Healthy |
| prometheus-adapter | Synced/Healthy |
| kube-prometheus-stack | Synced/Degraded (Grafana - separate issue) |
| cloudflared | Synced/Degraded (separate issue) |
| velero | OutOfSync (expected - missing B2 credentials) |

All other applications are Synced. The ignoreDifferences configurations have resolved the OutOfSync issues caused by controller modifications.
