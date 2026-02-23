## Context

ArgoCD is a GitOps tool that continuously monitors Git repositories and ensures the Kubernetes cluster state matches the desired state defined in Git. However, many Kubernetes controllers (Cilium, cert-manager, Longhorn, Prometheus) modify resources after creation:

- **Cilium Gateway API**: Populates HTTPRoute status with parent gateway information, normalizes parentRefs/backendRefs with default group/kind values
- **cert-manager**: Injects CA bundles into webhook configurations
- **Longhorn**: Updates Volume/Node/Setting CRD status fields continuously
- **Prometheus Operator**: Modifies ServiceMonitor endpoints and CRD statuses

This creates a mismatch between Git (source of truth) and cluster state (modified by controllers), causing ArgoCD to mark applications as "OutOfSync" even though the configuration is correct.

### Critical Discovery: Controller Crash

During investigation, it was discovered that the **argocd-application-controller was in CrashLoopBackOff**, which was the root cause of sync failures. See [argocd-controller-crash spec](./specs/argocd-controller-crash/spec.md) for details.

**Key finding:** The ArgoCD Helm chart was generating invalid `resource.customizations` configuration that crashed the controller on startup:

```
level=fatal msg="error loading cache settings: failed to get resource overrides: 
error unmarshaling JSON: json: cannot unmarshal string into Go value of 
type v1alpha1.rawResourceOverride"
```

The fix required:
1. Removing the broken `resource.customizations` from argocd-cm ConfigMap
2. Moving ignoreDifferences to ApplicationSet templates
3. Adding jqPathExpressions for Gateway API HTTPRoute normalization

## Goals / Non-Goals

**Goals:**
- Eliminate false-positive OutOfSync statuses for all applications
- Configure ignoreDifferences at ApplicationSet level for granular control
- Maintain proper sync wave ordering with Application health checks
- Add documentation via `info` sections in ApplicationSets

**Non-Goals:**
- Change any application functionality or behavior
- Modify controller configurations
- Add new applications or resources
- Change sync policies or deployment strategies
- Fix actual configuration drift (only expected controller modifications)

## Decisions

### 1. Application-Level vs Global ignoreDifferences

**Decision:** Configure ignoreDifferences in ApplicationSet `template.spec` rather than relying solely on global ArgoCD config.

**Rationale:**
- Global config applies to ALL applications, which can mask real issues
- ApplicationSet-level config is scoped to specific app types
- Easier to maintain and understand per-application differences
- Matches k8s-gitops best practices pattern

**Alternative considered:** Continue using only global config, but this doesn't provide enough granularity for different app types.

### 2. Separate Longhorn ApplicationSet

**Decision:** Create a dedicated ApplicationSet for Longhorn instead of including it in the general infrastructure set.

**Rationale:**
- Longhorn has extensive webhook and CRD configurations
- Requires more retry attempts (storage operations can fail temporarily)
- Has unique ignoreDifferences requirements (Volume, Node, Setting, Engine, Replica statuses)
- Easier to troubleshoot when isolated

**Alternative considered:** Keep in infrastructure-appset with generic rules, but this would miss Longhorn-specific fields.

### 3. JSON Pointers vs jqPathExpressions

**Decision:** Use JSON Pointers (`/status`, `/webhooks/*/caBundle`) for most fields, with jqPathExpressions only for complex StatefulSet volumeClaimTemplates.

**Rationale:**
- JSON Pointers are simpler and more readable
- Most controller modifications are simple field updates
- jqPathExpressions needed only for array traversal with wildcards

**Alternative considered:** Use jqPathExpressions everywhere, but this adds unnecessary complexity.

### 4. AllowEmpty: false

**Decision:** Add `allowEmpty: false` to all ApplicationSet sync policies.

**Rationale:**
- Prevents ArgoCD from creating empty applications
- Catches configuration errors early
- Matches k8s-gitops pattern

### 5. Application Health Check Customization

**Decision:** Add Lua-based health check for Application resources to properly support sync waves.

**Rationale:**
- Without this, parent apps mark healthy before children are ready
- Breaks sync wave ordering (apps deploy out of order)
- Critical for infrastructure → monitoring → apps dependency chain

## Risks / Trade-offs

**Risk:** Ignoring too many fields could mask real configuration drift
→ **Mitigation:** Only ignore fields that controllers are known to modify (status, CA bundles, normalized values). Regular fields (spec, metadata) still tracked.

**Risk:** ApplicationSet-level ignoreDifferences could be overlooked during troubleshooting
→ **Mitigation:** Document clearly in proposal and design; use `info` sections in ApplicationSets for visibility.

**Risk:** New controller versions may modify different fields
→ **Mitigation:** Use wildcards where possible (`/webhooks/*/caBundle`), document patterns, monitor for new OutOfSync issues after controller updates.

**Risk:** HTTPRoute parentRefs changes could affect routing
→ **Mitigation:** Only ignore weight/kind/group normalization, not parentRefs themselves. Gateway assignment still tracked.

**Trade-off:** More verbose ApplicationSets vs cleaner global config
→ **Acceptance:** ApplicationSet verbosity provides better transparency and control. Worth the extra YAML lines.

## Migration Plan

1. **Apply ArgoCD Config Changes**
   - ArgoCD will pick up new health check configuration
   - Requires ArgoCD app sync or restart

2. **Apply New ApplicationSets**
   - New Longhorn ApplicationSet created
   - Existing ApplicationSets updated with ignoreDifferences
   - Changes applied via GitOps (automatic once committed)

3. **Sync Applications**
   - All OutOfSync apps will automatically sync
   - Status should change from OutOfSync → Synced
   - Verify in ArgoCD UI

4. **Rollback Strategy**
   - Revert Git changes to restore previous ApplicationSets
   - Applications will return to OutOfSync state but remain functional
   - No data loss or downtime risk

## Open Questions

None - implementation approach is well-defined from k8s-gitops reference implementation.
