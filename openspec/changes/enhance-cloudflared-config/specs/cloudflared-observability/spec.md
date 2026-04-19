## ADDED Requirements

### Requirement: Cloudflared exposes metrics endpoint via Service

The cloudflared deployment SHALL expose its metrics endpoint through a Kubernetes Service for Prometheus scraping.

#### Scenario: Metrics Service exists
- **WHEN** the cloudflared manifests are applied
- **THEN** a Service named `cloudflared-metrics` exists in the cloudflared namespace
- **AND** the Service targets pods with label `app: cloudflared`
- **AND** the Service exposes port 2000 (metrics)

#### Scenario: Metrics endpoint is scrapeable
- **WHEN** Prometheus scrapes the cloudflared-metrics Service
- **THEN** metrics are returned on port 2000 at `/metrics`
- **AND** the tunnel connection status is visible in metrics

### Requirement: Cloudflared has explicit network egress policy

The cloudflared deployment SHALL have a CiliumNetworkPolicy that explicitly defines allowed egress destinations for security compliance.

#### Scenario: Network policy allows gateway egress
- **WHEN** the CiliumNetworkPolicy is applied
- **THEN** egress to the Gateway service on port 443 is allowed
- **AND** egress to Cloudflare edge servers is allowed

#### Scenario: Network policy allows DNS resolution
- **WHEN** the cloudflared pod needs to resolve DNS
- **THEN** egress to kube-dns on port 53 is allowed
