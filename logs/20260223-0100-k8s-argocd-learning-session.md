# Summary: Kubernetes & ArgoCD Learning Session

2026-02-23-0100 (February 23, 2026 1:00 AM)

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         SESSION OVERVIEW                                         │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  TOPICS COVERED:                                                                │
│  ═══════════════                                                                │
│  1. OpenSpec workflow (verification, archival)                                  │
│  2. Local-path-provisioner Helm migration                                       │
│  3. ArgoCD ignoreDifferences configuration                                      │
│  4. Kubernetes storage concepts (PVC/PV/StorageClass)                           │
│  5. Helm chart workflows                                                        │
│  6. Kustomize + Helm integration                                                │
│                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  CHANGES ARCHIVED:                                                              │
│  ╀──────────────                                                                │
│                                                                                 │
│  • fix-expense-update-priority-clearing (3 tasks)                               │
│  • migrate-local-path-provisioner-helm (10 tasks)                               │
│  • fix-argocd-outofsync-appsets (41 tasks)                                      │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 1. OpenSpec Workflow

### Verification Process

- `openspec status --change "<name>" --json` - check artifact completion
- Parse `- [x]` vs `- [ ]` for task completion
- Verify specs against implementation in codebase
- Generate reports: Completeness, Correctness, Coherence

### Archival Process

1. Check delta specs need syncing to `openspec/specs/`
2. Move completed changes to `openspec/changes/archive/YYYY-MM-DD-<name>/`
3. Sync specs before archiving

---

## 2. Local-Path-Provisioner Helm Migration

### Before vs After

```
Before: 163 lines of manual YAML (RBAC, Deployment, ConfigMap, StorageClass)
After:   80 lines total (namespace.yaml, kustomization.yaml, values.yaml)
```

### Key Configuration

```yaml
# values.yaml - CRITICAL SETTINGS
storageClass:
  name: local-path
  provisionerName: rancher.io/local-path  # MUST match existing PVs!
  reclaimPolicy: Retain
  volumeBindingMode: WaitForFirstConsumer

securityContext:
  runAsNonRoot: true
  runAsUser: 65534
  readOnlyRootFilesystem: true
```

### The Immutable Field Problem

When migrating, encountered fields that cannot be changed after creation:

| Resource | Immutable Fields |
|----------|-----------------|
| StorageClass | `provisioner`, `reclaimPolicy` |
| Deployment | `spec.selector` |

**Solution:** Delete resources manually, then let ArgoCD recreate them.

---

## 3. ArgoCD Concepts

### ApplicationSet → Application Relationship

```
ApplicationSet (Template)
    │
    ├── Generates → Application (via git generator)
    │
    └── template.spec.ignoreDifferences → Inherited by all Applications
```

### ignoreDifferences Configuration

**Why needed:** Controllers modify resources after deployment:
- Cilium Gateway → HTTPRoute status, parentRefs normalization
- cert-manager → Webhook CA bundles
- Longhorn → Volume/Node/Engine/Replica status
- Prometheus Operator → CRD status, ServiceMonitor endpoints

```yaml
ignoreDifferences:
  - group: gateway.networking.k8s.io
    kind: HTTPRoute
    jsonPointers:
      - /status
    jqPathExpressions:          # For dynamic array fields
      - '.spec.parentRefs[]?.group'
      - '.spec.parentRefs[]?.kind'
```

### JSON Pointers vs jqPathExpressions

| Type | Use Case | Example |
|------|----------|---------|
| JSON Pointers | Static paths | `/status`, `/webhooks/*/caBundle` |
| jqPathExpressions | Dynamic arrays | `.spec.parentRefs[]?.group` |

---

## 4. Kubernetes Storage Concepts

### PVC ↔ PV ↔ StorageClass Relationship

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  PVC                                            PV              │
│  ┌─────────────────────┐              ┌─────────────────────┐  │
│  │ spec:               │              │ spec:               │  │
│  │   storageClassName ─┼──────────────┼─► (provisioned by)  │  │
│  │   volumeName ───────┼─────────────►│ claimRef:           │  │
│  │                     │              │   name: pvc-name    │  │
│  │ NO ownerReferences  │◄─────────────│   namespace: ns     │  │
│  └─────────────────────┘              │                     │  │
│                                       │ NO ownerReferences  │  │
│                                       └─────────────────────┘  │
│                                                                 │
│  StorageClass (NO relationship to PVC/PV)                       │
│  ┌─────────────────────┐                                        │
│  │ reclaimPolicy       │  ← Controls PV deletion behavior      │
│  │ allowVolumeExpansion│  ← Allows PVC resize                  │
│  └─────────────────────┘                                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### reclaimPolicy Behavior

| Policy | PVC Deleted → PV | Data |
|--------|------------------|------|
| `Delete` | PV deleted | LOST |
| `Retain` | PV becomes "Released" | PRESERVED |

### Volume Expansion

```yaml
# StorageClass must have:
allowVolumeExpansion: true

# PVC can be expanded (not shrunk):
1Gi → 2Gi ✅  (same PV, filesystem expanded)
2Gi → 1Gi ❌  (forbidden - data loss risk)
```

### Immutable Fields Summary

| Resource | Immutable Fields |
|----------|-----------------|
| PVC | `storageClassName` |
| PV | `capacity`, `storageClassName` |
| StorageClass | `provisioner`, `reclaimPolicy` |
| Deployment | `spec.selector` |

---

## 5. Provisioner Name Importance

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  StorageClass                                                   │
│  provisioner: rancher.io/local-path                            │
│       │                                                         │
│       │  This is like a "phone number"                          │
│       │                                                         │
│       ▼                                                         │
│  local-path-provisioner binary                                  │
│  "I only answer calls to rancher.io/local-path"                │
│                                                                 │
│  If provisioner name changes:                                   │
│  → Existing PVs still reference old provisioner                 │
│  → New PVCs won't be provisioned correctly                      │
│  → ORPHANED VOLUMES                                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Helm charts auto-generate provisioner names** like `cluster.local/<release-name>`. Must set explicitly:

```yaml
storageClass:
  provisionerName: rancher.io/local-path  # Preserve compatibility
```

---

## 6. ArgoCD Sync Options Annotation

```yaml
annotations:
  argocd.argoproj.io/sync-options: Delete=false
```

| Action | With `Delete=false` | Without |
|--------|---------------------|---------|
| Remove from Git | Resource kept | Resource deleted |
| Prune operation | Resource kept | Resource deleted |
| Update resource | Resource updated | Resource updated |

**Best practice:** Use for PVCs to prevent accidental data loss.

---

## 7. Helm Chart Workflow

### Finding Values Templates

```bash
# Method 1: helm show values (recommended)
helm show values rancher/local-path-provisioner --version 0.0.34

# Method 2: helm pull (download full chart)
helm pull rancher/local-path-provisioner --version 0.0.34 --untar

# Method 3: Artifact Hub / GitHub
```

### Kustomize + Helm Integration

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

helmCharts:
  - name: local-path-provisioner
    repo: https://charts.containeroo.ch
    version: 0.0.35
    releaseName: local-path-provisioner
    namespace: local-path-storage
    valuesFile: values.yaml
```

**Requires:** `kustomize build --enable-helm` or ArgoCD plugin

### The `charts/` Directory

- Local cache created when running `kustomize build --enable-helm`
- NOT tracked in git - add to `.gitignore`
- Recreated on each build

---

## 8. kubectl Label Selectors

```bash
# Basic syntax
kubectl get pods -l app=nginx

# Multiple labels (AND)
kubectl get pods -l app=nginx,env=prod

# Set-based matching
kubectl get pods -l 'app in (nginx,grafana)'

# Inequality
kubectl get pods -l app!=nginx

# Exists (has label key)
kubectl get pods -l app
```

---

## Quick Reference Table

| Concept | Key Point |
|---------|-----------|
| PVC `storageClassName` | Immutable after creation |
| PV `reclaimPolicy` | Delete=lose data, Retain=keep data |
| `Delete=false` annotation | Prevents ArgoCD prune, not kubectl delete |
| Volume expansion | Same PV expanded, cannot shrink |
| `ignoreDifferences` | Handle controller modifications |
| `jqPathExpressions` | For dynamic array fields in ignoreDifferences |
| ApplicationSet | Generates Applications with shared config |
| Helm chart values | `helm show values <chart>` to get template |
| Provisioner name | Must match for existing PVs to work |
| `charts/` directory | Local cache, add to .gitignore |

---

## Files Modified in Git

- `cluster/infrastructure/storage/local-path-provisioner/` - Helm migration
- `openspec/changes/archive/` - Archived 3 completed changes
- `openspec/specs/` - Synced 7 new specs
- `.gitignore` - Added `charts/` pattern
