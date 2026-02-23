## Context

The homelab Kubernetes cluster uses ArgoCD for GitOps with a three-tier ApplicationSet structure (infrastructure, monitoring, apps). The cluster is a single-node K3s setup with:
- **Cilium CNI** with Gateway API (dual gateway: external via Cloudflare Tunnel, internal via Tailscale)
- **local-path-provisioner** as the primary storage class (due to node resource constraints)
- **Longhorn** configs preserved but excluded from ArgoCD management (for future use)
- **Backblaze B2** existing backup infrastructure with Restic

Reference implementation from `k8s-gitops/` demonstrates production-ready patterns for:
- Cilium Network Policies (18 reusable policies with label-based opt-in)
- SealedSecrets for git-safe secret storage
- ArgoCD drift prevention (ignoreDifferences for controller-modified fields)
- Enhanced monitoring (custom alerts, Grafana dashboards)

### Current Pain Points
1. **OutOfSync applications**: cert-manager, nginx, and other apps show perpetual OutOfSync due to controller-injected fields
2. **No network segmentation**: All pods can reach any other pod/external endpoint
3. **No PVC backups**: local-path-provisioner volumes have no backup strategy
4. **Secrets not in git**: Cloudflare tunnel credentials, API keys stored outside version control
5. **Limited observability**: Only default Prometheus alerts/dashboards

## Goals / Non-Goals

**Goals:**
- Eliminate OutOfSync drift for all applications by configuring ArgoCD ignoreDifferences
- Add network security through Cilium Network Policies with opt-in model
- Implement Velero + Restic backup strategy for local-path PVCs to Backblaze B2
- Convert all secrets to SealedSecrets for safe git storage
- Add custom alerting rules and Grafana dashboards for infrastructure components
- Add Renovate for automated dependency updates
- Add Reloader for automatic ConfigMap/Secret reloads

**Non-Goals:**
- Migrating to CloudNativePG (no PostgreSQL workloads currently)
- Adding External DNS (existing cert-manager + Cloudflare Tunnel handles DNS)
- Multi-node cluster changes (keeping single-node optimizations)
- Changing the dual gateway architecture (external/internal separation is working well)
- Activating Longhorn now (configs preserved for future when node resources allow)

## Decisions

### D1: Network Policy Approach - Opt-in via Labels
**Decision**: Use label-based opt-in model for network policies

**Rationale**:
- k8s-gitops uses this pattern successfully
- Allows gradual rollout - existing apps work unchanged
- Explicit declaration of network requirements per app
- Example: Add `netpol.cilium.io/egress-to-kube-dns: "true"` to enable DNS egress

**Alternatives Considered**:
- Default-deny with explicit allow: More secure but would break existing apps immediately
- Per-app network policies: Duplicates policy definitions, harder to maintain

### D2: Backup Strategy - Velero + Restic for local-path
**Decision**: Use Velero with Restic for PVC backups to Backblaze B2

**Rationale**:
- Works with any storage class including local-path
- File-level backup means it works without snapshot support
- Supports migration between storage classes (local-path → Longhorn)
- User already has B2 + Restic workflow established
- Can restore individual files or entire PVCs

**Velero vs K8up Resource Usage**:
| Tool | Controller | Memory | Use Case |
|------|------------|--------|----------|
| Velero | ~150MB | Full-featured backup/restore, migrations | Better for complex scenarios |
| K8up | ~30MB | Restic operator only | Lighter, simpler |

**Recommendation**: Use Velero for full backup/restore capabilities including migrations. K8up is lighter but Velero provides more features for disaster recovery.

**Alternatives Considered**:
- K8up: Lighter weight but fewer features for migration
- Longhorn recurring jobs: Not applicable to local-path storage

### D3: SealedSecrets for GitOps-Safe Secrets
**Decision**: Convert all secrets to SealedSecrets with cluster-wide scope

**Rationale**:
- Secrets can be safely committed to git
- SealedSecrets are encrypted with controller's public key
- Only the sealed-secrets controller in the cluster can decrypt
- k8s-gitops pattern uses `cluster-wide` scope for flexibility

**Secrets to Convert**:
| Secret | Location | Purpose |
|--------|----------|---------|
| cloudflared-credentials | cluster/infrastructure/networking/cloudflared/ | Cloudflare Tunnel auth |
| B2 credentials | cluster/infrastructure/backup/velero/ | Backup storage auth |
| Grafana admin | cluster/monitoring/kube-prometheus-stack/ | Grafana login |

**Alternatives Considered**:
- External Secrets Operator: Requires external secret store (HashiCorp Vault, AWS Secrets Manager)
- SOPS: Good but SealedSecrets is already installed

### D4: ArgoCD ignoreDifferences Configuration Location
**Decision**: Configure ignoreDifferences in ArgoCD ConfigMap (values.yaml)

**Rationale**:
- Central configuration applies to all applications
- No need to modify each Application manifest
- Easier to maintain and audit

### D5: Longhorn Exclusion from ArgoCD
**Decision**: Exclude Longhorn directory from ApplicationSet while keeping configs in repo

**Rationale**:
- Longhorn requires significant RAM/CPU not currently available
- Configs preserved for future when node is upgraded
- Single `exclude` entry in ApplicationSet keeps things clean

### D6: Renovate Configuration
**Decision**: Use Renovate with regex managers for Helm charts and Docker images

**Rationale**:
- Handles both Helm chart versions and Docker image tags
- Custom regex managers for kustomization.yaml Helm chart syntax
- Schedule during off-hours (0-4 AM Monday)

## Storage Migration Strategy

### local-path → Longhorn Migration (Future)

When Longhorn becomes viable:

```bash
# 1. Install Longhorn (remove from ApplicationSet exclude)
# 2. Install Velero if not already present
# 3. Backup current PVC
velero backup create myapp-backup --include-namespaces myapp

# 4. Scale down application
kubectl scale deployment myapp --replicas=0 -n myapp

# 5. Delete old PVC, create new with Longhorn
kubectl delete pvc myapp-data -n myapp
kubectl apply -f - <<EOF
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
EOF

# 6. Restore backup to new PVC
velero restore create --from-backup myapp-backup

# 7. Scale up application
kubectl scale deployment myapp --replicas=1 -n myapp
```

### Immich Migration Scenario

For complex apps like Immich with multiple data types:

```bash
# Immich has: PostgreSQL + Redis + Uploads directory

# 1. Backup PostgreSQL (pg_dump or Velero)
kubectl exec -n immich immich-db-0 -- pg_dump -U immich immich > immich-db.sql

# 2. Backup uploads via Velero Restic
velero backup create immich-backup --include-namespaces immich

# 3. Deploy new Immich with Longhorn PVCs

# 4. Restore database
cat immich-db.sql | kubectl exec -i -n immich immich-db-0 -- psql -U immich immich

# 5. Restore uploads (Velero handles this automatically)
velero restore create --from-backup immich-backup
```

## Risks / Trade-offs

### R1: Network Policy Lockout
**Risk**: Applying network policies could lock out critical traffic (e.g., DNS, API server)
**Mitigation**: 
- Start with egress-to-kube-dns and egress-to-kube-apiserver policies applied to all apps
- Test each policy group incrementally
- Keep `ingress-from-world` available for quick debugging

### R2: Velero Backup Storage Costs
**Risk**: B2 storage could grow with Restic backups
**Mitigation**:
- Set retention policies in Velero schedule
- Use Restic pruning to remove old snapshots
- B2 lifecycle rules for cost management

### R3: SealedSecret Key Loss
**Risk**: Losing the sealed-secrets private key means all secrets are unrecoverable
**Mitigation**:
- Backup sealed-secrets-key secret to B2
- Document key rotation process
- Keep offline copy of key

### R4: Renovate PR Overload
**Risk**: Too many automated PRs could overwhelm review process
**Mitigation**:
- Group related packages (CNPG stack, monitoring, etc.)
- Schedule runs weekly during off-hours
- Use automerge for patch versions only (if desired)

## Migration Plan

### Phase 1: Foundation (No Breaking Changes)
1. Add ArgoCD ignoreDifferences configuration
2. Exclude Longhorn from ApplicationSet
3. Add standardized labels to all applications
4. Add `Delete=false` to PVCs

### Phase 2: Secrets Management
1. Create SealedSecrets for Cloudflare tunnel credentials
2. Create SealedSecrets for B2 backup credentials
3. Add key rotation script

### Phase 3: Network Security
1. Create `cluster/common/cilium-network-policies/` directory
2. Copy all network policy files from k8s-gitops
3. Add network policy references to each app's kustomization
4. Add required labels to deployments (start with DNS/API server egress)

### Phase 4: Backup Strategy
1. Deploy Velero with Restic and B2 backend
2. Create backup schedules for all namespaces with PVCs
3. Test backup/restore workflow

### Phase 5: Enhanced Monitoring
1. Add custom alert rules
2. Add Grafana dashboards
3. Add ServiceMonitors/PodMonitors

### Phase 6: Automation
1. Add Renovate configuration
2. Add Reloader controller
3. Configure image annotations for Renovate

### Rollback Strategy
- Each phase is independently reversible
- Network policies: Remove label opt-in or delete policy resources
- ignoreDifferences: Remove from ArgoCD config and restart
- Velero: Disable schedules, backups remain in B2
- SealedSecrets: Original secrets can be recreated manually
- Renovate/Reloader: Disable via ApplicationSet exclude

## Open Questions

1. **Renovate Automerge**: Should Renovate automatically merge patch versions, or require manual approval for all updates?
2. **Alert Notifications**: Do you want Telegram alerts? (k8s-gitops uses Telegram; alternatives: Slack, Discord, email)
