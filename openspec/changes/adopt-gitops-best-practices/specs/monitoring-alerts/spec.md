## ADDED Requirements

### Requirement: Prometheus SHALL have custom Kubernetes alert rules
The system SHALL provide PrometheusRule resources for Kubernetes cluster health monitoring.

#### Scenario: Node not ready alert exists
- **WHEN** a Kubernetes node is not ready for 5 minutes
- **THEN** an alert `KubernetesNodeNotReady` with severity `critical` SHALL fire

#### Scenario: Pod crash looping alert exists
- **WHEN** a pod is restarting more than 0 times per 15 minutes
- **THEN** an alert `KubernetesPodCrashLooping` with severity `warning` SHALL fire

#### Scenario: High memory usage alert exists
- **WHEN** a node's memory usage exceeds 85% for 5 minutes
- **THEN** an alert `NodeMemoryHighUsage` with severity `warning` SHALL fire

#### Scenario: High CPU usage alert exists
- **WHEN** a node's CPU usage exceeds 90% for 10 minutes
- **THEN** an alert `NodeCPUHighUsage` with severity `warning` SHALL fire

### Requirement: Prometheus SHALL have custom storage alert rules
The system SHALL provide PrometheusRule resources for Longhorn storage monitoring.

#### Scenario: Longhorn node down alert exists
- **WHEN** a Longhorn node is offline for 10 minutes
- **THEN** an alert `LonghornNodeDown` with severity `critical` SHALL fire

#### Scenario: Longhorn volume unhealthy alert exists
- **WHEN** a Longhorn volume's robustness is not healthy (1)
- **THEN** an alert `LonghornVolumeUnhealthy` with severity `critical` SHALL fire

#### Scenario: Longhorn storage space low alert exists
- **WHEN** a Longhorn node's storage usage exceeds 90%
- **THEN** an alert `LonghornNodeStorageSpaceLow` with severity `warning` SHALL fire

### Requirement: Prometheus SHALL have application alert rules
The system SHALL provide PrometheusRule resources for application-level monitoring.

#### Scenario: ArgoCD sync failure alert exists
- **WHEN** an ArgoCD application sync fails
- **THEN** an appropriate alert SHALL fire with details about the failed sync

### Requirement: Alert rules SHALL be labeled for Prometheus discovery
All PrometheusRule resources SHALL have labels that match Prometheus's rule selector.

#### Scenario: Alert rules are discovered by Prometheus
- **WHEN** Prometheus scrapes for rules
- **THEN** custom rules SHALL be discovered via labels:
  - `prometheus: kube-prometheus-stack-prometheus`
  - `role: alert-rules`

### Requirement: Alert rules SHALL be referenced in monitoring kustomization
The kube-prometheus-stack kustomization.yaml SHALL include the alerts directory as a resource.

#### Scenario: Alerts are included in deployment
- **WHEN** the monitoring stack is deployed
- **THEN** all alert rule files SHALL be applied to the cluster