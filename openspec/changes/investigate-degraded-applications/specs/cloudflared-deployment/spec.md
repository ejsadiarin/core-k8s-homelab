## ADDED Requirements

### Requirement: Cloudflared runs as Deployment with single replica

The cloudflared tunnel SHALL run as a Kubernetes Deployment with exactly 1 replica, rather than a DaemonSet, to optimize resource usage for single-tunnel scenarios.

#### Scenario: Deployment instead of DaemonSet
- **WHEN** the cloudflared manifest is applied to the cluster
- **THEN** a Deployment resource is created with `replicas: 1`
- **AND** no DaemonSet resource exists for cloudflared

#### Scenario: Tunnel remains connected after conversion
- **WHEN** the Deployment is created after removing DaemonSet
- **THEN** the cloudflared pod connects to Cloudflare edge within 30 seconds
- **AND** the tunnel status shows "Connected" in Cloudflare dashboard

### Requirement: Cloudflared runs with security hardening

The cloudflared container SHALL run with restricted security context following Pod Security Standards "Restricted" profile.

#### Scenario: Pod runs as non-root user
- **WHEN** the cloudflared pod starts
- **THEN** the container runs as user 65532 (non-root)
- **AND** `runAsNonRoot` is set to `true`

#### Scenario: Read-only root filesystem
- **WHEN** the cloudflared container runs
- **THEN** `readOnlyRootFilesystem` is set to `true`
- **AND** `/tmp` is mounted as emptyDir for temporary files

#### Scenario: Capabilities dropped
- **WHEN** the container security context is evaluated
- **THEN** all Linux capabilities are dropped (`capabilities.drop: [ALL]`)
- **AND** `allowPrivilegeEscalation` is set to `false`

### Requirement: Cloudflared has resource limits defined

The cloudflared container SHALL have CPU and memory requests and limits defined to prevent resource contention.

#### Scenario: Resource requests configured
- **WHEN** the Deployment manifest is applied
- **THEN** `resources.requests.cpu` is set to at most 100m
- **AND** `resources.requests.memory` is set to at most 64Mi

#### Scenario: Resource limits configured
- **WHEN** the Deployment manifest is applied
- **THEN** `resources.limits.cpu` is set to at most 500m
- **AND** `resources.limits.memory` is set to at most 256Mi
