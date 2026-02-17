# Network Policies Reference

This document provides a reference for the Cilium Network Policies used in this cluster.

## Overview

Network policies use a **label-based opt-in model**. Pods opt-in to policies by adding specific labels to their pod template.

## Available Policies

### Egress Policies (Outbound Traffic)

| Policy | Label | Description |
|--------|-------|-------------|
| egress-to-kube-dns | `netpol.cilium.io/egress-to-kube-dns: "true"` | Allow DNS queries to kube-dns |
| egress-to-kube-apiserver | `netpol.cilium.io/egress-to-kube-apiserver: "true"` | Allow Kubernetes API server access |
| egress-to-world | `netpol.cilium.io/egress-to-world: "true"` | Allow all external internet access |
| egress-to-public-ips | `netpol.cilium.io/egress-to-public-ips: "true"` | Allow public IPs (excludes private ranges) |
| egress-to-cloudflare | `netpol.cilium.io/egress-to-cloudflare: "true"` | Allow Cloudflare IP ranges |
| egress-to-host | `netpol.cilium.io/egress-to-host: "true"` | Allow traffic to local node |
| egress-to-intra | `netpol.cilium.io/egress-to-intra: "true"` | Allow intra-namespace traffic |
| egress-deny | `netpol.cilium.io/egress-deny: "true"` | Deny all egress (override) |

### Ingress Policies (Inbound Traffic)

| Policy | Label | Description |
|--------|-------|-------------|
| ingress-from-prometheus | `netpol.cilium.io/ingress-from-prometheus: "true"` | Allow Prometheus scraping |
| ingress-from-ingress | `netpol.cilium.io/ingress-from-ingress: "true"` | Allow Gateway/Ingress traffic |
| ingress-from-host | `netpol.cilium.io/ingress-from-host: "true"` | Allow from host entity |
| ingress-from-intra | `netpol.cilium.io/ingress-from-intra: "true"` | Allow intra-namespace traffic |
| ingress-from-world | `netpol.cilium.io/ingress-from-world: "true"` | Allow all external traffic (debugging) |
| ingress-deny | `netpol.cilium.io/ingress-deny: "true"` | Deny all ingress (override) |

## Common Patterns

### Web Application (External Access)

```yaml
spec:
  template:
    metadata:
      labels:
        app: myapp
        # Required for DNS resolution
        netpol.cilium.io/egress-to-kube-dns: "true"
        # Allow Gateway traffic
        netpol.cilium.io/ingress-from-ingress: "true"
        # Allow Prometheus metrics
        netpol.cilium.io/ingress-from-prometheus: "true"
```

### Database (Internal Only)

```yaml
spec:
  template:
    metadata:
      labels:
        app: database
        # DNS resolution
        netpol.cilium.io/egress-to-kube-dns: "true"
        # Only allow traffic from same namespace
        netpol.cilium.io/ingress-from-intra: "true"
        # Prometheus metrics
        netpol.cilium.io/ingress-from-prometheus: "true"
```

### API Client (External APIs)

```yaml
spec:
  template:
    metadata:
      labels:
        app: api-client
        # DNS resolution
        netpol.cilium.io/egress-to-kube-dns: "true"
        # Access to external APIs
        netpol.cilium.io/egress-to-world: "true"
        # Prometheus metrics
        netpol.cilium.io/ingress-from-prometheus: "true"
```

### Monitoring Component

```yaml
spec:
  template:
    metadata:
      labels:
        app: prometheus
        # DNS resolution
        netpol.cilium.io/egress-to-kube-dns: "true"
        # API server access (for service discovery)
        netpol.cilium.io/egress-to-kube-apiserver: "true"
        # Access to host (node metrics)
        netpol.cilium.io/egress-to-host: "true"
        # Self-metrics
        netpol.cilium.io/ingress-from-prometheus: "true"
```

## Adding Network Policies to Your App

1. **Add labels to your deployment** (see patterns above)

2. **Reference the common policies in kustomization.yaml**:
```yaml
resources:
  - deployment.yaml
  - service.yaml
  - ../../common/cilium-network-policies
```

3. **Apply and verify**:
```bash
kubectl apply -k ./cluster/apps/myapp
kubectl get ciliumnetworkpolicies -n myapp
```

## Troubleshooting

### Check if policy is applied

```bash
kubectl get ciliumnetworkpolicies -A
kubectl describe ciliumnetworkpolicy <name> -n <namespace>
```

### View policy status in Cilium

```bash
cilium policy get
```

### Debug connectivity issues

```bash
# Run a test pod
kubectl run test --image=busybox --rm -it --restart=Never -- nslookup kubernetes

# Check Cilium endpoint status
cilium endpoint list
```

## Policy Priority

Policies are additive. If a pod has multiple egress labels, it can access the union of all allowed destinations.

Deny policies take precedence - if both allow and deny match, deny wins.