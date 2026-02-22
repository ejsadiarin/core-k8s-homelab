## Context

### Current State

The local-path-provisioner is deployed via manual YAML at `cluster/infrastructure/storage/local-path-provisioner/local-path-storage.yaml` containing:
- Namespace definition
- ServiceAccount with Role/ClusterRole and bindings
- Deployment with container spec
- ConfigMap with setup/teardown scripts
- StorageClass with `reclaimPolicy: Retain`

The manifest is 163 lines and must be manually updated for any changes.

### Constraints

- Existing PVs must remain unaffected during migration
- `reclaimPolicy: Retain` must be preserved (critical for Velero backup workflow)
- StorageClass name `local-path` must remain unchanged to avoid PVC binding issues
- Volume binding mode `WaitForFirstConsumer` must be preserved

## Goals / Non-Goals

**Goals:**
- Replace manual YAML with official Rancher Helm chart
- Reduce configuration footprint from ~163 to ~35 lines
- Add security hardening (securityContext, resource limits)
- Preserve all existing behavior (reclaimPolicy, storageClass name, binding mode)

**Non-Goals:**
- Changes to existing PVs or PVCs
- Changes to backup/restore workflow with Velero
- Adding new storage classes

## Decisions

### 1. Use Official Rancher Helm Chart

**Decision:** Use the official `rancher/local-path-provisioner` Helm chart from the Rancher GitHub pages repo.

**Rationale:**
- Official chart maintained by Rancher
- Automatic RBAC creation via `rbac.create: true`
- Configurable StorageClass via values
- Supports `reclaimPolicy` configuration
- Version 0.0.34 matches current image version v0.0.30 with upgrade path

**Alternatives considered:**
- Containeroo chart: Third-party, less official
- DIY manifest: Current state, harder to maintain

### 2. Security Context Hardening

**Decision:** Add security context following Pod Security Standards "Restricted" profile where possible.

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 65534
  readOnlyRootFilesystem: true
```

**Rationale:**
- Follows cluster security posture
- Reduces attack surface
- Chart supports this via `securityContext` values

**Trade-off:** May require emptyDir for `/tmp` if provisioner needs write access. Chart handles this automatically.

### 3. Resource Limits

**Decision:** Add explicit resource requests and limits.

```yaml
resources:
  requests:
    cpu: 50m
    memory: 64Mi
  limits:
    cpu: 200m
    memory: 128Mi
```

**Rationale:**
- Provisioner is lightweight
- Prevents resource contention on single-node cluster
- Current manual manifest has no limits

## Risks / Trade-offs

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| StorageClass recreation causes brief unavailability | Low | Medium | StorageClass is non-namespaced, recreation is instant |
| Security context breaks provisioner | Low | High | Test locally first; chart handles tmpdir |
| Helm repo unavailable | Low | Low | Chart can be vendored locally |
| Existing PVs affected | Very Low | High | PVs are independent of provisioner deployment |

## Migration Plan

### Phase 1: Create New Files

1. Create `namespace.yaml` (explicit namespace)
2. Create `values.yaml` with Helm configuration
3. Update `kustomization.yaml` to use Helm chart

### Phase 2: Deploy

1. ArgoCD will sync and create new resources
2. New Deployment replaces old (same name = seamless)
3. RBAC recreated (same permissions)

### Phase 3: Cleanup

1. Delete `local-path-storage.yaml` (now managed by Helm)

### Rollback

- Revert Git changes
- ArgoCD will auto-sync to previous state
- No data loss (PVs unaffected)
