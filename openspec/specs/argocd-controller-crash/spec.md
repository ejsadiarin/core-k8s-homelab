# Spec: ArgoCD Application Controller Crash Fix

## Summary

The ArgoCD application-controller was in CrashLoopBackOff, preventing any Application sync operations. The root cause was malformed `resource.customizations` configuration in the `argocd-cm` ConfigMap.

## Problem

### Symptoms

- `argocd-application-controller-0` pod in CrashLoopBackOff
- Applications stuck in OutOfSync status
- Manual syncs not processing
- ApplicationSet controller working (creating Application CRs) but application-controller not reconciling them

### Error Message

```
level=fatal msg="error loading cache settings: failed to get resource overrides: 
error unmarshaling JSON: while decoding JSON: json: cannot unmarshal string into 
Go value of type v1alpha1.rawResourceOverride"
```

### Root Cause

The ArgoCD Helm chart was generating invalid `resource.customizations` configuration in the argocd-cm ConfigMap. The format was incompatible with ArgoCD v3.1.x:

**Invalid format (was causing crash):**

```yaml
# Wrong: ignoreDifferences as a pipe string makes it unparsable
gateway.networking.k8s.io_HTTPRoute:
  ignoreDifferences: |
    jsonPointers:
    - /status
```

**Also wrong (from Helm chart defaults):**

```yaml
# These resource.customizations.ignoreResourceUpdates.* keys were also invalid
resource.customizations.ignoreResourceUpdates.all: |
  jsonPointers:
  - /status
```

The Helm chart's `configs.cm` section was merging user-provided customizations with built-in defaults, resulting in multiple conflicting key formats that ArgoCD v3.1.x couldn't parse.

## Solution

### 1. Remove resource.customizations from argocd-cm

The `resource.customizations` configuration was removed from the ArgoCD values.yaml since:

1. The format was causing controller crashes
2. ignoreDifferences are better suited at ApplicationSet level for granularity
3. Health checks are now handled via ApplicationSet-level configuration

**Updated values.yaml:**

```yaml
configs:
  cm:
    create: true
    application.resourceTrackingMethod: "annotation+label"
    # NOTE: resource.customizations removed - it was causing ArgoCD controller crashes
    # in v3.1.x. ignoreDifferences are now defined in ApplicationSet templates instead.
```

### 2. Move ignoreDifferences to ApplicationSet templates

Each ApplicationSet now defines its own `ignoreDifferences` in `template.spec`, which is the recommended pattern for ArgoCD v3.x.

### 3. Add jqPathExpressions for HTTPRoute normalization

Gateway API controllers normalize HTTPRoute resources by adding default values:

- `parentRefs[].group` - defaulted to `gateway.networking.k8s.io`
- `parentRefs[].kind` - defaulted to `Gateway`
- `backendRefs[].group` - defaulted to `""` (core API group)
- `backendRefs[].kind` - defaulted to `Service`
- `backendRefs[].weight` - defaulted to `1`

JSON pointers alone cannot handle these dynamic array fields. jqPathExpressions are required:

```yaml
ignoreDifferences:
  - group: gateway.networking.k8s.io
    kind: HTTPRoute
    jsonPointers:
      - /status
      - /spec/rules/0/backendRefs/0/weight
      - /spec/rules/0/backendRefs/0/kind
      - /spec/rules/0/backendRefs/0/group
    jqPathExpressions:
      - '.spec.parentRefs[]?.group'
      - '.spec.parentRefs[]?.kind'
      - '.spec.rules[]?.backendRefs[]?.group'
      - '.spec.rules[]?.backendRefs[]?.kind'
      - '.spec.rules[]?.backendRefs[]?.weight'
```

## Verification

After applying the fix:

1. Controller pod running: `kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-application-controller`
2. Applications syncing: `kubectl get applications -n argocd`
3. HTTPRoutes no longer OutOfSync due to normalization

## Files Modified

| File | Change |
|------|--------|
| `cluster/infrastructure/controllers/argocd/values.yaml` | Removed resource.customizations |
| `cluster/infrastructure/infrastructure-components-appset.yaml` | Added jqPathExpressions |
| `cluster/monitoring/monitoring-components-appset.yaml` | Added jqPathExpressions |
| `cluster/apps/myapplications-appset.yaml` | Added jqPathExpressions |

## Lessons Learned

1. **ArgoCD v3.1.x has strict parsing** for resource.customizations - invalid YAML will crash the controller
2. **Helm chart defaults can conflict** with user configuration, especially for nested config maps
3. **jqPathExpressions are essential** for ignoring fields in arrays where controllers add default values
4. **ApplicationSet-level ignoreDifferences** provide better granularity than global configuration

## References

- [ArgoCD Resource Customizations](https://argo-cd.readthedocs.io/en/stable/user-guide/resource_tracking/)
- [ArgoCD IgnoreDifferences](https://argo-cd.readthedocs.io/en/stable/user-guide/diffing/)
- [Gateway API HTTPRoute](https://gateway-api.sigs.k8s.io/reference/spec/#gateway.networking.k8s.io/v1.HTTPRoute)