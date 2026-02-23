## ADDED Requirements

### Requirement: Monitoring ApplicationSet ignores Prometheus CRD status
The monitoring ApplicationSet SHALL ignore differences in Prometheus, Alertmanager, PrometheusRule, and ServiceMonitor status fields.

#### Scenario: Prometheus operator updates CRD status
- **WHEN** Prometheus operator updates monitoring CRD statuses
- **THEN** ArgoCD SHALL NOT mark the application as OutOfSync

### Requirement: Monitoring ApplicationSet ignores ServiceMonitor endpoints
The monitoring ApplicationSet SHALL ignore differences in ServiceMonitor spec.endpoints fields.

#### Scenario: Prometheus operator modifies ServiceMonitor endpoints
- **WHEN** Prometheus operator modifies ServiceMonitor endpoint configurations
- **THEN** ArgoCD SHALL NOT mark the application as OutOfSync

### Requirement: Monitoring ApplicationSet ignores generated Secret data
The monitoring ApplicationSet SHALL ignore differences in Secret data fields for generated certificates and tokens.

#### Scenario: Monitoring stack generates TLS certificates
- **WHEN** Monitoring components generate or rotate TLS certificates in Secrets
- **THEN** ArgoCD SHALL NOT mark the application as OutOfSync

### Requirement: Monitoring ApplicationSet ignores HTTPRoute status
The monitoring ApplicationSet SHALL ignore differences in HTTPRoute status fields for Grafana and Prometheus ingress routes.

#### Scenario: Cilium Gateway populates monitoring HTTPRoute status
- **WHEN** Cilium Gateway controller populates HTTPRoute status for monitoring UIs
- **THEN** ArgoCD SHALL NOT mark the application as OutOfSync
