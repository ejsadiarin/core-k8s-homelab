# Storage Class Migration

This document covers migrating PVCs between storage classes, specifically from local-path to Longhorn.

## Prerequisites

- Velero with Restic enabled
- Both source and target storage classes available
- Sufficient disk space for backup storage

## Migration: local-path → Longhorn

### Method 1: Using Velero Backup/Restore

```bash
# 1. Create a backup of the current PVC
velero backup create myapp-pre-migration \
  --include-namespaces myapp \
  --snapshot-volumes=false

# 2. Wait for backup to complete
velero backup describe myapp-pre-migration

# 3. Scale down the application
kubectl scale deployment myapp --replicas=0 -n myapp

# 4. Delete the old PVC
kubectl delete pvc myapp-data -n myapp

# 5. Create new PVC with Longhorn storage class
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myapp-data
  namespace: myapp
spec:
  storageClassName: longhorn
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
EOF

# 6. Restore the backup
velero restore create --from-backup myapp-pre-migration

# 7. Verify the restore
kubectl get pvc -n myapp
kubectl describe pvc myapp-data -n myapp

# 8. Scale up the application
kubectl scale deployment myapp --replicas=1 -n myapp

# 9. Verify application is working
kubectl logs -n myapp -l app=myapp
```

### Method 2: Direct Data Copy (for simple apps)

```bash
# 1. Scale down the application
kubectl scale deployment myapp --replicas=0 -n myapp

# 2. Create a data mover pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: data-mover
  namespace: myapp
spec:
  containers:
  - name: mover
    image: busybox
    command: ["sh", "-c", "cp -a /source/. /dest/ && sync"]
    volumeMounts:
    - name: source
      mountPath: /source
    - name: dest
      mountPath: /dest
  volumes:
  - name: source
    persistentVolumeClaim:
      claimName: myapp-data-local
  - name: dest
    persistentVolumeClaim:
      claimName: myapp-data-longhorn
  restartPolicy: Never
EOF

# 3. Wait for the copy to complete
kubectl wait --for=condition=Complete pod/data-mover -n myapp --timeout=600s

# 4. Check the logs for any errors
kubectl logs data-mover -n myapp

# 5. Clean up
kubectl delete pod data-mover -n myapp
kubectl delete pvc myapp-data-local -n myapp

# 6. Update deployment to use new PVC and scale up
kubectl scale deployment myapp --replicas=1 -n myapp
```

## Migration Checklist

- [ ] Verify backup exists before starting
- [ ] Application is scaled down
- [ ] Old PVC deleted after backup confirmed
- [ ] New PVC created with correct storage class
- [ ] Restore completed successfully
- [ ] Application scaled up and verified
- [ ] Old backups cleaned up if no longer needed

## Rollback

If migration fails:

```bash
# 1. Scale down
kubectl scale deployment myapp --replicas=0 -n myapp

# 2. Delete new PVC
kubectl delete pvc myapp-data -n myapp

# 3. Recreate old PVC with local-path
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myapp-data
  namespace: myapp
spec:
  storageClassName: local-path
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
EOF

# 4. Restore from backup
velero restore create rollback-restore --from-backup myapp-pre-migration

# 5. Scale up
kubectl scale deployment myapp --replicas=1 -n myapp
```