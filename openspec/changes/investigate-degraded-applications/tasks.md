## 0. Previously Completed (2026-02-17)

These issues were discovered and fixed during the initial investigation session.

### 0.1 ArgoCD Controller Crash Fix

- [x] 0.1.1 Identified root cause: malformed `resource.customizations` in argocd-cm ConfigMap
- [x] 0.1.2 Removed incompatible `resource.customizations` keys that caused CrashLoopBackOff
- [x] 0.1.3 Removed `resource.customizations.ignoreResourceUpdates.*` keys temporarily
- [x] 0.1.4 Restarted application-controller to verify fix
- [x] 0.1.5 Documented that ignoreDifferences should be in ApplicationSet templates, not global ConfigMap

**Root Cause:** ArgoCD v3.1.x has strict parsing for `resource.customizations`. The Helm chart was generating invalid YAML:
```
Error: json: cannot unmarshal object into Go struct field rawResourceOverride.ignoreDifferences of type string
```

**Fix:** Removed all `resource.customizations.*` from values.yaml and rely on ApplicationSet-level `ignoreDifferences`.

### 0.2 HTTPRoute OutOfSync Fix

- [x] 0.2.1 Identified that Gateway API controllers normalize HTTPRoute resources
- [x] 0.2.2 Added jqPathExpressions to ApplicationSet templates for HTTPRoute:
  - `.spec.parentRefs[]?.group`
  - `.spec.parentRefs[]?.kind`
  - `.spec.rules[]?.backendRefs[]?.group`
  - `.spec.rules[]?.backendRefs[]?.kind`
  - `.spec.rules[]?.backendRefs[]?.weight`
- [x] 0.2.3 Updated infrastructure-components-appset.yaml
- [x] 0.2.4 Updated monitoring-components-appset.yaml
- [x] 0.2.5 Updated myapplications-appset.yaml

**Root Cause:** Gateway API adds default values (`group`, `kind`, `weight`) to parentRefs and backendRefs. JSON pointers alone can't handle dynamic array fields.

### 0.3 Reloader Chart Fix

- [x] 0.3.1 Identified error: `chart "reloader" version "1.0.0" not found`
- [x] 0.3.2 Updated kustomization.yaml to use version 2.2.8
- [x] 0.3.3 Committed and pushed fix
- [x] 0.3.4 Verified application syncs successfully

### 0.4 Velero Configuration Fix

- [x] 0.4.1 Identified error: deprecated `enableRestic` and `restic` keys
- [x] 0.4.2 Removed deprecated restic configuration from values.yaml
- [x] 0.4.3 Fixed kubectl image version: bitnami/kubectl:1.33 → 1.32 (1.33 doesn't exist)
- [x] 0.4.4 Committed and pushed fix

**Note:** Velero still shows OutOfSync due to missing B2 credentials (expected - not configured yet).

### 0.5 Longhorn Application Cleanup

- [x] 0.5.1 Identified orphaned Longhorn application (excluded from AppSet but still existed)
- [x] 0.5.2 Deleted application with finalizers
- [x] 0.5.3 Verified ApplicationSet exclusion is working

---

## 1. Investigation

- [x] 1.1 Check Grafana pod logs for crash cause
- [x] 1.2 Check Grafana PVC status and storage
- [x] 1.3 Review Grafana probe configuration in values.yaml
- [x] 1.4 Verify current cloudflared tunnel connectivity

**Findings (2026-02-23):**
- Grafana crash: PVC bound to `longhorn` storage class but Longhorn CSI driver not running
- Error: `driver name driver.longhorn.io not found in the list of registered CSI drivers`
- Same issue affects: Prometheus, Alertmanager, nginx PVCs
- Solution: Migrate PVCs to `local-path` storage class

## 1.5 PVC Migration to local-path

- [x] 1.5.1 Scale down kube-prometheus-stack StatefulSets (prometheus, alertmanager)
- [x] 1.5.2 Scale down kube-prometheus-stack Deployments (grafana)
- [x] 1.5.3 Delete Longhorn PVCs in kube-prometheus-stack namespace
- [x] 1.5.4 Delete Longhorn PVs (force delete with finalizer removal)
- [x] 1.5.5 Update values.yaml: storageClassName longhorn → local-path for Grafana
- [x] 1.5.6 Update values.yaml: storageClassName longhorn → local-path for Prometheus
- [x] 1.5.7 Update values.yaml: storageClassName longhorn → local-path for Alertmanager
- [ ] 1.5.8 Force ArgoCD sync to recreate PVCs
- [ ] 1.5.9 Verify monitoring stack pods are Running

## 2. Cloudflared Migration

- [ ] 2.1 Convert DaemonSet to Deployment in `cluster/infrastructure/networking/cloudflared/deployment.yaml`
- [ ] 2.2 Add PodSecurityContext (runAsNonRoot, runAsUser: 65532)
- [ ] 2.3 Add ContainerSecurityContext (readOnlyRootFilesystem, drop capabilities)
- [ ] 2.4 Update resource limits (requests: 100m/64Mi, limits: 500m/256Mi)
- [ ] 2.5 Add emptyDir volume for /tmp
- [ ] 2.6 Commit and push changes
- [ ] 2.7 Verify tunnel reconnects after Deployment rollout

## 3. Grafana Fix

- [ ] 3.1 Identify root cause from logs (probe timeout, resource limit, config issue)
- [ ] 3.2 Update kube-prometheus-stack values.yaml with fix
- [ ] 3.3 Delete failing Grafana pods to force recreation
- [ ] 3.4 Verify Grafana pod reaches Ready state
- [ ] 3.5 Verify Grafana UI is accessible via HTTPRoute

## 4. Verification

- [ ] 4.1 Run `kubectl get applications -n argocd` - verify cloudflared shows Synced/Healthy
- [ ] 4.2 Verify kube-prometheus-stack shows Synced/Healthy
- [ ] 4.3 Test cloudflared tunnel connectivity (access external domain)
- [ ] 4.4 Test Grafana dashboard access
- [ ] 4.5 Document any additional ArgoCD health cache fixes needed

## 5. Cleanup

- [ ] 5.1 Remove any orphaned DaemonSet resources if needed
- [ ] 5.2 Update OpenSpec change status to completed
