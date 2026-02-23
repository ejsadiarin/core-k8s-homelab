## ADDED Requirements

### Requirement: Longhorn ApplicationSet ignores webhook CA bundles
The Longhorn ApplicationSet SHALL ignore differences in ValidatingWebhookConfiguration and MutatingWebhookConfiguration CA bundles.

#### Scenario: Longhorn injects webhook CA certificates
- **WHEN** Longhorn operator injects CA bundles into webhook configurations
- **THEN** ArgoCD SHALL NOT mark the application as OutOfSync

### Requirement: Longhorn ApplicationSet ignores Volume status
The Longhorn ApplicationSet SHALL ignore differences in longhorn.io/Volume status fields.

#### Scenario: Longhorn updates volume status
- **WHEN** Longhorn controller updates Volume CRD status (attachment, replication, health)
- **THEN** ArgoCD SHALL NOT mark the application as OutOfSync

### Requirement: Longhorn ApplicationSet ignores Node status
The Longhorn ApplicationSet SHALL ignore differences in longhorn.io/Node status fields.

#### Scenario: Longhorn updates node status
- **WHEN** Longhorn controller updates Node CRD status (scheduling, storage)
- **THEN** ArgoCD SHALL NOT mark the application as OutOfSync

### Requirement: Longhorn ApplicationSet ignores Setting status
The Longhorn ApplicationSet SHALL ignore differences in longhorn.io/Setting status fields.

#### Scenario: Longhorn updates setting status
- **WHEN** Longhorn controller updates Setting CRD status
- **THEN** ArgoCD SHALL NOT mark the application as OutOfSync

### Requirement: Longhorn ApplicationSet ignores Engine status
The Longhorn ApplicationSet SHALL ignore differences in longhorn.io/Engine status fields.

#### Scenario: Longhorn updates engine status
- **WHEN** Longhorn controller updates Engine CRD status
- **THEN** ArgoCD SHALL NOT mark the application as OutOfSync

### Requirement: Longhorn ApplicationSet ignores Replica status
The Longhorn ApplicationSet SHALL ignore differences in longhorn.io/Replica status fields.

#### Scenario: Longhorn updates replica status
- **WHEN** Longhorn controller updates Replica CRD status
- **THEN** ArgoCD SHALL NOT mark the application as OutOfSync

### Requirement: Longhorn ApplicationSet ignores HTTPRoute status
The Longhorn ApplicationSet SHALL ignore differences in HTTPRoute status fields for Longhorn UI access.

#### Scenario: Cilium Gateway populates Longhorn UI HTTPRoute status
- **WHEN** Cilium Gateway controller populates HTTPRoute status for Longhorn UI
- **THEN** ArgoCD SHALL NOT mark the application as OutOfSync
