## Why

ArgoCD applications are showing perpetual "OutOfSync" status due to controllers (Cilium Gateway, cert-manager, Longhorn, Prometheus) modifying resources after deployment. These controllers inject CA bundles, populate status fields, and normalize configurations, causing ArgoCD to constantly detect drift and attempt reconciliation. This creates noise, wastes resources, and makes it difficult to identify real configuration drift versus expected controller behavior.

## What Changes

- Add comprehensive `ignoreDifferences` configurations to all ArgoCD ApplicationSets:
  - `infrastructure-components-appset.yaml`: Webhook CA bundles, CRD fields, HTTPRoute status, StatefulSet volumeClaimTemplates
  - `monitoring-components-appset.yaml`: Prometheus CRD status fields, ServiceMonitor endpoints, Secret data
  - `myapplications-appset.yaml`: HTTPRoute status, Deployment resources, PVC/Service status
  - **NEW** `longhorn-components-appset.yaml`: Dedicated ApplicationSet for Longhorn with Longhorn-specific ignore rules
  
- Add `allowEmpty: false` to all ApplicationSet sync policies to prevent empty applications
- Add Application health check customization for proper sync wave ordering
- Add `info` sections to all ApplicationSets for better documentation in ArgoCD UI
- Simplify global ArgoCD ignoreDifferences (move to ApplicationSet level)

## Capabilities

### New Capabilities
- `argocd-ignoredifferences-infrastructure`: Ignore differences for infrastructure components including webhooks, CRDs, and HTTPRoutes
- `argocd-ignoredifferences-monitoring`: Ignore differences for monitoring stack including Prometheus CRDs and generated secrets
- `argocd-ignoredifferences-applications`: Ignore differences for user applications including HTTPRoutes and workload resources
- `argocd-ignoredifferences-longhorn`: Ignore differences for Longhorn storage including all Longhorn CRD status fields

### Modified Capabilities
<!-- No existing specs are being modified - this is purely configuration enhancement -->

## Impact

- **ArgoCD**: All ApplicationSets updated with ignoreDifferences configurations
- **Applications**: No functional changes - purely cosmetic sync status improvements
- **GitOps Workflow**: More reliable drift detection, reduced sync noise
- **Monitoring**: False-positive OutOfSync alerts eliminated
- **Dependencies**: Requires ArgoCD sync to pick up new Application configurations
