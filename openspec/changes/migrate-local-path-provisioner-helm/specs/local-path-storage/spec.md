## ADDED Requirements

### Requirement: Local-path-provisioner is deployed via Helm chart

The local-path-provisioner SHALL be deployed using the official Rancher Helm chart with configuration managed through Helm values.

#### Scenario: Helm chart is used for deployment
- **WHEN** the kustomization.yaml is applied
- **THEN** the local-path-provisioner Helm chart is rendered
- **AND** RBAC resources are created automatically

#### Scenario: No manual YAML for RBAC
- **WHEN** the deployment is complete
- **THEN** no manual ServiceAccount, Role, ClusterRole, RoleBinding, or ClusterRoleBinding YAML exists
- **AND** all RBAC is managed by the Helm chart

### Requirement: StorageClass has Retain reclaim policy

The StorageClass created by the Helm chart SHALL use `reclaimPolicy: Retain` to preserve PV data when PVCs are deleted.

#### Scenario: PVs are retained on PVC deletion
- **WHEN** a PVC using the local-path StorageClass is deleted
- **THEN** the underlying PV remains with status Released
- **AND** data on the local path is preserved

#### Scenario: StorageClass configuration via values
- **WHEN** the Helm values specify `storageClass.reclaimPolicy: Retain`
- **THEN** the created StorageClass has `reclaimPolicy: Retain`

### Requirement: StorageClass name matches existing

The StorageClass name SHALL be `local-path` to maintain compatibility with existing PVCs.

#### Scenario: Existing PVCs remain bound
- **WHEN** the Helm chart is deployed
- **THEN** the StorageClass is named `local-path`
- **AND** existing PVCs using `local-path` remain bound

### Requirement: Provisioner runs with security hardening

The local-path-provisioner pod SHALL run with restricted security context following Pod Security Standards.

#### Scenario: Container runs as non-root
- **WHEN** the provisioner pod starts
- **THEN** the container runs as user 65534 (nobody)
- **AND** `runAsNonRoot` is set to `true`

#### Scenario: Root filesystem is read-only
- **WHEN** the provisioner container runs
- **THEN** `readOnlyRootFilesystem` is set to `true`
- **AND** the chart provides writable tmp directory

### Requirement: Provisioner runs without explicit resource limits

The local-path-provisioner container MAY run without explicit resource requests and limits, as it is a lightweight provisioner and the chart recommends leaving resources unspecified for environments with limited resources.

#### Scenario: No explicit resource limits required
- **WHEN** the Deployment manifest is rendered
- **THEN** resources MAY be unspecified
- **AND** the provisioner runs with unbounded resources
