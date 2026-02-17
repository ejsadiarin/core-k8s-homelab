## 1. Infrastructure ApplicationSet Updates

- [ ] 1.1 Add `allowEmpty: false` to infrastructure-components-appset.yaml syncPolicy.automated
- [ ] 1.2 Add ignoreDifferences block for webhook CA bundles (ValidatingWebhookConfiguration, MutatingWebhookConfiguration)
- [ ] 1.3 Add ignoreDifferences for CRD preserveUnknownFields
- [ ] 1.4 Add ignoreDifferences for HTTPRoute status and parentRefs (weight, kind, group)
- [ ] 1.5 Add ignoreDifferences for StatefulSet volumeClaimTemplates (apiVersion, kind via jqPathExpressions)
- [ ] 1.6 Add `info` section with Description field to template.spec
- [ ] 1.7 Update syncOptions order (move ApplyOutOfSyncOnly before RespectIgnoreDifferences)

## 2. Monitoring ApplicationSet Updates

- [ ] 2.1 Add `allowEmpty: false` to monitoring-components-appset.yaml syncPolicy.automated
- [ ] 2.2 Add ignoreDifferences for Prometheus CRD status (Prometheus, Alertmanager, PrometheusRule)
- [ ] 2.3 Add ignoreDifferences for ServiceMonitor spec.endpoints
- [ ] 2.4 Add ignoreDifferences for Secret data fields
- [ ] 2.5 Add ignoreDifferences for HTTPRoute status and parentRefs
- [ ] 2.6 Add `info` section with Description field to template.spec
- [ ] 2.7 Update syncOptions order (move ApplyOutOfSyncOnly before RespectIgnoreDifferences)

## 3. Applications ApplicationSet Updates

- [ ] 3.1 Add `allowEmpty: false` to myapplications-appset.yaml syncPolicy.automated
- [ ] 3.2 Add ignoreDifferences for HTTPRoute status and parentRefs (weight, kind, group)
- [ ] 3.3 Add ignoreDifferences for Deployment container/initContainer resources
- [ ] 3.4 Add ignoreDifferences for PersistentVolumeClaim status
- [ ] 3.5 Add ignoreDifferences for Service status
- [ ] 3.6 Add `info` section with Description field to template.spec
- [ ] 3.7 Update syncOptions order (move ApplyOutOfSyncOnly before RespectIgnoreDifferences)

## 4. Longhorn ApplicationSet Creation

- [ ] 4.1 Create new file infrastructure/longhorn-components-appset.yaml
- [ ] 4.2 Add ApplicationSet metadata with sync-wave: "1" annotation
- [ ] 4.3 Configure git generator for cluster/infrastructure/storage/longhorn path
- [ ] 4.4 Add ignoreDifferences for webhook CA bundles
- [ ] 4.5 Add ignoreDifferences for all Longhorn CRDs (Volume, Node, Setting, Engine, Replica)
- [ ] 4.6 Add ignoreDifferences for HTTPRoute status
- [ ] 4.7 Configure extended retry settings (limit: 10, maxDuration: 5m)
- [ ] 4.8 Add `info` section with Description field

## 5. ArgoCD Configuration Updates

- [ ] 5.1 Add Application health check Lua script for proper sync wave ordering
- [ ] 5.2 Simplify global ignoreDifferences (remove duplicates now handled at ApplicationSet level)
- [ ] 5.3 Keep minimal global fallbacks for HTTPRoute and ServiceMonitor
- [ ] 5.4 Fix resource.customizations.health syntax (remove duplicate key)

## 6. Verification and Testing

- [ ] 6.1 Apply ArgoCD config changes and sync ArgoCD app
- [ ] 6.2 Apply new Longhorn ApplicationSet
- [ ] 6.3 Verify infrastructure apps sync status (should show Synced)
- [ ] 6.4 Verify monitoring apps sync status (should show Synced)
- [ ] 6.5 Verify user apps sync status (nginx, glance, hello-world should show Synced)
- [ ] 6.6 Verify Longhorn app sync status (should show Synced)
- [ ] 6.7 Check cloudflared status (may still be Degraded - separate issue)
- [ ] 6.8 Document any remaining OutOfSync issues
