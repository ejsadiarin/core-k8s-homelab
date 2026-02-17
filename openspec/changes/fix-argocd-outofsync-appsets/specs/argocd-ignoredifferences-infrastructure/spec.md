## ADDED Requirements

### Requirement: Infrastructure ApplicationSet ignores webhook CA bundles
The infrastructure ApplicationSet SHALL ignore differences in ValidatingWebhookConfiguration and MutatingWebhookConfiguration CA bundles.

#### Scenario: cert-manager webhook CA is injected
- **WHEN** cert-manager injects CA bundle into webhook configurations
- **THEN** ArgoCD SHALL NOT mark the application as OutOfSync

### Requirement: Infrastructure ApplicationSet ignores CRD preserveUnknownFields
The infrastructure ApplicationSet SHALL ignore differences in CustomResourceDefinition preserveUnknownFields fields.

#### Scenario: CRD fields are modified by controllers
- **WHEN** controllers modify CRD preserveUnknownFields
- **THEN** ArgoCD SHALL NOT mark the application as OutOfSync

### Requirement: Infrastructure ApplicationSet ignores HTTPRoute status and parentRefs
The infrastructure ApplicationSet SHALL ignore differences in HTTPRoute status and parentRefs normalization fields.

#### Scenario: Cilium Gateway populates HTTPRoute status
- **WHEN** Cilium Gateway controller populates HTTPRoute status and normalizes parentRefs
- **THEN** ArgoCD SHALL NOT mark the application as OutOfSync

### Requirement: Infrastructure ApplicationSet ignores StatefulSet volumeClaimTemplates
The infrastructure ApplicationSet SHALL ignore differences in StatefulSet volumeClaimTemplates apiVersion and kind fields.

#### Scenario: Kubernetes normalizes volumeClaimTemplates
- **WHEN** Kubernetes normalizes StatefulSet volumeClaimTemplates fields
- **THEN** ArgoCD SHALL NOT mark the application as OutOfSync
