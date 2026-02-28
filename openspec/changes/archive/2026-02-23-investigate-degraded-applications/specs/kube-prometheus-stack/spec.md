## ADDED Requirements

### Requirement: Grafana pods run without crash loops

The Grafana deployment in kube-prometheus-stack SHALL run without crashing or failing health probes.

#### Scenario: Grafana pod starts successfully
- **WHEN** the Grafana deployment is applied
- **THEN** the pod reaches `Ready` state within 120 seconds
- **AND** the pod does not restart due to probe failures

#### Scenario: Liveness probe succeeds
- **WHEN** the Grafana container is running
- **THEN** the liveness probe returns HTTP 200
- **AND** the probe timeout is sufficient for startup (at least 30 seconds)

#### Scenario: Readiness probe succeeds
- **WHEN** the Grafana container is ready to serve traffic
- **THEN** the readiness probe returns HTTP 200
- **AND** Grafana UI is accessible at the configured route

### Requirement: Grafana has sufficient resources

The Grafana container SHALL have sufficient CPU and memory resources to start and run without being OOMKilled or CPU throttled.

#### Scenario: Memory limits sufficient for dashboards
- **WHEN** Grafana loads multiple dashboards
- **THEN** memory usage stays within limits
- **AND** no OOMKilled events occur

#### Scenario: Startup completes within probe initial delay
- **WHEN** Grafana pod starts
- **THEN** the container starts within the `initialDelaySeconds` of probes
- **AND** no probe failures occur during normal startup
