## ADDED Requirements

### Requirement: Cloudflared connects to Cilium Gateway via HTTP

Cloudflared SHALL connect to the Cilium Gateway service over HTTP (port 80) for proxying tunnel traffic to backend services. HTTPS with SNI-based routing is incompatible because cloudflared's `originServerName` is static and cannot send per-request SNI matching the actual hostname.

#### Scenario: Wildcard ingress rule uses HTTP
- **WHEN** cloudflared processes a request for any `*.ejsadiarin.com` hostname
- **THEN** it forwards the request to `http://cilium-gateway-gateway-external.gateway.svc.cluster.local:80`
- **AND** the Host header is preserved for gateway routing

#### Scenario: Root domain ingress rule uses HTTP
- **WHEN** cloudflared processes a request for `ejsadiarin.com`
- **THEN** it forwards the request to `http://cilium-gateway-gateway-external.gateway.svc.cluster.local:80`
- **AND** no TLS negotiation occurs between cloudflared and the gateway

#### Scenario: No TLS origin configuration present
- **WHEN** the cloudflared config is evaluated
- **THEN** no `noTLSVerify` field is present in any ingress rule's `originRequest`
- **AND** no `originServerName` field is present in any ingress rule's `originRequest`

### Requirement: CiliumNetworkPolicy allows cloudflared egress to gateway on HTTP

The CiliumNetworkPolicy for cloudflared SHALL allow egress to the gateway service on port 80 (HTTP) instead of port 443 (HTTPS).

#### Scenario: Egress to gateway on port 80
- **WHEN** cloudflared sends traffic to `cilium-gateway-gateway-external` service
- **THEN** the CiliumNetworkPolicy permits TCP traffic on port 80
- **AND** TCP traffic on port 443 to the gateway is not explicitly allowed

### Requirement: HTTPRoutes bind to all gateway listeners

All HTTPRoutes SHALL omit `sectionName` from their `parentRefs` so they bind to both HTTP and HTTPS listeners on the gateway. This ensures routes are accessible regardless of which port the client connects to.

#### Scenario: External HTTPRoute binds to both listeners
- **WHEN** an HTTPRoute with `parentRef` to `gateway-external` is applied
- **THEN** the route does not specify `sectionName`
- **AND** the route is available on both the HTTP (port 80) and HTTPS (port 443) gateway listeners

#### Scenario: Internal HTTPRoute binds to both listeners
- **WHEN** an HTTPRoute with `parentRef` to `gateway-internal` is applied
- **THEN** the route does not specify `sectionName`
- **AND** the route is available on both gateway listeners

#### Scenario: Gateway returns 200 for valid Host on HTTP
- **WHEN** a request is sent to the gateway on port 80 with a valid Host header
- **THEN** the gateway routes the request to the matching backend service
- **AND** returns the backend's response (not 404 or connection reset)
