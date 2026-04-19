## ADDED Requirements

### Requirement: Cloudflared deployment has Reloader annotation

The cloudflared deployment SHALL include the Reloader annotation to automatically restart pods when secrets change.

#### Scenario: Reloader annotation is configured
- **WHEN** the Deployment manifest is applied
- **THEN** annotation `reloader.stakater.com/auto` is set to `"true"`
- **AND** pods are automatically restarted when `tunnel-credentials` secret changes

### Requirement: Cloudflared pods have network policy labels

The cloudflared pod template SHALL include labels for common network policy integration.

#### Scenario: Pod labels for egress policies exist
- **WHEN** the Deployment manifest is applied
- **THEN** pod template includes label `netpol.cilium.io/egress-to-cloudflare: "true"`
- **AND** pod template includes label `netpol.cilium.io/egress-to-kube-dns: "true"`

### Requirement: Cloudflared supports ICMP proxy via sysctl

The cloudflared pod SHALL have sysctl configured to enable ICMP proxy functionality.

#### Scenario: ICMP sysctl is configured
- **WHEN** the cloudflared pod starts
- **THEN** `net.ipv4.ping_group_range` is set to `"65532 65532"`
- **AND** the cloudflared process can send ICMP packets for health checks

### Requirement: Config volume is mounted read-only

The cloudflared container SHALL mount the config volume as read-only for defense in depth.

#### Scenario: Config volume is read-only
- **WHEN** the Deployment manifest is applied
- **THEN** the config volumeMount has `readOnly: true`

### Requirement: Configuration has no duplicate headers

The cloudflared config.yaml SHALL not contain duplicate header entries.

#### Scenario: Headers are unique
- **WHEN** the ConfigMap is generated from config.yaml
- **THEN** each header name appears exactly once in the headers list
- **AND** no duplicate `CF-IPCountry` or `CF-Ray` entries exist

## MODIFIED Requirements

### Requirement: Cloudflared has resource limits defined

The cloudflared container SHALL have CPU and memory requests and limits defined to prevent resource contention, optimized for actual usage patterns.

#### Scenario: Resource requests configured
- **WHEN** the Deployment manifest is applied
- **THEN** `resources.requests.cpu` is set to 50m (reduced from 100m)
- **AND** `resources.requests.memory` is set to 64Mi

#### Scenario: Resource limits configured
- **WHEN** the Deployment manifest is applied
- **THEN** `resources.limits.cpu` is set to 200m (reduced from 500m)
- **AND** `resources.limits.memory` is set to 256Mi
