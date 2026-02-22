## 1. Create New Files

- [x] 1.1 Create `cluster/infrastructure/storage/local-path-provisioner/namespace.yaml` with explicit namespace definition
- [x] 1.2 Create `cluster/infrastructure/storage/local-path-provisioner/values.yaml` with Helm chart configuration:
  - Image tag v0.0.34
  - StorageClass name: local-path
  - reclaimPolicy: Retain
  - volumeBindingMode: WaitForFirstConsumer
  - securityContext (runAsNonRoot, runAsUser: 65534, readOnlyRootFilesystem)
  - Note: resources removed per chart recommendation (lightweight provisioner)

## 2. Update Kustomization

- [x] 2.1 Update `cluster/infrastructure/storage/local-path-provisioner/kustomization.yaml` to use Helm chart:
  - Added helmCharts section with containeroo/local-path-provisioner
  - Referenced values.yaml
  - Set namespace

## 3. Remove Manual Manifests

- [x] 3.1 Delete `cluster/infrastructure/storage/local-path-provisioner/local-path-storage.yaml`

## 4. Verify Deployment

- [ ] 4.1 Verify ArgoCD syncs the new Helm chart successfully
- [ ] 4.2 Verify StorageClass `local-path` exists with `reclaimPolicy: Retain`
- [ ] 4.3 Verify provisioner pod is running with security context
- [ ] 4.4 Verify existing PVCs remain bound

## 5. Cleanup

- [ ] 5.1 Commit and push changes
- [ ] 5.2 Update OpenSpec change status to completed
