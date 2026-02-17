# Architecture at a Glance

Internet → Cloudflare Tunnel → Gateway External (public apps)
↓
VPN → Tailscale → Gateway Internal (private apps only)

## Three-Tier Design:

- External Gateway (192.168.10.201): Public apps (\*.ejsadiarin.com)
- Internal Gateway (192.168.10.202): VPN-only apps (\*.int.ejsadiarin.com)
- Cloudflared DaemonSet: Routes external traffic via Cloudflare Tunnel

---

## Infrastructure Components

### Networking (/infrastructure/networking/)

| Component        | Technology     | Purpose                                               |
| ---------------- | -------------- | ----------------------------------------------------- |
| CNI              | Cilium 1.18.4  | kube-proxy replacement, Gateway API, L2 announcements |
| Ingress          | Gateway API    | HTTPRoutes for all traffic                            |
| External Access  | cloudflared    | Cloudflare Tunnel (DaemonSet)                         |
| LoadBalancer     | Cilium IP Pool | 192.168.10.200/29 range                               |
| Network Policies | Cilium         | Label-based opt-in network segmentation               |

### Storage (/infrastructure/storage/)

| Type       | Default | Use Case                            |
| ---------- | ------- | ----------------------------------- |
| Longhorn   | ✅ Yes  | Databases, critical data, 1 replica |
| Local-Path | No      | Caches, temporary data              |

**Note:** Longhorn configs are preserved but excluded from ArgoCD (requires more resources)

### Backup (/infrastructure/backup/)

| Component | Purpose                                              |
| --------- | ---------------------------------------------------- |
| Velero    | PVC backup/restore with Restic                       |
| B2 Target | S3-compatible backup storage                         |
| Schedules | Daily (3 AM, 30d retention) + Weekly (Sun 2 AM, 90d) |

### Controllers (/infrastructure/controllers/)

| Controller     | Purpose                                             |
| -------------- | --------------------------------------------------- |
| ArgoCD         | GitOps with custom kustomize-build-with-helm plugin |
| cert-manager   | Let's Encrypt wildcard certs via DNS-01             |
| Sealed Secrets | Git-friendly secret encryption                      |
| Reloader       | Auto-reload workloads on ConfigMap/Secret changes   |

### Common Resources (/common/)

| Resource                | Purpose                                     |
| ----------------------- | ------------------------------------------- |
| cilium-network-policies | Reusable network policies with label opt-in |

---

## Applications (/apps/)

| App                | Gateway  | Domain                      | Storage      |
| ------------------ | -------- | --------------------------- | ------------ |
| glance             | External | dash.ejsadiarin.com         | ConfigMap    |
| nginx              | External | nginx.ejsadiarin.com        | Longhorn 1Gi |
| hello-world        | External | hello-world.ejsadiarin.com  | local-path   |
| homepage-dashboard | Internal | homepage.int.ejsadiarin.com | None         |
| it-tools           | External | (configured)                | None         |
| bday-hannah        | External | (configured)                | None         |
| grafana            | Internal | grafana.int.ejsadiarin.com  | Longhorn 1Gi |
| longhorn           | Internal | longhorn.int.ejsadiarin.com | N/A          |

---

## Monitoring Stack (/monitoring/)

| Component          | Storage        | Access                        |
| ------------------ | -------------- | ----------------------------- |
| Prometheus         | 10Gi Longhorn  | prometheus.int.ejsadiarin.com |
| Grafana            | 1Gi Longhorn   | grafana.int.ejsadiarin.com    |
| AlertManager       | 512Mi Longhorn | Internal                      |
| Node Exporter      | None           | Host metrics                  |
| kube-state-metrics | None           | K8s object metrics            |

### Alerting

| Alert Rule File     | Coverage                                  |
| ------------------- | ----------------------------------------- |
| kubernetes-alerts   | Node ready, pod crashloop, resource usage |
| storage-alerts      | PVC usage warnings                        |
| applications-alerts | App down, high error rate                 |

### Dashboards

| Dashboard          | Purpose                              |
| ------------------ | ------------------------------------ |
| argocd-dashboard   | ArgoCD sync status, app health       |
| longhorn-dashboard | Volume health, node storage          |
| cilium-dashboard   | Network policy hits, endpoint status |
| cilium-hubble      | Network flow visibility              |

---

## GitOps Workflow

**ArgoCD ApplicationSets (sync wave order):**

Wave -10: cert-manager (TLS must be ready first)
Wave -2: Infrastructure (Cilium, Gateways, Storage, Backup, Reloader)
Wave -1: Cloudflared (depends on gateways)
Wave 0: Monitoring stack
Wave 1: User Applications
Wave 2: Prometheus Adapter

**Deployment Pattern:**

- Kustomize + Helm via custom ArgoCD plugin
- Namespace-per-app
- HTTPRoute for all ingress
- CreateNamespace + ServerSideApply sync options
- ignoreDifferences for controller-modified fields

---

**Key Patterns & Conventions**

1. _Two Gateway Separation_: Public vs private at infrastructure level
2. _Wildcard TLS_: `*.ejsadiarin.com` and `*.int.ejsadiarin.com` via cert-manager
3. _ConfigMap Generators_: For glance and homepage-dashboard configs
4. _Sealed Secrets_: For Git-stored secrets (cluster-wide scope)
5. _Sync Waves_: Ensure proper dependency ordering
6. _Network Policies_: Label-based opt-in for network segmentation
7. _ignoreDifferences_: Prevent OutOfSync from controller-modified fields
8. _PVC Protection_: Delete=false annotation on all PVCs

---

**Documentation Files**

- `/README.md` - Full architecture analysis
- `/SETUP_GUIDE.md` - Bootstrap procedures
- `/docs/backup-restore.md` - Velero backup/restore procedures
- `/docs/storage-migration.md` - Storage class migration guide
- `/docs/sealed-secrets.md` - SealedSecret creation workflow
- `/docs/network-policies.md` - Network policy reference
- `/docs/tailscale-access.md` - VPN setup
- `/docs/storage-testing-guide.md` - Storage validation

---

**Automation**

- Renovate: Automated dependency updates (weekly, 0-4 AM Monday)
- Reloader: Automatic workload reload on ConfigMap/Secret changes

## Infrastructure Components

### Networking (/infrastructure/networking/)

| Component       | Technology     | Purpose                                               |
| --------------- | -------------- | ----------------------------------------------------- |
| CNI             | Cilium 1.18.4  | kube-proxy replacement, Gateway API, L2 announcements |
| Ingress         | Gateway API    | HTTPRoutes for all traffic                            |
| External Access | cloudflared    | Cloudflare Tunnel (DaemonSet)                         |
| LoadBalancer    | Cilium IP Pool | 192.168.10.200/29 range                               |

### Storage (/infrastructure/storage/)

| Type       | Default | Use Case                            |
| ---------- | ------- | ----------------------------------- |
| Longhorn   | ✅ Yes  | Databases, critical data, 1 replica |
| Local-Path | No      | Caches, temporary data              |

### Controllers (/infrastructure/controllers/)

| Controller     | Purpose                                             |
| -------------- | --------------------------------------------------- |
| ArgoCD         | GitOps with custom kustomize-build-with-helm plugin |
| cert-manager   | Let's Encrypt wildcard certs via DNS-01             |
| Sealed Secrets | Git-friendly secret encryption                      |

---

## Applications (/apps/)

| App                | Gateway  | Domain                      | Storage      |
| ------------------ | -------- | --------------------------- | ------------ |
| glance             | External | dash.ejsadiarin.com         | ConfigMap    |
| nginx              | External | nginx.ejsadiarin.com        | Longhorn 1Gi |
| hello-world        | External | hello-world.ejsadiarin.com  | local-path   |
| homepage-dashboard | Internal | homepage.int.ejsadiarin.com | None         |
| grafana            | Internal | grafana.int.ejsadiarin.com  | Longhorn 1Gi |
| longhorn           | Internal | longhorn.int.ejsadiarin.com | N/A          |

---

## Monitoring Stack (/monitoring/)

| Component          | Storage        | Access                        |
| ------------------ | -------------- | ----------------------------- |
| Prometheus         | 10Gi Longhorn  | prometheus.int.ejsadiarin.com |
| Grafana            | 1Gi Longhorn   | grafana.int.ejsadiarin.com    |
| AlertManager       | 512Mi Longhorn | Internal                      |
| Node Exporter      | None           | Host metrics                  |
| kube-state-metrics | None           | K8s object metrics            |

---

## GitOps Workflow

**ArgoCD ApplicationSets (sync wave order):**

Wave -10: cert-manager (TLS must be ready first)
Wave -2: Infrastructure (Cilium, Gateways, Storage)
Wave -1: Cloudflared (depends on gateways)
Wave 0: Monitoring stack
Wave 1: User Applications
Wave 2: Prometheus Adapter

**Deployment Pattern:**

- Kustomize + Helm via custom ArgoCD plugin
- Namespace-per-app
- HTTPRoute for all ingress
- CreateNamespace + ServerSideApply sync options

---

**Key Patterns & Conventions**

1. _Two Gateway Separation_: Public vs private at infrastructure level
2. _Wildcard TLS_: `_.ejsadiarin.com` and `_.int.ejsadiarin.com` via cert-manager
3. _ConfigMap Generators_: For glance and homepage-dashboard configs
4. _Sealed Secrets_: For Git-stored secrets
5. _Sync Waves_: Ensure proper dependency ordering

---

**Documentation Files**

- `/README.md` - Full architecture analysis
- `/SETUP_GUIDE.md` - Bootstrap procedures
- `/tasks.md` - Monitoring implementation tasks
- `/docs/tailscale-access.md` - VPN setup
- `/docs/storage-testing-guide.md` - Storage validation

---
