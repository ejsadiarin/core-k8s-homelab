# Backup and Restore with Velero

## Prerequisites

- Velero CLI installed locally (`brew install velero` or download from GitHub releases)
- Access to Backblaze B2 bucket
- kubectl access to the cluster

## Backup Operations

### List All Backups

```bash
velero get backups
```

### Manual Backup

```bash
# Backup a specific namespace
velero backup create myapp-backup --include-namespaces nginx

# Backup multiple namespaces
velero backup create multi-backup --include-namespaces nginx,glance,hello-world

# Backup entire cluster (excluding system namespaces)
velero backup create full-backup --exclude-namespaces velero,kube-system,sealed-secrets
```

### View Backup Status

```bash
# View backup details
velero backup describe myapp-backup

# View backup logs
velero backup logs myapp-backup
```

### Schedule Backups

Daily and weekly schedules are pre-configured:
- `daily-backup`: Runs at 3 AM, 30-day retention
- `weekly-backup`: Runs Sunday 2 AM, 90-day retention

## Restore Operations

### Restore Entire Namespace

```bash
velero restore create --from-backup myapp-backup
```

### Restore Specific Resources

```bash
# Restore only PVCs
velero restore create --from-backup myapp-backup --include-resources pvc

# Restore only from specific namespace
velero restore create --from-backup myapp-backup --include-namespaces nginx
```

### Restore to Different Namespace

```bash
velero restore create restored-nginx \
  --from-backup myapp-backup \
  --namespace-mappings nginx=nginx-restored
```

## Troubleshooting

### Check Velero Logs

```bash
kubectl logs -n velero -l app=velero --tail=100
```

### Check Backup Status

```bash
velero backup get
```

### Common Issues

1. **Backup stuck in "InProgress"**
   - Check node agent pods are running
   - Check Restic repository status

2. **Restore fails with "volume not found"**
   - Ensure PVC storage class exists
   - Check if PV was already deleted

3. **Permission denied errors**
   - Verify B2 credentials are correct
   - Check secret `velero-b2-credentials` exists

## Backup Storage

Backups are stored in Backblaze B2:
- Location: `s3://YOUR_BUCKET/`
- Configured in `cluster/infrastructure/backup/velero/values.yaml`

## Retention Policy

- Daily backups: 30 days (720 hours)
- Weekly backups: 90 days (2160 hours)