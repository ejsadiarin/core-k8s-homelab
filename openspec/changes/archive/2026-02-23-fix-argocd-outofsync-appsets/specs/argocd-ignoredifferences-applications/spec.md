## ADDED Requirements

### Requirement: Applications ApplicationSet ignores HTTPRoute status
The applications ApplicationSet SHALL ignore differences in HTTPRoute status and parentRefs normalization fields.

#### Scenario: Cilium Gateway populates application HTTPRoute status
- **WHEN** Cilium Gateway controller populates HTTPRoute status for user applications
- **THEN** ArgoCD SHALL NOT mark the application as OutOfSync

### Requirement: Applications ApplicationSet ignores Deployment resources
The applications ApplicationSet SHALL ignore differences in Deployment container and initContainer resource fields.

#### Scenario: VPA or defaults modify resource requests/limits
- **WHEN** Vertical Pod Autoscaler or cluster defaults modify Deployment resources
- **THEN** ArgoCD SHALL NOT mark the application as OutOfSync

### Requirement: Applications ApplicationSet ignores PVC status
The applications ApplicationSet SHALL ignore differences in PersistentVolumeClaim status fields.

#### Scenario: PVC binding updates status
- **WHEN** PersistentVolume binding updates PVC status
- **THEN** ArgoCD SHALL NOT mark the application as OutOfSync

### Requirement: Applications ApplicationSet ignores Service status
The applications ApplicationSet SHALL ignore differences in Service status fields.

#### Scenario: Service endpoints populate status
- **WHEN** Kubernetes populates Service status with endpoint information
- **THEN** ArgoCD SHALL NOT mark the application as OutOfSync
