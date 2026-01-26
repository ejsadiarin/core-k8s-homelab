# Kubernetes Homelab Infrastructure Analysis

## 1. Overall Architecture

**Directory Structure Philosophy**

```txt
cluster/
├── infrastructure/ # Core platform components (sync-wave: -2)
│ ├── networking/ # CNI, Gateways, Tunnels
│ ├── storage/ # Longhorn, Local-Path, CSI drivers
│ └── controllers/ # ArgoCD, Cert-Manager, Sealed Secrets
├── apps/ # User applications (sync-wave: 1)
│ ├── glance/
│ ├── hello-world/
│ ├── homepage-dashboard/
│ ├── it-tools/
│ └── nginx/
├── monitoring/ # Observability stack (sync-wave: 0)
│ ├── kube-prometheus-stack/
│ └── prometheus-adapter/
├── deprecated/ # Archived/disabled apps
└── docs/ # Setup guides
```

**Key Architectural Principles:**

- **GitOps-First**: Everything is declarative in Git; ArgoCD syncs desired state
- **Three-Tier Separation**: Infrastructure, Monitoring, and Applications are isolated via ArgoCD Projects with RBAC
- **Sync Waves**: Infrastructure deploys first (wave -2), then Monitoring (wave 0), then Apps (wave 1)
- **Kustomize + Helm**: Uses Kustomize for resource composition with HelmChart inflators for external charts

---

## 2. Infrastructure Components (`cluster/infrastructure/`)

### **Networking Setup**

**Cilium CNI (`/infrastructure/networking/cilium/`)**

- **Role**: Replaces k3s default Flannel; provides advanced networking
- **Features Enabled**:
    - _kubeProxyReplacement_: true - Cilium acts as kube-proxy
    - _gatewayAPI.enabled_: true - Native Gateway API support
    - _l2announcements.enabled_: true - L2 load balancer announcements
    - _hubble.enabled_: true - Network observability UI
    - Maglev consistent hashing for load balancing
- **IP Pool**: 192.168.10.200/29 (usable IPs: .201 to .206)
- **L2 Policy**: Announces on all common network interfaces (eth*, enp*, ens*, wlan*, wlp\*)

### Gateway Configuration (`/infrastructure/networking/gateway/`)

- **Dual Gateway Strategy**:
  | Gateway | Hostname Pattern | Purpose |
  |---------|------------------|---------|
  | gateway-external | _.ejsadiarin.com | Public-facing apps via Cloudflare Tunnel |
  | gateway-internal | _.int.ejsadiarin.com | Private apps via Tailscale VPN only |
- **GatewayClass**: Uses Cilium's `io.cilium/gateway-controller`
- **TLS**: Wildcard certificate for both `*.ejsadiarin.com` and `*.int.ejsadiarin.com` managed by cert-manager

### Cloudflared Tunnel (`/infrastructure/networking/cloudflared/`)

- **Deployment Type**: DaemonSet
- **Configuration**:
    - Tunnel name: k3s-homelab-tunnel
    - Routes \*.ejsadiarin.com traffic to gateway-external service
    - Passes through Cloudflare headers (CF-Connecting-IP, CF-Ray, bot detection, etc.)
    - Security: Only connects to external gateway; internal apps are unreachable from internet

### Storage Solutions

#### Longhorn (`/infrastructure/storage/longhorn/`) - Default Storage Class

- **Type**: Replicated block storage with snapshots/backups
- **Configuration Optimizations (for 1-node cluster)**:
    - _defaultClassReplicaCount_: 1 - No data replication (single node)
    - _defaultDataLocality_: best-effort
    - Reduced resource limits (200m CPU, 256Mi memory)
- **Use Cases**: Databases, persistent configs, anything needing backup
- **UI Access**: `longhorn.int.ejsadiarin.com` (internal only)

#### Local-Path Provisioner (`/infrastructure/storage/local-path-provisioner/`)

- **Type**: Simple hostPath wrapper
- **Storage Path**: `/opt/local-path-provisioner`
- **VolumeBindingMode**: WaitForFirstConsumer
- **Use Cases**: Caches, temporary data, non-critical logs

#### CSI Drivers (Excluded from current deployment)

- `csi-driver-nfs` and `csi-driver-smb` are present but explicitly excluded in the ApplicationSet

---

### Controllers

#### ArgoCD (`/infrastructure/controllers/argocd/`)

- Manages all GitOps deployments
- **Three isolated Projects with RBAC**:
    - `infrastructure` - Core platform components
    - `applications` - User workloads
    - `monitoring` - Observability stack
- Uses custom `kustomize-build-with-helm` plugin

### Cert-Manager (`/infrastructure/controllers/cert-manager/`)

- **ClusterIssuer**: cloudflare-cluster-issuer using Let's Encrypt ACME
- **DNS01 Challenge**: Cloudflare API for wildcard certificates
- **Sync Wave**: -10 (deploys very early)

### Sealed Secrets (/infrastructure/controllers/sealed-secrets/)

- Encrypts secrets for safe Git storage
- Controller decrypts SealedSecrets into native Secrets in-cluster

### Deployment via ApplicationSet

**File**: _infrastructure-components-appset.yaml_

```yaml
generators:
    - git:
          directories:
              - path: cluster/infrastructure/networking/*
              - path: cluster/infrastructure/storage/*
              - path: cluster/infrastructure/controllers/*
              - exclude: true
                path: cluster/infrastructure/storage/csi-driver-nfs
              - exclude: true
                path: cluster/infrastructure/storage/csi-driver-smb
```

- **Pattern**: Each subdirectory becomes an ArgoCD Application
- **Naming**: Application name = {{path.basename}}
- **Namespace**: Created automatically; matches directory name
- **Sync Policy**: Automated with prune, self-heal, retry (5 attempts)

---

## 3. Applications (`cluster/apps/`)

### Deployed Applications

| Application        | Purpose              | Gateway  | Domain                      |
| ------------------ | -------------------- | -------- | --------------------------- |
| glance             | Dashboard/Start page | External | glance.ejsadiarin.com       |
| hello-world        | Test application     | External | hello-world.ejsadiarin.com  |
| homepage-dashboard | Service dashboard    | Internal | homepage.int.ejsadiarin.com |
| it-tools           | Developer utilities  | -        | -                           |
| nginx              | Example web server   | External | nginx.ejsadiarin.com        |

### Application Structure Pattern

**Each application follows a consistent Kustomize pattern**:

```
<app-name>/
├── kustomization.yaml # Resource aggregation + configMapGenerator
├── namespace.yaml # Dedicated namespace
├── deployment.yaml # Workload definition
├── service.yaml # ClusterIP or LoadBalancer service
├── httproute.yaml # Gateway API routing
└── pvc.yaml (optional) # Persistent storage
```

#### Example - nginx application:

- **Namespace**: `nginx`
- **Storage**: PVC using storage class
- **Service**: LoadBalancer with Cilium L2 IP assignment (`192.168.70.105`)
- **Routing**: HTTPRoute to gateway-external with hostname `nginx.ejsadiarin.com`
  `myapplications-appset.yaml`
    ```yaml
    generators:
        - git:
              directories:
                  - path: cluster/apps/*
                  - exclude: true
                    path: cluster/apps/myapplications-appset.yaml
    ```
- **Pattern**: Git directory generator scans cluster/apps/\*
- **Automation**: Adding a new folder to cluster/apps/ automatically creates an ArgoCD Application
- **Project Assignment**: All apps belong to applications project
- **Sync Wave**: 1 (deploys after infrastructure)

---

## 4.. Monitoring (`cluster/monitoring/`)

### Components

**kube-prometheus-stack (Full observability suite)**

- **Prometheus**: Metric collection (7-day retention, 10Gi storage on Longhorn)
- **Grafana**: Dashboards (1Gi persistent storage, auto-provisioned dashboards)
- **AlertManager**: Alert handling (512Mi storage)
- **Node Exporter**: Host metrics (disabled nfsd collector for stability)
- **kube-state-metrics**: Kubernetes object metrics

**Access**:

- **Grafana**: _grafana.int.ejsadiarin.com_ (Internal)
- **Prometheus**: _prometheus.int.ejsadiarin.com_ (Internal)

##### Prometheus Adapter

- Enables kubectl top commands
- Provides Custom Metrics API for Horizontal Pod Autoscaling (HPA)
- **Sync Wave** 2 (after Prometheus is ready)

#### Configuration Highlights

- Recreate deployment strategy for Grafana to avoid PVC multi-attach errors
- Reduced scrape intervals (30s) with 10s timeouts
- Dashboard auto-discovery via ConfigMap sidecar with label _grafana_dashboard: "1"_

---

## 5. Deployment Strategy

### GitOps Workflow

1. Make Changes: Modify YAML manifests in Git
2. Commit & Push: Push to cluster branch
3. ArgoCD Detects: Watches repository for changes
4. Reconcile: Syncs desired state to cluster
5. Self-Heal: Automatically corrects drift

### Sync Wave Ordering

| Wave | Components                                 |
| ---- | ------------------------------------------ |
| -10  | cert-manager                               |
| -2   | Infrastructure (Cilium, Gateways, Storage) |
| -1   | Cloudflared                                |
| 0    | Monitoring (kube-prometheus-stack)         |
| 1    | User Applications                          |
| 2    | Prometheus Adapter                         |

### Kustomize Strategy

- **HelmCharts Inflator**: Kustomize native Helm support (no Flux required)
- **ConfigMapGenerator**: Dynamic config generation (e.g., glance, homepage)
- **commonAnnotations**: Bulk annotation application
- **Patches**: API version fixes, resource modifications

### ArgoCD Sync Options

```yaml
syncOptions:
    - CreateNamespace=true # Auto-create namespaces
    - ServerSideApply=true # Use SSA for large CRDs
    - RespectIgnoreDifferences=true
    - ApplyOutOfSyncOnly=true # Only sync changed resources
    - Replace=false # Prefer patch over replace
```

---

## 6. Networking Details

### Gateway API Usage

**GatewayClass: cilium (`controller: io.cilium/gateway-controller`)**

### Two Gateway Resources:

1. _gateway-external (192.168.10.201)_
    - Listens on ports 80 (HTTP) and 443 (HTTPS)
      **- Hostname**: `*.ejsadiarin.com`
      **- Routes**: All namespaces allowed
    - Connected via Cloudflare Tunnel for internet access

2. _gateway-internal (192.168.10.202)_
    - Listens on ports 80 (HTTP) and 443 (HTTPS)
      **- Hostname**: `*.int.ejsadiarin.com`
      **- Routes**: All namespaces allowed
    - Accessible only via Tailscale VPN or LAN

#### HTTPRoute Pattern

Applications define routing via HTTPRoute resources:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
spec:
    parentRefs:
        - name: gateway-external # or gateway-internal
          namespace: gateway
          sectionName: https # TLS listener
    hostnames:
        - "app.ejsadiarin.com"
    rules:
        - matches:
              - path:
                    type: PathPrefix
                    value: /
          backendRefs:
              - name: service-name
                port: 80
```

### Cloudflare Tunnel Flow

```txt
Internet Request
      │
      ▼
Cloudflare Edge (CDN/WAF)
      │
      ▼
Cloudflared Tunnel (in-cluster DaemonSet)
      │
      ▼
cilium-gateway-gateway-external.gateway.svc.cluster.local:443
      │
      ▼
HTTPRoute → Backend Service → Pod
```

3. **Subnet Router**: NUC advertises `192.168.10.200/29` to Tailnet
4. **Split DNS**: Tailscale resolves `*.int.ejsadiarin.com` via AdGuard on NUC
5. **Traffic Flow**: _Device → Tailscale VPN → NUC → gateway-internal → Internal Apps_

---

### 7. Storage Strategy

**Available Storage Classes**

| Storage Class | Provisioner           | Default | Use Case                 |
| ------------- | --------------------- | ------- | ------------------------ |
| longhorn      | Longhorn              | Yes     | Databases, critical data |
| local-path    | rancher.io/local-path | No      | Caches, temp data        |

### Persistent Storage Handling

**Longhorn Volumes**:

- **Default replica count**: 1 (single node setup)
- **Default path**: /var/lib/longhorn
- **ReclaimPolicy**: Delete
- Supports snapshots and S3 backups (configurable)

**Local-Path Volumes**:

- **Default path**: /opt/local-path-provisioner
- **VolumeBindingMode**: WaitForFirstConsumer
- **ReclaimPolicy**: Delete

#### PVC Usage Examples

**Monitoring (Longhorn)**:

- Prometheus: 10Gi
- Grafana: 1Gi
- AlertManager: 512Mi

**Applications**:

- nginx: Uses PVC (storage class from default)
- hello-world: Uses PVC

---

## Summary: How It All Works Together

```txt
┌─────────────────────────────────────────────────────────────────────────────┐
│                              GITOPS LAYER                                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │
│  │  Infrastructure │  │   Monitoring    │  │  Applications   │             │
│  │   AppSet (-2)   │  │   AppSet (0)    │  │   AppSet (1)    │             │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘             │
│           │                    │                    │                       │
│           ▼                    ▼                    ▼                       │
│         ArgoCD (watches GitHub repo, reconciles cluster state)              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           KUBERNETES CLUSTER                                │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ NETWORKING (Cilium)                                                  │   │
│  │  ├─ CNI + kube-proxy replacement                                    │   │
│  │  ├─ Gateway API controller                                          │   │
│  │  ├─ L2 Load Balancer (IP Pool: 192.168.10.200/29)                  │   │
│  │  └─ Hubble (observability)                                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ GATEWAYS                                                             │   │
│  │  ├─ gateway-external (.201) ── Cloudflared ── Internet              │   │
│  │  └─ gateway-internal (.202) ── Tailscale VPN ── Remote Access       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ STORAGE                                                              │   │
│  │  ├─ Longhorn (default) ── Replicated block storage                  │   │
│  │  └─ Local-Path ── Simple hostPath                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ SECURITY                                                             │   │
│  │  ├─ Cert-Manager ── TLS certificates via Cloudflare DNS-01          │   │
│  │  └─ Sealed Secrets ── Encrypted secrets in Git                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ MONITORING                                                           │   │
│  │  ├─ Prometheus ── Metrics                                           │   │
│  │  ├─ Grafana ── Dashboards                                           │   │
│  │  ├─ AlertManager ── Alerts                                          │   │
│  │  └─ Prometheus Adapter ── HPA/kubectl top                           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ APPLICATIONS                                                         │   │
│  │  ├─ glance, nginx, hello-world ── External (*.ejsadiarin.com)       │   │
│  │  └─ homepage-dashboard, longhorn UI ── Internal (*.int.*)           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────
```

## This infrastructure provides a production-grade foundation for a homelab with:

- Zero-trust networking (public/private gateway separation)
- Automated certificate management (wildcard TLS)
- GitOps-driven deployments (code = infrastructure)
- Full observability (metrics, dashboards, alerts)
- Secure remote access (Tailscale VPN)
- Extensible storage (block and local storage options)

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

