## ADDED Requirements

### Requirement: ArgoCD ignoreDifferences are defined at ApplicationSet level

The ignoreDifferences configuration SHALL be defined in ApplicationSet `template.spec.ignoreDifferences` rather than in the global argocd-cm ConfigMap, to prevent controller crashes and provide granular control.

#### Scenario: ApplicationSet has ignoreDifferences defined
- **WHEN** an ApplicationSet is created for applications with HTTPRoute resources
- **THEN** the `template.spec.ignoreDifferences` contains HTTPRoute normalization rules
- **AND** no ignoreDifferences for HTTPRoute are in the global ConfigMap

#### Scenario: Controller starts without crash
- **WHEN** ArgoCD application-controller starts
- **THEN** it parses the argocd-cm ConfigMap without errors
- **AND** no `json: cannot unmarshal` errors appear in logs

### Requirement: HTTPRoute ignoreDifferences use jqPathExpressions

HTTPRoute ignoreDifferences SHALL use jqPathExpressions in addition to jsonPointers to handle Gateway API normalization of dynamic array fields.

#### Scenario: parentRefs normalization ignored
- **WHEN** Gateway API controller adds default `group` and `kind` to parentRefs
- **THEN** ArgoCD does not mark the HTTPRoute as OutOfSync
- **AND** the jqPathExpressions `.spec.parentRefs[]?.group` and `.spec.parentRefs[]?.kind` are matched

#### Scenario: backendRefs normalization ignored
- **WHEN** Gateway API controller adds default `group`, `kind`, and `weight` to backendRefs
- **THEN** ArgoCD does not mark the HTTPRoute as OutOfSync
- **AND** the jqPathExpressions for backendRefs fields are matched

### Requirement: Helm chart versions must exist in repositories

All Helm chart versions referenced in kustomization.yaml files SHALL be valid versions that exist in their respective repositories.

#### Scenario: Invalid chart version is caught
- **WHEN** a kustomization.yaml references a non-existent chart version
- **THEN** ArgoCD shows a ComparisonError with clear message
- **AND** the error message includes the repository URL and requested version

### Requirement: Velero uses nodeAgent instead of deprecated restic

Velero configuration SHALL use `deployNodeAgent` and `nodeAgent` keys instead of deprecated `enableRestic` and `restic` keys for chart version 8.x.

#### Scenario: Velero chart renders without errors
- **WHEN** the Velero Helm chart is rendered with values.yaml
- **THEN** no breaking change warnings appear
- **AND** the node-agent DaemonSet is created

#### Scenario: kubectl image version exists
- **WHEN** Velero upgrade-crds job runs
- **THEN** the bitnami/kubectl image tag exists in Docker Hub
- **AND** no ImagePullBackOff errors occur
