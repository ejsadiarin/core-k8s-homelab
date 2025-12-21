🚀 Kubernetes Starter Kit
=========================

Tutorial Video

[![Tutorial Walkthrough Video](https://img.youtube.com/vi/AY5mC5rDUcw/0.jpg)](https://youtu.be/AY5mC5rDUcw)



> Modern GitOps deployment structure using Argo CD on Kubernetes

This starter kit provides a production-ready foundation for deploying applications and infrastructure components using GitOps principles. Compatible with both Raspberry Pi and x86 systems.

## 📋 Table of Contents

- [Prerequisites](#-prerequisites)
- [Architecture](#-architecture)
- [Quick Start](#-quick-start)
  - [System Setup](#1-system-setup)
  - [K3s Installation](#2-k3s-installation)
  - [Networking Setup](#3-networking-setup-cilium)
  - [GitOps Setup](#4-gitops-setup-argo-cd-part-1-of-2)
- [Network & Security](#-network--security)
  - [Dual Gateway Strategy](#dual-gateway-strategy)
  - [Remote Access (Tailscale)](#remote-access-tailscale)
- [Storage](#-storage)
- [Monitoring](#-monitoring)
- [Verification](#-verification)
- [Applications](#-included-applications)
- [Contributing](#-contributing)
- [License](#-license)
- [Troubleshooting](#-troubleshooting)

## 📋 Prerequisites

- Kubernetes cluster (tested with K3s v1.32.0+k3s1)
- Linux host (ARM or x86) with:
  - Storage support (OpenEBS works with ZFS or standard directories)
  - NFS and CIFS support (optional)
  - Open-iSCSI
- Cloudflare account (for DNS and Tunnel)
- Local DNS setup (one of the following):
  - Local DNS server ([AdGuard Home setup guide](docs/adguard-home-setup.md))
  - Router with custom DNS capabilities (e.g., Firewalla)
  - Ability to modify hosts file on all devices

## 🏗️ Architecture

```mermaid
graph TD
    subgraph "Argo CD Projects"
        IP[Infrastructure Project] --> IAS[Infrastructure ApplicationSet]
        AP[Applications Project] --> AAS[Applications ApplicationSet]
        MP[Monitoring Project] --> MAS[Monitoring ApplicationSet]
    end
    
    subgraph "Infrastructure Components"
        IAS --> N[Networking]
        IAS --> S[Storage]
        IAS --> C[Controllers]
        
        N --> Cilium[Cilium CNI]
        N --> Cloudflared[Cloudflare Tunnel]
        N --> Gateway[Cilium Gateway API]
        
        S --> Longhorn[Longhorn (Replicated)]
        S --> LocalPath[Local Path (Simple)]
        
        C --> CertManager
        C --> SealedSecrets
    end
    
    subgraph "Monitoring Stack"
        MAS --> Prometheus
        MAS --> Grafana
        MAS --> AlertManager
        MAS --> NodeExporter
        MAS --> Adapter[Prometheus Adapter]
        MAS --> KSM[kube-state-metrics]
    end
    
    subgraph "User Applications"
        AAS --> P[Privacy Apps]
        AAS --> Web[Web Apps]
        AAS --> Other[Other Apps]
        
        P --> ProxiTok
        P --> SearXNG
        P --> LibReddit
        
        Web --> Nginx
        Web --> Homepage[Homepage Dashboard]
        
        Other --> HelloWorld
    end

    style IP fill:#f9f,stroke:#333,stroke-width:2px
    style AP fill:#f9f,stroke:#333,stroke-width:2px
    style MP fill:#f9f,stroke:#333,stroke-width:2px
    style IAS fill:#bbf,stroke:#333,stroke-width:2px
    style AAS fill:#bbf,stroke:#333,stroke-width:2px
    style MAS fill:#bbf,stroke:#333,stroke-width:2px
```

### Key Features
- **GitOps Structure**: Two-level Argo CD ApplicationSets for infrastructure/apps
- **Security Boundaries**: Separate projects with RBAC enforcement
- **Sync Waves**: Infrastructure deploys first (negative sync waves)
- **Self-Healing**: Automated sync with pruning and failure recovery

## 🚀 Quick Start

> **Note:** For detailed step-by-step instructions, please refer to the [**SETUP_GUIDE.md**](SETUP_GUIDE.md).

1.  **System Setup**: Prepare OS, install dependencies (iSCSI, NFS).
2.  **K3s Installation**: Install K3s with Flannel/Traefik disabled.
3.  **Networking**: Install Cilium CNI.
4.  **GitOps**: Bootstrap Argo CD.
5.  **Secrets**: Manually create Cloudflare/Tunnel secrets.
6.  **Sync**: Apply ApplicationSets to hydrate the cluster.

## 🌐 Network & Security

This cluster uses a **Dual Gateway** architecture to strictly separate public and private traffic.

### Dual Gateway Strategy

| Gateway | Service Name | IP Address | Purpose | Access Method |
| :--- | :--- | :--- | :--- | :--- |
| **External** | `gateway-external` | `192.168.10.201` | Publicly exposed apps | **Internet** via Cloudflare Tunnel<br>**LAN** via Local DNS (`*.ejsadiarin.com`) |
| **Internal** | `gateway-internal` | `192.168.10.202` | Private admin apps | **LAN** via Local DNS<br>**Remote** via Tailscale VPN |

-   **Cloudflare Tunnel:** Connects **only** to `gateway-external`. It cannot reach internal apps.
-   **AdGuard Home:** Rewrites DNS requests on your LAN to point to the correct Gateway IP, bypassing the internet loop.

### Remote Access (Tailscale)

For secure remote access to internal apps (like Longhorn UI, Grafana) without exposing them to the web:

1.  **Tailscale Subnet Router:** The cluster node advertises the Gateway subnet (`192.168.10.200/29`).
2.  **Split DNS:** Tailscale is configured to resolve `*.int.ejsadiarin.com` to the **Internal Gateway IP** (`192.168.10.202`).
3.  **Result:** You can access `https://longhorn.int.ejsadiarin.com` from your phone/laptop anywhere in the world, securely.

See [**docs/tailscale-access.md**](docs/tailscale-access.md) for setup details.

## 🔐 Secrets Management

This cluster uses **Sealed Secrets** for GitOps-friendly secret management.

-   **Problem:** You cannot commit raw Kubernetes Secrets to Git (insecure).
-   **Solution:** `kubeseal` encrypts your Secret into a `SealedSecret` resource. This encrypted resource is safe to commit.
-   **Workflow:**
    1.  Create a standard Secret locally: `kubectl create secret generic my-secret --from-literal=password=123 --dry-run=client -o yaml > secret.yaml`
    2.  Seal it: `kubeseal --controller-name=sealed-secrets --controller-namespace=sealed-secrets -o yaml < secret.yaml > sealed-secret.yaml`
    3.  Commit `sealed-secret.yaml` to Git.
    4.  The controller in the cluster decrypts it back into a standard Secret.

## 💾 Storage

Two storage classes are available:

1.  **Longhorn (`longhorn` - Default):**
    -   **Type:** Replicated Block Storage.
    -   **Features:** Snapshots, S3 Backups, High Availability.
    -   **Use for:** Databases, persistent config, anything needing backup.
2.  **Local Path (`local-path`):**
    -   **Type:** HostPath wrapper.
    -   **Features:** Simple, Fast, Zero-overhead.
    -   **Use for:** Caches, temporary data, logs (if persistence isn't critical).

## 📊 Monitoring

Full observability stack provided by `kube-prometheus-stack`:

-   **Prometheus:** Metric collection.
-   **Grafana:** Dashboards (Auto-provisioned from Git).
-   **Prometheus Adapter:** Enables `kubectl top` and Horizontal Pod Autoscaling (HPA) by translating Prometheus metrics to Kubernetes API.

## 🔍 Verification
```bash
# Cluster status
kubectl get pods -A --sort-by=.metadata.creationTimestamp

# Argo CD status
kubectl get applications -n argocd -o wide

# Monitoring stack status
kubectl get pods -n kube-prometheus-stack

# Certificate checks
kubectl get certificates -A
kubectl describe clusterissuer cloudflare-cluster-issuer

# Network validation
cilium status --verbose
cilium connectivity test --all-flows
```

**Access Endpoints:**
- **Homepage:** `https://homepage.ejsadiarin.com` (Start Here!)
- **Grafana:** `https://grafana.int.ejsadiarin.com` (Internal)
- **Argo CD:** `https://argocd.int.ejsadiarin.com` (Internal)
- **Longhorn:** `https://longhorn.int.ejsadiarin.com` (Internal)

## 📦 Included Applications

| Category       | Components                          |
|----------------|-------------------------------------|
| **Dashboard**  | Homepage                            |
| **Monitoring** | Prometheus, Grafana, Loki, Promtail, Adapter |
| **Privacy**    | ProxiTok, SearXNG, LibReddit        |
| **Infra**      | Cilium, Gateway API, Cloudflared    |
| **Storage**    | Longhorn, Local-Path                |
| **Security**   | cert-manager, Argo CD Projects      |

## 🤝 Contributing
Contributions welcome! Please:
1. Maintain existing comment structure
2. Keep all warnings/security notes
3. Open issue before major changes

## 📝 License
MIT License - Full text in [LICENSE](LICENSE)

## 🔧 Troubleshooting

See [**20251220-troubleshooting-log.md**](20251220-troubleshooting-log.md) for a history of issues and solutions encountered during setup.

**Common Commands:**
```bash
# Force Sync an Application
kubectl patch application <app-name> -n argocd --type merge -p '{"operation": {"sync": {"prune": true}}}'

# Check Disk Pressure
kubectl describe node <node-name> | grep Pressure

# Restart Cloudflare Tunnel
kubectl rollout restart daemonset cloudflared -n cloudflared
```