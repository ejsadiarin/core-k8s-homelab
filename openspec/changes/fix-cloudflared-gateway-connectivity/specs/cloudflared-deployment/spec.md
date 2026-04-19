## MODIFIED Requirements

### Requirement: Cloudflared runs as Deployment with single replica

The cloudflared tunnel SHALL run as a Kubernetes Deployment with exactly 1 replica, rather than a DaemonSet, to optimize resource usage for single-tunnel scenarios. The tunnel SHALL connect to the Cilium Gateway via HTTP (port 80) instead of HTTPS (port 443).

#### Scenario: Deployment instead of DaemonSet
- **WHEN** the cloudflared manifest is applied to the cluster
- **THEN** a Deployment resource is created with `replicas: 1`
- **AND** no DaemonSet resource exists for cloudflared

#### Scenario: Tunnel remains connected after conversion
- **WHEN** the Deployment is created after removing DaemonSet
- **THEN** the cloudflared pod connects to Cloudflare edge within 30 seconds
- **AND** the tunnel status shows "Connected" in Cloudflare dashboard

#### Scenario: Tunnel proxies via HTTP to gateway
- **WHEN** cloudflared receives a request from Cloudflare edge
- **THEN** it forwards the request to the Cilium Gateway on HTTP port 80
- **AND** the Host header from the original request is preserved
