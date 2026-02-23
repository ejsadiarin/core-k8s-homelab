## ADDED Requirements

### Requirement: Reloader SHALL be deployed as an infrastructure component
The system SHALL deploy the Reloader controller in the `reloader` namespace.

#### Scenario: Reloader is deployed
- **WHEN** the infrastructure components are synced
- **THEN** Reloader SHALL be running with:
  - Namespace: `reloader`
  - Service account with appropriate RBAC
  - Deployment with resource limits configured

### Requirement: Reloader SHALL watch for ConfigMap changes
Reloader SHALL detect ConfigMap changes and trigger rolling updates for dependent workloads.

#### Scenario: ConfigMap update triggers rollout
- **WHEN** a ConfigMap mounted by a Deployment is updated
- **THEN** Reloader SHALL trigger a rolling update of that Deployment

### Requirement: Reloader SHALL watch for Secret changes
Reloader SHALL detect Secret changes and trigger rolling updates for dependent workloads.

#### Scenario: Secret update triggers rollout
- **WHEN** a Secret mounted by a Deployment is updated
- **THEN** Reloader SHALL trigger a rolling update of that Deployment

### Requirement: Workloads SHALL opt-in to Reloader via annotations
Workloads MAY opt-in to Reloader reloader by adding specific annotations.

#### Scenario: Workload with annotation is reloaded
- **WHEN** a Deployment has annotation `configmap.reloader.stakater.com/reload: "my-configmap"`
- **THEN** Reloader SHALL trigger a rollout when my-configmap is updated

#### Scenario: Workload without annotation is not affected
- **WHEN** a Deployment has no Reloader annotations
- **THEN** Reloader SHALL NOT trigger rollouts even if referenced ConfigMaps change

### Requirement: Reloader SHALL be included in infrastructure ApplicationSet
The Reloader application SHALL be included in the infrastructure-components-appset.yaml generator.

#### Scenario: Reloader is auto-discovered
- **WHEN** the infrastructure ApplicationSet scans directories
- **THEN** Reloader at `cluster/infrastructure/controllers/reloader/` SHALL be deployed