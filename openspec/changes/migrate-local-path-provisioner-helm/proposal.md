## Why

The current local-path-provisioner deployment uses 163 lines of manual YAML defining RBAC, Deployment, ConfigMap, and StorageClass resources. Maintaining this manually is error-prone and makes updates difficult. The official Rancher Helm chart provides the same functionality with proper versioning, easier configuration, and automatic RBAC management.

Migrating to the Helm chart simplifies maintenance and ensures we can easily track and update the provisioner version.

## What Changes

- Replace manual YAML manifests with official `rancher/local-path-provisioner` Helm chart
- Configure `reclaimPolicy: Retain` via Helm values (matching current behavior)
- Reduce code from ~163 lines to ~35 lines of configuration
- Add security context hardening (runAsNonRoot, readOnlyRootFilesystem)
- Add explicit resource limits for the provisioner pod

## Capabilities

### New Capabilities

- `local-path-storage`: Dynamic local storage provisioning using Helm-managed local-path-provisioner with Retain reclaim policy

### Modified Capabilities

None - this is a migration to Helm with no spec-level behavior changes.

## Impact

| Area | Impact |
|------|--------|
| Files | `cluster/infrastructure/storage/local-path-provisioner/` refactored |
| Resources | No PVC/PV changes - existing volumes unaffected |
| Downtime | Brief during Deployment recreation (new pod starts before old terminates) |
| Dependencies | No new dependencies; Helm chart from Rancher repo |

**Affected files:**
- `cluster/infrastructure/storage/local-path-provisioner/kustomization.yaml` - add Helm chart
- `cluster/infrastructure/storage/local-path-provisioner/local-path-storage.yaml` - DELETE (replaced by Helm)
- `cluster/infrastructure/storage/local-path-provisioner/values.yaml` - NEW (Helm values)
- `cluster/infrastructure/storage/local-path-provisioner/namespace.yaml` - NEW (explicit namespace)