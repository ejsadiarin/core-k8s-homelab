## Context

### Previously Fixed Issues (2026-02-17)

During the initial debugging session, several critical issues were discovered and resolved:

#### 1. ArgoCD Controller Crash Loop

**Symptom:** `argocd-application-controller-0` in CrashLoopBackOff

**Root Cause:** Malformed `resource.customizations` in argocd-cm ConfigMap. ArgoCD v3.1.x has strict parsing:
```
Error: json: cannot unmarshal object into Go struct field rawResourceOverride.ignoreDifferences of type string
```

**Fix:** 
- Removed all `resource.customizations.*` from values.yaml
- Moved ignoreDifferences to ApplicationSet `template.spec.ignoreDifferences`
- Restarted controller

**Lesson:** ArgoCD v3.1.x expects specific formats for resource.customizations. The Helm chart's built-in `resource.customizations.ignoreResourceUpdates.*` keys work fine, but custom ignoreDifferences in the ConfigMap can crash the controller.

#### 2. HTTPRoute OutOfSync Status

**Symptom:** HTTPRoutes showing OutOfSync despite correct configuration

**Root Cause:** Gateway API controllers normalize resources by adding default values:
- `parentRefs[].group` → `gateway.networking.k8s.io`
- `parentRefs[].kind` → `Gateway`
- `backendRefs[].group` → `""` (core API)
- `backendRefs[].kind` → `Service`
- `backendRefs[].weight` → `1`

**Fix:** Added jqPathExpressions to ApplicationSets (jsonPointers alone can't match dynamic arrays):
```yaml
jqPathExpressions:
  - '.spec.parentRefs[]?.group'
  - '.spec.parentRefs[]?.kind'
  - '.spec.rules[]?.backendRefs[]?.group'
  - '.spec.rules[]?.backendRefs[]?.kind'
  - '.spec.rules[]?.backendRefs[]?.weight'
```

#### 3. Reloader Chart Version

**Symptom:** `chart "reloader" version "1.0.0" not found`

**Fix:** Updated to valid version 2.2.8

#### 4. Velero Deprecated Config

**Symptom:** Breaking change error for restic configuration

**Fix:** Removed deprecated `enableRestic` and `restic` keys, use `deployNodeAgent`/`nodeAgent` instead. Also fixed kubectl image version (1.33 → 1.32).

#### 5. Orphaned Longhorn Application

**Symptom:** Longhorn application exists but excluded from AppSet

**Fix:** Deleted with finalizers removal. ApplicationSet exclusion now prevents recreation.

### Current State (Updated 2026-02-23)

**Root Cause Found:** All kube-prometheus-stack pods are failing because their PVCs are bound to `longhorn` storage class, but Longhorn CSI driver is not running:

```
MountVolume.SetUp failed: driver name driver.longhorn.io not found in the list of registered CSI drivers
```

This occurred because Longhorn was removed from the cluster, but existing PVCs were not migrated.

**Affected Resources:**

| PVC | Namespace | StorageClass | Size | Status |
|-----|-----------|--------------|------|--------|
| prometheus-grafana | kube-prometheus-stack | longhorn | 1Gi | Bound (inaccessible) |
| alertmanager-db-... | kube-prometheus-stack | longhorn | 512Mi | Bound (inaccessible) |
| prometheus-db-... | kube-prometheus-stack | longhorn | 10Gi | Bound (inaccessible) |
| nginx-storage | nginx | longhorn | 1Gi | Bound (running pod has mount) |

**Applications:**

1. **cloudflared**: ArgoCD reports Degraded, but DaemonSet is healthy (1/1 Ready)
   - Current: DaemonSet running on all nodes
   - Issue: Stale health cache in ArgoCD + over-provisioned for single tunnel

2. **kube-prometheus-stack**: ArgoCD reports Degraded
   - Root Cause: Longhorn PVCs with missing CSI driver
   - Fix: Delete Longhorn PVCs and recreate with local-path storage class

### Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         CURRENT ARCHITECTURE                                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  cloudflared (DaemonSet)           kube-prometheus-stack                        │
│  ┌─────────────────────┐           ┌─────────────────────────────────────┐     │
│  │ DaemonSet           │           │ StatefulSets:                        │     │
│  │ ┌─────────────────┐ │           │  - prometheus (0/2 Completed)       │     │
│  │ │ Pod per node    │ │           │  - alertmanager (0/2 Completed)     │     │
│  │ │ cloudflared     │ │           │                                      │     │
│  │ └─────────────────┘ │           │ Deployments:                         │     │
│  │                     │           │  - grafana (Error/CrashLoop)        │     │
│  │ Only 1 needed!      │           │  - operator (1/1 Running)           │     │
│  │ Tunnel is stateless │           │  - kube-state-metrics (1/1)         │     │
│  └─────────────────────┘           │  - node-exporter (DaemonSet)        │     │
│                                    └─────────────────────────────────────┘     │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Goals / Non-Goals

**Goals:**
- Convert cloudflared from DaemonSet to Deployment (right-size for single tunnel)
- Add security hardening to cloudflared (securityContext, resource limits)
- Fix Grafana crash loop in kube-prometheus-stack
- Document and understand ArgoCD health status caching behavior

**Non-Goals:**
- Changes to ArgoCD controller code (only configuration)
- Changes to other monitoring components (Prometheus, Alertmanager)
- Network policy changes
- External DNS or gateway changes

## Decisions

### 1. Cloudflared: DaemonSet → Deployment

**Decision:** Convert cloudflared to Deployment with 1 replica.

**Rationale:**
- Cloudflare Tunnel is stateless - only one connection needed to Cloudflare edge
- DaemonSet wastes resources on single-node cluster
- Reference k8s-gitops uses Deployment pattern
- Security hardening easier with Deployment

**Trade-off:** On multi-node clusters, DaemonSet provides redundancy
→ **Mitigation:** Can increase replicas if needed; Deployment supports HPA

### 2. Cloudflared Security Hardening

**Decision:** Add PodSecurityContext and ContainerSecurityContext.

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 65532
  runAsGroup: 65532
  seccompProfile:
    type: RuntimeDefault
  fsGroup: 65532

containerSecurityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop: [ALL]
```

**Rationale:** Matches security best practices from k8s-gitops reference.

### 3. Grafana Crash Loop Investigation

**Decision:** Investigate Grafana probe failures (HTTP 503).

**Root cause hypotheses:**
1. PVC issue (storage not ready)
2. Init container race condition
3. ConfigMap/Secret mount issues
4. Resource limits too low
5. Liveness probe timeout too aggressive

**Approach:**
1. Check Grafana container logs
2. Verify PVC status
3. Check init container status
4. Review probe configuration

### 4. ArgoCD Health Status Caching

**Decision:** Document the caching behavior, no code changes.

**Observations:**
- Health status has `lastTransitionTime` that can be days old
- Restarting application-controller clears cache
- Restarting repo-server clears manifest cache
- This is expected ArgoCD behavior, not a bug

**Mitigation:** Force refresh applications after significant changes.

## Risks / Trade-offs

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Cloudflared tunnel reconnects during conversion | Medium | Low | Brief downtime, auto-reconnect |
| Grafana data loss during fix | Low | Medium | PVC persists, backup exists |
| Security context breaks cloudflared | Low | High | Test locally, rollback available |
| Health status remains stale | Medium | Low | Manual refresh or controller restart |

## Migration Plan

### Phase 1: Storage Migration (2026-02-23 - In Progress)

1. ~~Scale down kube-prometheus-stack StatefulSets and Deployments~~ ✅
2. ~~Delete Longhorn PVCs and PVs (force delete with finalizer removal)~~ ✅
3. ~~Update values.yaml: `storageClassName: longhorn` → `storageClassName: local-path`~~ ✅
4. Force ArgoCD sync to recreate PVCs with local-path
5. Verify monitoring stack comes up healthy

**Note on nginx:** nginx pod is running with Longhorn PVC mounted. If pod restarts, it will fail. Handle similarly.

### Phase 2: Cloudflared Conversion

1. Update deployment.yaml: DaemonSet → Deployment
2. Add security contexts
3. Apply via ArgoCD (will recreate pods)
4. Verify tunnel connectivity

### Phase 3: Verification

1. Run `kubectl get applications -n argocd` - all should be Synced/Healthy
2. Verify cloudflared tunnel is connected
3. Verify Grafana UI is accessible

### Rollback

- Revert Git changes
- ArgoCD will auto-sync to previous state
- No data loss expected
