# Summary: ArgoCD Debug Session

2026-02-17-2220 (February 17, 2026 10:20:36 PM)

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         ROOT CAUSE & FIX SUMMARY                                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ROOT CAUSE: ArgoCD Application Controller Crash Loop                           │
│  ═══════════════════════════════════════════════                                │
│                                                                                 │
│  The controller was crashing due to malformed resource.customizations in        │
│  the argocd-cm ConfigMap. The Helm chart was generating invalid YAML that       │
│  ArgoCD v3.1.x couldn't parse.                                                  │
│                                                                                 │
│  ERROR: json: cannot unmarshal string into Go value of type                     │
│         v1alpha1.rawResourceOverride                                            │
│                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  FIXES APPLIED:                                                                 │
│  ╀──────────────                                                                │
│                                                                                 │
│  1. Removed broken resource.customizations from argocd-cm ConfigMap             │
│     - The ignoreDifferences format was incompatible with ArgoCD v3.1.x          │
│     - Moved ignoreDifferences to ApplicationSet template.spec instead           │
│                                                                                 │
│  2. Added jqPathExpressions to ApplicationSets for HTTPRoute normalization      │
│     - Gateway API adds group/kind to parentRefs and backendRefs                 │
│     - jsonPointers alone couldn't handle these dynamic fields                   │
│                                                                                 │
│  3. Removed orphaned longhorn Application                                       │
│     - Was created before exclusion was added to AppSet                          │
│     - Had to remove finalizers to delete properly                              │
│                                                                                 │
│  4. Updated Git files to match cluster state                                    │
│     - values.yaml: removed resource.customizations                              │
│     - AppSets: added jqPathExpressions for HTTPRoute fields                     │
│                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  CURRENT STATUS:                                                                │
│  ╀──────────────                                                                │
│                                                                                 │
│  ✅ argocd-application-controller: Running (was CrashLoopBackOff)               │
│  ✅ Most applications: Synced                                                   │
│  ⚠️ argocd: OutOfSync (expected - ConfigMap changed)                            │
│  ⚠️ cloudflared: Degraded (unrelated to sync issue)                             │
│  ⚠️ nginx: Progressing (pod starting)                                           │
│  ⚠️ reloader/velero: Unknown (separate issue)                                   │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Files modified in Git:

- cluster/infrastructure/controllers/argocd/values.yaml - removed broken resource.customizations
- cluster/infrastructure/infrastructure-components-appset.yaml - added jqPathExpressions
- cluster/monitoring/monitoring-components-appset.yaml - added jqPathExpressions
- cluster/apps/myapplications-appset.yaml - added jqPathExpressions
  You should commit these changes:
  git add cluster/infrastructure/controllers/argocd/values.yaml \
   cluster/infrastructure/infrastructure-components-appset.yaml \
   cluster/monitoring/monitoring-components-appset.yaml \
   cluster/apps/myapplications-appset.yaml
  git commit -m "fix: ArgoCD controller crash and HTTPRoute OutOfSync issues
- Remove broken resource.customizations from ArgoCD values.yaml
  (was causing controller crash in v3.1.x)
- Move ignoreDifferences to ApplicationSet templates
- Add jqPathExpressions for Gateway API HTTPRoute normalization
  (handles parentRefs.group/kind and backendRefs.group/kind/weight)
- Exclude longhorn from infrastructure AppSet"
