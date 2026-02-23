## ADDED Requirements

### Requirement: Grafana SHALL have an ArgoCD dashboard
The system SHALL provide a Grafana dashboard ConfigMap for ArgoCD observability.

#### Scenario: ArgoCD dashboard is available
- **WHEN** a user accesses Grafana
- **THEN** a dashboard named "ArgoCD" SHALL be available showing:
  - Application count and sync status
  - Health status distribution
  - Reconciliation activity
  - Controller stats (memory, CPU, goroutines)

### Requirement: Grafana SHALL have a Longhorn dashboard
The system SHALL provide a Grafana dashboard ConfigMap for Longhorn storage observability.

#### Scenario: Longhorn dashboard is available
- **WHEN** a user accesses Grafana
- **THEN** a dashboard named "Longhorn" SHALL be available showing:
  - Volume count and health status
  - Node storage usage
  - Volume capacity and actual size
  - Disk usage per node

### Requirement: Grafana SHALL have a Cilium dashboard
The system SHALL provide Grafana dashboard ConfigMaps for Cilium and Hubble observability.

#### Scenario: Cilium dashboard is available
- **WHEN** a user accesses Grafana
- **THEN** dashboards for Cilium and Hubble SHALL be available showing:
  - Cilium agent metrics
  - Hubble network flow visibility
  - Policy hit counts

### Requirement: Dashboard ConfigMaps SHALL have discovery labels
All dashboard ConfigMaps SHALL have labels that match Grafana's dashboard sidecar discovery.

#### Scenario: Dashboards are auto-discovered
- **WHEN** Grafana starts or ConfigMaps change
- **THEN** dashboards SHALL be imported automatically via labels:
  - `grafana_dashboard: "1"`

### Requirement: Dashboards SHALL be stored in monitoring directory
Dashboard ConfigMaps SHALL be stored in `cluster/monitoring/kube-prometheus-stack/dashboards/`.

#### Scenario: Dashboards are in correct location
- **WHEN** the monitoring stack is deployed
- **THEN** dashboard ConfigMaps SHALL be applied from the dashboards directory