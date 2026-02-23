## 1. ArgoCD Drift Prevention

- [x] 1.1 Add ignoreDifferences for ValidatingWebhookConfiguration CA bundles in ArgoCD values.yaml
- [x] 1.2 Add ignoreDifferences for MutatingWebhookConfiguration CA bundles in ArgoCD values.yaml
- [x] 1.3 Add ignoreDifferences for HTTPRoute status fields in ArgoCD values.yaml
- [x] 1.4 Add ignoreDifferences for Gateway status fields in ArgoCD values.yaml
- [x] 1.5 Add ignoreDifferences for Longhorn Volume status fields in ArgoCD values.yaml
- [x] 1.6 Add ignoreDifferences for ServiceMonitor endpoints in ArgoCD values.yaml
- [x] 1.7 Remove blanket sync-wave annotation from cert-manager kustomization.yaml
- [x] 1.8 Add Delete=false sync option annotation to all PVC resources
- [x] 1.9 Exclude Longhorn from infrastructure ApplicationSet (add to exclude list)

## 2. SealedSecrets

- [x] 2.1 Fetch sealed-secrets public certificate from cluster
- [x] 2.2 Create SealedSecret for cloudflared tunnel credentials
- [x] 2.3 Replace cloudflared secret reference with SealedSecret
- [x] 2.4 Create SealedSecret for Velero B2 credentials
- [x] 2.5 Add rotate-seal-key.sh script to cluster/scripts/
- [x] 2.6 Document SealedSecret creation workflow in docs/

## 3. Network Policies

- [x] 3.1 Create `cluster/common/cilium-network-policies/` directory
- [x] 3.2 Create egress-to-kube-dns.yaml network policy
- [x] 3.3 Create egress-to-kube-apiserver.yaml network policy
- [x] 3.4 Create egress-to-prometheus.yaml network policy
- [x] 3.5 Create egress-to-host.yaml network policy
- [x] 3.6 Create egress-to-intra.yaml network policy
- [x] 3.7 Create egress-to-world.yaml network policy
- [x] 3.8 Create egress-to-public-ips.yaml network policy
- [x] 3.9 Create egress-to-cloudflare.yaml network policy
- [x] 3.10 Create egress-deny.yaml network policy
- [x] 3.11 Create ingress-from-prometheus.yaml network policy
- [x] 3.12 Create ingress-from-ingress.yaml network policy
- [x] 3.13 Create ingress-from-host.yaml network policy
- [x] 3.14 Create ingress-from-intra.yaml network policy
- [x] 3.15 Create ingress-from-world.yaml network policy
- [x] 3.16 Create ingress-deny.yaml network policy
- [x] 3.17 Create kustomization.yaml for common network policies
- [x] 3.18 Add network policy labels to nginx deployment
- [x] 3.19 Add network policy labels to glance deployment
- [x] 3.20 Add network policy labels to hello-world deployment
- [x] 3.21 Add network policy labels to homepage-dashboard deployment
- [x] 3.22 Add network policy labels to it-tools deployment
- [x] 3.23 Add network policy labels to bday-hannah deployment
- [x] 3.24 Add network policy labels to monitoring stack components
- [x] 3.25 Add common network policies reference to each app's kustomization.yaml

## 4. Velero Backup

- [x] 4.1 Create infrastructure/backup/velero/ directory
- [x] 4.2 Create namespace.yaml for velero
- [x] 4.3 Create kustomization.yaml for velero
- [x] 4.4 Create values.yaml with Restic enabled and B2 configuration
- [x] 4.5 Create SealedSecret for B2 credentials (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
- [x] 4.6 Create daily backup Schedule (3 AM, 30-day retention)
- [x] 4.7 Create weekly backup Schedule (Sunday 2 AM, 90-day retention)
- [x] 4.8 Create BackupStorageLocation for B2
- [x] 4.9 Verify velero is auto-discovered by infrastructure ApplicationSet

## 5. Monitoring Alerts

- [x] 5.1 Create alerts/kustomization.yaml
- [x] 5.2 Create kubernetes-alerts.yaml with node/pod/resource alerts
- [x] 5.3 Create storage-alerts.yaml with Longhorn node/volume/storage alerts
- [x] 5.4 Create applications-alerts.yaml with ArgoCD sync alerts
- [x] 5.5 Reference alerts directory in kube-prometheus-stack kustomization.yaml

## 6. Grafana Dashboards

- [x] 6.1 Create dashboards/kustomization.yaml
- [x] 6.2 Create argocd-dashboard.yaml ConfigMap
- [x] 6.3 Create longhorn-dashboard.yaml ConfigMap
- [x] 6.4 Create cilium-dashboard.yaml ConfigMap
- [x] 6.5 Create cilium-hubble-dashboard.yaml ConfigMap
- [x] 6.6 Reference dashboards directory in kube-prometheus-stack kustomization.yaml

## 7. Renovate Automation

- [x] 7.1 Create .github/renovate.json with base configuration
- [x] 7.2 Add regex manager for Helm chart versions in kustomization.yaml
- [x] 7.3 Add regex manager for Docker images in deployment.yaml
- [x] 7.4 Configure package grouping rules (CNPG, monitoring, etc.)
- [x] 7.5 Set schedule to weekly during off-hours (0-4 AM Monday)

## 8. Reloader

- [x] 8.1 Create infrastructure/controllers/reloader/namespace.yaml
- [x] 8.2 Create infrastructure/controllers/reloader/kustomization.yaml
- [x] 8.3 Create infrastructure/controllers/reloader/values.yaml with resource limits
- [x] 8.4 Verify reloader is auto-discovered by infrastructure ApplicationSet

## 9. Standardized Labels

- [x] 9.1 Add standard labels to nginx kustomization.yaml
- [x] 9.2 Add standard labels to glance kustomization.yaml
- [x] 9.3 Add standard labels to hello-world kustomization.yaml
- [x] 9.4 Add standard labels to homepage-dashboard kustomization.yaml
- [x] 9.5 Add standard labels to it-tools kustomization.yaml
- [x] 9.6 Add standard labels to bday-hannah kustomization.yaml

## 10. Verification

- [x] 10.1 Verify ArgoCD applications show Synced status after ignoreDifferences
- [x] 10.2 Verify network policies exist in cluster and are enforced
- [ ] 10.3 Verify Velero is running and backups are scheduled
- [ ] 10.4 Verify test backup completes successfully
- [ ] 10.5 Verify custom alerts are loaded in Prometheus
- [ ] 10.6 Verify dashboards are loaded in Grafana
- [x] 10.7 Verify Reloader is running and functional
- [x] 10.8 Verify Longhorn is excluded from ArgoCD management

## 11. Documentation

- [x] 11.1 Create docs/backup-restore.md with Velero procedures
- [x] 11.2 Create docs/storage-migration.md with local-path to Longhorn migration
- [x] 11.3 Create docs/sealed-secrets.md with creation workflow
- [x] 11.4 Create docs/network-policies.md with opt-in label reference
- [x] 11.5 Update ARCHITECTURE_AT_A_GLANCE.md with new components

---

## Documentation Templates

### docs/backup-restore.md

```markdown
# Backup and Restore with Velero

## Prerequisites

- Velero CLI installed locally (`brew install velero` or download from GitHub)
- Access to Backblaze B2 bucket

## Backup Operations

### Manual Backup

velero backup create manual-backup --include-namespaces nginx

### View Backup Status

velero backup describe manual-backup

### List Backups

velero get backups

## Restore Operations

### Restore Entire Namespace

velero restore create --from-backup manual-backup

### Restore Specific Resource

velero restore create --from-backup manual-backup --include-resources pvc

### Restore to Different Namespace

velero restore create restored-nginx --from-backup manual-backup --namespace-mappings nginx=nginx-restored

## Troubleshooting

### Check Velero Logs

kubectl logs -n velero -l app=velero

### Check Restic Repository

velero restic repo get
```

### docs/storage-migration.md

```markdown
# Storage Class Migration (local-path → Longhorn)

## Prerequisites

- Longhorn installed and configured
- Velero with Restic enabled
- Sufficient node resources for Longhorn

## Migration Steps

### 1. Backup Current PVC

velero backup create myapp-pre-migration --include-namespaces myapp

### 2. Scale Down Application

kubectl scale deployment myapp --replicas=0 -n myapp

### 3. Delete Old PVC

kubectl delete pvc myapp-data -n myapp

### 4. Create New PVC with Longhorn

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
name: myapp-data
namespace: myapp
spec:
storageClassName: longhorn
accessModes: [ReadWriteOnce]
resources:
requests:
storage: 10Gi

### 5. Restore Data

velero restore create --from-backup myapp-pre-migration

### 6. Scale Up Application

kubectl scale deployment myapp --replicas=1 -n myapp

### 7. Verify

kubectl get pods -n myapp
kubectl exec -n myapp <pod> -- ls -la /data
```

### docs/sealed-secrets.md

```markdown
# SealedSecrets Workflow

## Creating a New SealedSecret

### 1. Get the Public Certificate

kubeseal --fetch-cert > sealed-secrets-cert.pem

### 2. Create Plain Secret YAML (DO NOT COMMIT)

apiVersion: v1
kind: Secret
metadata:
name: my-secret
namespace: my-namespace
stringData:
API_KEY: my-secret-value

### 3. Seal the Secret

kubeseal --format=yaml --scope=cluster-wide \
 --cert=sealed-secrets-cert.pem \
 < my-secret.yaml > my-secret-sealed.yaml

### 4. Commit Only the SealedSecret

git add my-secret-sealed.yaml
git commit -m "Add sealed secret for my-app"

### 5. Clean Up Plain Secret

rm my-secret.yaml

## Key Rotation

Run the rotation script:
./cluster/scripts/rotate-seal-key.sh

Follow the prompts to:

1. Generate new key pair
2. Reseal all secrets
3. Update controller

## Disaster Recovery

The sealed-secrets key is backed up to B2 via Velero.
To recover:
velero restore create --from-backup daily-pvc-backup --include-resources secret -n sealed-secrets
```

### docs/network-policies.md

```markdown
# Network Policies Reference

## Available Policies

### Egress Policies

| Policy                   | Label                                               | Description                    |
| ------------------------ | --------------------------------------------------- | ------------------------------ |
| egress-to-kube-dns       | `netpol.cilium.io/egress-to-kube-dns: "true"`       | Allow DNS queries to kube-dns  |
| egress-to-kube-apiserver | `netpol.cilium.io/egress-to-kube-apiserver: "true"` | Allow API server access        |
| egress-to-world          | `netpol.cilium.io/egress-to-world: "true"`          | Allow external internet access |
| egress-to-cloudflare     | `netpol.cilium.io/egress-to-cloudflare: "true"`     | Allow Cloudflare API access    |

### Ingress Policies

| Policy                  | Label                                              | Description                    |
| ----------------------- | -------------------------------------------------- | ------------------------------ |
| ingress-from-prometheus | `netpol.cilium.io/ingress-from-prometheus: "true"` | Allow Prometheus scraping      |
| ingress-from-ingress    | `netpol.cilium.io/ingress-from-ingress: "true"`    | Allow Gateway traffic          |
| ingress-from-world      | `netpol.cilium.io/ingress-from-world: "true"`      | Allow all incoming (debugging) |

## Adding to a Deployment

spec:
template:
metadata:
labels:
netpol.cilium.io/egress-to-kube-dns: "true"
netpol.cilium.io/egress-to-kube-apiserver: "true"
netpol.cilium.io/ingress-from-prometheus: "true"
netpol.cilium.io/ingress-from-ingress: "true"

## Common Patterns

### Web Application

- egress-to-kube-dns
- ingress-from-ingress
- ingress-from-prometheus

### Database

- egress-to-kube-dns
- ingress-from-intra (namespace-internal only)

### Monitoring

- egress-to-kube-apiserver
- egress-to-kube-dns
- ingress-from-prometheus
```

