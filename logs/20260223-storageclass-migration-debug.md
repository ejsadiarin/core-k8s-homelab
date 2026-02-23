# Debugging Workflow: StorageClass Migration (Longhorn → local-path)

**Date:** 2026-02-23  
**Context:** Migrating kube-prometheus-stack and nginx PVCs from Longhorn to local-path storage class after Longhorn CSI driver was removed from the cluster.

---

## 1. Investigation Phase

### Initial Symptoms Observed

```bash
kubectl get applications -n argocd
kube-prometheus-stack    Synced        Degraded
```

### Step-by-step Investigation

```bash
# 1. Check pod status
kubectl get pods -n kube-prometheus-stack
# Result: Grafana in Error/CrashLoop, Prometheus/Alertmanager showing "Completed"

# 2. Describe the failing pod to find root cause
kubectl describe pod -n kube-prometheus-stack -l app.kubernetes.io/name=grafana
```

### Key Finding

```
Events:
  Warning  FailedMount  ...  MountVolume.SetUp failed for volume "pvc-ff5b000a..." 
  : kubernetes.io/csi: mounter.SetUpAt failed to get CSI client: 
  driver name driver.longhorn.io not found in the list of registered CSI drivers
```

**Root Cause Identified:**
- PVCs were bound to `longhorn` storage class
- Longhorn CSI driver was not running (Longhorn was removed from cluster)
- Pods couldn't mount their volumes → crash loop

---

## 2. Verification of Assumptions

```bash
# Check PVCs and their storage classes
kubectl get pvc -A

# Result showed:
# kube-prometheus-stack/prometheus-grafana    - longhorn
# kube-prometheus-stack/prometheus-db-...     - longhorn  
# kube-prometheus-stack/alertmanager-db-...   - longhorn
# nginx/nginx-storage                         - longhorn

# Check available storage classes
kubectl get storageclass
# Result: local-path exists, longhorn exists but CSI driver not running
```

---

## 3. Solution Implementation

### The GitOps Way (ideal approach)

1. Edit `values.yaml` to change `storageClassName: longhorn` → `storageClassName: local-path`
2. Delete PVCs and PVs in cluster
3. ArgoCD sync recreates PVCs with new storage class

### What Actually Happened (debugging challenges)

#### Challenge 1: PVCs stuck in Terminating

```bash
kubectl delete pvc prometheus-grafana -n kube-prometheus-stack
# PVC stuck in Terminating status
```

**Why?** Two things blocking deletion:
1. `kubernetes.io/pvc-protection` finalizer
2. Longhorn admission webhook still active (blocking operations)

#### Challenge 2: Longhorn Admission Webhook

```bash
kubectl get pvc prometheus-grafana -n kube-prometheus-stack -o json | jq 'del(.metadata.finalizers)' | kubectl replace -f -
# Error: failed calling webhook "validator.longhorn.io": service "longhorn-admission-webhook" not found
```

**Fix:**
```bash
kubectl delete validatingwebhookconfiguration longhorn-webhook-validator
```

**Learning:** Even though Longhorn was "removed", its ValidatingWebhookConfiguration remained, blocking all PVC operations.

#### Challenge 3: Removing Finalizers

After removing the webhook:
```bash
kubectl get pvc prometheus-grafana -n kube-prometheus-stack -o json | jq 'del(.metadata.finalizers)' | kubectl replace -f -
# Success! PVC deleted
```

#### Challenge 4: StatefulSet VolumeClaimTemplates are Immutable

```bash
kubectl get statefulset prometheus-prometheus-kube-prometheus-prometheus -n kube-prometheus-stack -o jsonpath='{.spec.volumeClaimTemplates[0].spec.storageClassName}'
# Result: longhorn

# Can't patch it - immutable field
# Solution: Delete StatefulSet with --cascade=orphan (keeps pods), let ArgoCD recreate it
kubectl delete statefulset prometheus-prometheus-kube-prometheus-prometheus -n kube-prometheus-stack --cascade=orphan
```

---

## 4. Patching Cluster State vs GitOps Sync

### Question: How to patch the cluster when ArgoCD wants to sync from Git?

### Approach A: Patch via kubectl (bypasses ArgoCD temporarily)

```bash
# These patches work because kubectl talks directly to API server
kubectl patch pvc prometheus-grafana -n kube-prometheus-stack --type=json -p='[{"op":"remove","path":"/metadata/finalizers"}]'

# ArgoCD will eventually "correct" this, but by then the PVC is already deleted
# When ArgoCD syncs again, it creates a fresh PVC from Git config
```

### Approach B: Force Sync After Git Changes

```bash
# After pushing changes to Git
git add cluster/monitoring/kube-prometheus-stack/values.yaml
git commit -m "fix: migrate to local-path storage"
git push origin cluster

# Trigger ArgoCD sync
kubectl patch application kube-prometheus-stack -n argocd --type=merge -p '{"operation":{"sync":{"syncStrategy":{"hook":{}}}}}'
```

**Key Insight:** ArgoCD doesn't immediately "fight" your patches. It only reconciles on:
- Sync interval (default 3 mins)
- Manual sync trigger
- Webhook from Git push
- Hard refresh

---

## 5. Why nginx PVC Kept Using `longhorn`

This was a caching issue:

```bash
# ArgoCD cached the old manifest somewhere
kubectl get pvc nginx-storage -n nginx -o yaml | grep last-applied-configuration
# Showed: "storageClassName":"longhorn"  (old value)

# Even though Git had: storageClassName: local-path
```

**Fix:**
```bash
# Force repo server to refresh cache
kubectl delete pod -n argocd -l app.kubernetes.io/name=argocd-repo-server --force
```

---

## 6. Checklist for StorageClass Migration

### Pre-migration Checklist

```bash
# 1. List all PVCs with target storage class
kubectl get pvc -A -o custom-columns=NAME:.metadata.name,NAMESPACE:.metadata.namespace,STORAGECLASS:.spec.storageClassName | grep longhorn

# 2. Check for blocking webhooks
kubectl get validatingwebhookconfigurations | grep -i longhorn

# 3. Scale down workloads that use the PVCs
kubectl scale deployment <name> --replicas=0 -n <namespace>
kubectl scale statefulset <name> --replicas=0 -n <namespace>

# 4. Delete webhook if exists
kubectl delete validatingwebhookconfiguration longhorn-webhook-validator

# 5. Delete PVCs (may need force + finalizer removal)
kubectl delete pvc <name> -n <namespace> --force --grace-period=0

# If stuck:
kubectl get pvc <name> -n <namespace> -o json | jq 'del(.metadata.finalizers)' | kubectl replace -f -

# 6. Delete orphaned PVs
kubectl delete pv <pv-name> --force --grace-period=0

# 7. Update Git config
# Edit values.yaml: storageClassName: longhorn → local-path

# 8. Trigger sync
kubectl patch application <app-name> -n argocd --type=merge -p '{"operation":{"sync":{"syncStrategy":{"hook":{}}}}}'

# 9. For StatefulSets, may need to delete and recreate
kubectl delete statefulset <name> -n <namespace> --cascade=orphan
```

### Migration Flow

```
┌─────────────────────────────┐
│ Identify affected PVCs      │
└──────────────┬──────────────┘
               ▼
┌─────────────────────────────┐
│ Scale down workloads        │
└──────────────┬──────────────┘
               ▼
┌─────────────────────────────┐
│ Check for Longhorn webhook  │
└──────────────┬──────────────┘
               ▼
       ┌───────────────┐
       │ Webhook exists?│
       └───────┬───────┘
               │
      ┌────────┴────────┐
      ▼                 ▼
   [Yes]             [No]
      │                 │
      ▼                 │
┌─────────────────┐     │
│ Delete webhook  │     │
└────────┬────────┘     │
         └──────┬───────┘
                ▼
┌─────────────────────────────┐
│ Delete PVCs                  │
└──────────────┬──────────────┘
               ▼
       ┌─────────────────┐
       │ PVCs stuck in    │
       │ Terminating?     │
       └────────┬────────┘
                │
       ┌────────┴────────┐
       ▼                 ▼
    [Yes]             [No]
       │                 │
       ▼                 │
┌─────────────────┐      │
│ Remove finalizers│     │
│ via JSON patch   │     │
└────────┬────────┘      │
         └──────┬────────┘
                ▼
┌─────────────────────────────┐
│ Delete PVs                   │
└──────────────┬──────────────┘
               ▼
┌─────────────────────────────┐
│ Update Git values.yaml       │
└──────────────┬──────────────┘
               ▼
┌─────────────────────────────┐
│ Force ArgoCD sync            │
└──────────────┬──────────────┘
               ▼
┌─────────────────────────────┐
│ Verify new PVCs with correct │
│ storageClass                 │
└──────────────┬──────────────┘
               ▼
┌─────────────────────────────┐
│ Verify pods are Running      │
└─────────────────────────────┘
```

---

## 7. Key Learnings

| Issue | Root Cause | Fix |
|-------|-----------|-----|
| PVC stuck Terminating | `kubernetes.io/pvc-protection` finalizer | `jq 'del(.metadata.finalizers)' \| kubectl replace -f -` |
| PVC operations blocked | Longhorn webhook still active | `kubectl delete validatingwebhookconfiguration longhorn-webhook-validator` |
| StatefulSet storage immutable | VolumeClaimTemplates can't be modified | Delete STS with `--cascade=orphan`, let ArgoCD recreate |
| ArgoCD not picking up Git change | Repo server cache | `kubectl delete pod -n argocd -l app.kubernetes.io/name=argocd-repo-server` |
| ArgoCD applying old config | Cached manifest in repo server | Hard refresh + force sync |

---

## 8. Final State

```bash
kubectl get pvc -n kube-prometheus-stack
# NAME                    STATUS   STORAGECLASS
# prometheus-grafana      Bound    local-path
# prometheus-db-...       Bound    local-path
# alertmanager-db-...     Bound    local-path

kubectl get applications -n argocd kube-prometheus-stack
# NAME                    SYNC STATUS   HEALTH STATUS
# kube-prometheus-stack   Synced        Healthy
```

---

## 9. Files Modified

- `cluster/monitoring/kube-prometheus-stack/values.yaml` - Changed storageClassName from `longhorn` to `local-path` for:
  - Grafana persistence
  - Prometheus storageSpec
  - Alertmanager storage

---

## 10. Remaining Work

- nginx PVC migration (stuck due to ArgoCD caching issue, needs repo server restart)
- cloudflared DaemonSet → Deployment migration
- Security hardening for cloudflared
