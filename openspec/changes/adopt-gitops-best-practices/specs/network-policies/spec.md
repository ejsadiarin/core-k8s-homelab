## ADDED Requirements

### Requirement: Network policies SHALL be defined in a shared common directory
The system SHALL provide reusable Cilium Network Policy definitions in `cluster/common/cilium-network-policies/` that can be referenced by any application.

#### Scenario: Network policy directory exists
- **WHEN** the cluster infrastructure is deployed
- **THEN** the directory `cluster/common/cilium-network-policies/` SHALL exist with at least 15 network policy files

### Requirement: Network policies SHALL use label-based opt-in model
Applications SHALL opt-in to network policies by adding specific labels to their pod templates, not by modifying the policy definitions.

#### Scenario: Application opts in to DNS egress
- **WHEN** a deployment includes label `netpol.cilium.io/egress-to-kube-dns: "true"`
- **THEN** pods from that deployment SHALL be allowed to make DNS queries to kube-dns

#### Scenario: Application opts in to API server access
- **WHEN** a deployment includes label `netpol.cilium.io/egress-to-kube-apiserver: "true"`
- **THEN** pods from that deployment SHALL be allowed to connect to the Kubernetes API server

### Requirement: Egress policies SHALL cover essential cluster services
The system SHALL provide egress policies for: kube-dns, kube-apiserver, prometheus, ingress gateway, host, intra-namespace, and world access.

#### Scenario: Egress to DNS is configured
- **WHEN** a pod has the DNS egress label
- **THEN** the pod SHALL be able to resolve DNS queries via kube-dns on port 53 UDP

#### Scenario: Egress to world is controlled
- **WHEN** a pod has `netpol.cilium.io/egress-to-world: "true"`
- **THEN** the pod SHALL be able to make outbound connections to external IPs

### Requirement: Ingress policies SHALL cover common traffic sources
The system SHALL provide ingress policies for: prometheus scraping, ingress gateway, intra-namespace, host, and world access.

#### Scenario: Prometheus can scrape metrics
- **WHEN** a deployment includes label `netpol.cilium.io/ingress-from-prometheus: "true"`
- **THEN** Prometheus pods SHALL be able to scrape metrics from that deployment

#### Scenario: Ingress gateway can route traffic
- **WHEN** a deployment includes label `netpol.cilium.io/ingress-from-ingress: "true"`
- **THEN** the Cilium gateway SHALL be able to route HTTP traffic to that deployment

### Requirement: Applications SHALL reference common network policies in kustomization
Each application's kustomization.yaml SHALL include a reference to the common network policies directory.

#### Scenario: Application kustomization includes network policies
- **WHEN** an application kustomization is processed
- **THEN** it SHALL include `../../../common/cilium-network-policies/` (or appropriate relative path) in its resources