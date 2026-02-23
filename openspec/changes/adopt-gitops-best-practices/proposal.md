## Why

The current `cluster/` configuration has critical operational issues that impact reliability and security:
1. **OutOfSync drift**: Multiple ArgoCD applications are perpetually OutOfSync due to controller-modified fields (webhook CA bundles, HTTPRoute status, Longhorn status)
2. **Missing network security**: No Cilium Network Policies are configured, leaving all pods with unrestricted network access
3. **No backup strategy**: No backup solution for PVCs using local-path-provisioner storage class
4. **Limited observability**: Missing custom alerting rules and Grafana dashboards for critical infrastructure components
5. **Manual maintenance burden**: No automated dependency updates (Renovate) and no auto-reload on ConfigMap changes (Reloader)
6. **Unencrypted secrets in git**: Sensitive credentials (Cloudflare tokens, API keys) are not stored as SealedSecrets

The `k8s-gitops/` reference repository demonstrates production-ready patterns that solve these exact problems.

## What Changes

### Infrastructure Improvements
- **ArgoCD ignoreDifferences**: Add resource customizations to ignore controller-injected fields (webhook CA bundles, status fields, generated secrets)
- **Longhorn exclusion**: Exclude Longhorn from ArgoCD management while keeping configs for future use when resources permit
- **Cilium Network Policies**: Add 18 reusable network policies to `common/cilium-network-policies/` for egress/ingress control
- **Velero + Restic**: Add Velero with Restic for PVC backup/restore to Backblaze B2, supporting migration to Longhorn
- **Reloader**: Add Reloader controller for automatic workload reloads on ConfigMap/Secret changes

### Secrets Management
- **Sealed Secrets**: Convert existing secrets (Cloudflare tokens, API keys) to SealedSecrets for safe git storage
- **Key rotation script**: Add script for sealed secrets key rotation and resealing

### Monitoring Enhancements
- **Custom Alerting Rules**: Add PrometheusRules for Kubernetes, storage, and application alerts
- **Grafana Dashboards**: Add dashboards for ArgoCD, Longhorn, Cilium/Hubble

### Automation
- **Renovate Bot**: Add `.github/renovate.json` for automated dependency updates
- **Standardized Labels**: Add consistent Kubernetes labels to all application manifests

### Fixes for Existing Issues
- Remove blanket `sync-wave` annotation from cert-manager kustomization (let Helm chart handle ordering)
- Add `Delete=false` sync option to PVC resources for data protection

## Capabilities

### New Capabilities
- `network-policies`: Reusable Cilium Network Policies for ingress/egress traffic control with label-based opt-in
- `velero-backup`: Velero with Restic for PVC backup/restore with Backblaze B2 storage, supporting storage class migration
- `argocd-drift-prevention`: ArgoCD resource customizations to prevent OutOfSync drift from controller-modified fields
- `monitoring-alerts`: Custom Prometheus alerting rules for Kubernetes, storage, and application health
- `grafana-dashboards`: Custom Grafana dashboards for infrastructure observability
- `renovate-automation`: Automated dependency updates via Renovate bot
- `reloader`: Automatic workload reloads on ConfigMap/Secret changes
- `sealed-secrets`: GitOps-safe secret management using SealedSecrets with cluster-wide scope

### Modified Capabilities
- None (all changes are additive, no existing spec requirements are being modified)

## Impact

### Files Created
- `cluster/common/cilium-network-policies/` - 18 network policy files + kustomization
- `cluster/infrastructure/backup/velero/` - Velero deployment with Restic and B2 credentials
- `cluster/infrastructure/controllers/reloader/` - Reloader deployment
- `cluster/monitoring/kube-prometheus-stack/alerts/` - 3+ alert rule files
- `cluster/monitoring/kube-prometheus-stack/dashboards/` - 4+ dashboard ConfigMaps
- `cluster/scripts/rotate-seal-key.sh` - Sealed secrets key rotation script
- `.github/renovate.json` - Renovate configuration
- Various `*-sealed.yaml` files for existing secrets (cloudflared credentials, etc.)

### Files Modified
- `cluster/infrastructure/controllers/argocd/values.yaml` - Add ignoreDifferences configuration
- `cluster/infrastructure/infrastructure-components-appset.yaml` - Exclude Longhorn from management
- All app `kustomization.yaml` files - Add standardized labels and network policy references
- All `pvc.yaml` files - Add `Delete=false` sync option annotation

### Files Excluded from ArgoCD (but kept in repo)
- `cluster/infrastructure/storage/longhorn/` - Configs preserved for future use when node resources permit

### Dependencies
- Velero requires Backblaze B2 credentials (to be stored as SealedSecret)
- SealedSecrets controller already installed in cluster
- Network policies require Cilium CNI (already installed)

### Systems Affected
- ArgoCD sync behavior (will stop fighting controller modifications)
- All application pods (will gain network policy restrictions)
- All PVCs (will have Velero/Restic backups to B2)
- Prometheus (will have new alert rules)
- Grafana (will have new dashboards)
- All secrets (will be converted to SealedSecrets)
