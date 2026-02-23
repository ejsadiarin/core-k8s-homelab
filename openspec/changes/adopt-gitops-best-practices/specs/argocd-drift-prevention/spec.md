## ADDED Requirements

### Requirement: ArgoCD SHALL ignore webhook CA bundle differences
The system SHALL configure ArgoCD to ignore CA bundle fields in webhook configurations that are injected by controllers.

#### Scenario: ValidatingWebhookConfiguration CA bundle is ignored
- **WHEN** ArgoCD compares a ValidatingWebhookConfiguration resource
- **THEN** differences in `/webhooks/*/clientConfig/caBundle` SHALL be ignored

#### Scenario: MutatingWebhookConfiguration CA bundle is ignored
- **WHEN** ArgoCD compares a MutatingWebhookConfiguration resource
- **THEN** differences in `/webhooks/*/clientConfig/caBundle` SHALL be ignored

### Requirement: ArgoCD SHALL ignore status field differences
The system SHALL configure ArgoCD to ignore status fields that are populated by controllers.

#### Scenario: HTTPRoute status is ignored
- **WHEN** ArgoCD compares an HTTPRoute resource
- **THEN** differences in `/status` SHALL be ignored

#### Scenario: Gateway status is ignored
- **WHEN** ArgoCD compares a Gateway resource
- **THEN** differences in `/status` SHALL be ignored

#### Scenario: Longhorn volume status is ignored
- **WHEN** ArgoCD compares a Longhorn Volume resource
- **THEN** differences in `/status` SHALL be ignored

### Requirement: ArgoCD SHALL ignore ServiceMonitor endpoint modifications
The system SHALL configure ArgoCD to ignore ServiceMonitor endpoint fields that are modified by Prometheus operator.

#### Scenario: ServiceMonitor endpoints differences are ignored
- **WHEN** ArgoCD compares a ServiceMonitor resource
- **THEN** differences in `/spec/endpoints` SHALL be ignored

### Requirement: ignoreDifferences SHALL be configured centrally in ArgoCD ConfigMap
All ignoreDifferences configurations SHALL be defined in the ArgoCD config-cm ConfigMap via values.yaml.

#### Scenario: Configuration is in values.yaml
- **WHEN** ArgoCD is deployed
- **THEN** the `configs.cm.resource.customizations` section in values.yaml SHALL contain all ignoreDifferences rules

### Requirement: Each ignoreDifferences rule SHALL be documented
Each ignoreDifferences entry SHALL include a comment explaining why the field is ignored.

#### Scenario: Rules have rationale comments
- **WHEN** reviewing ArgoCD configuration
- **THEN** each ignoreDifferences rule SHALL have a comment explaining which controller modifies the field