# SealedSecrets Workflow

This document describes how to create and manage sealed secrets in this cluster.

## Overview

SealedSecrets allow you to encrypt Kubernetes Secrets so they can be safely stored in git. Only the sealed-secrets controller running in the cluster can decrypt them.

## Prerequisites

- `kubeseal` CLI installed (`brew install kubeseal` or download from GitHub)
- Cluster access via `kubectl`
- The sealed-secrets controller must be running in the cluster

## Creating a New SealedSecret

### Step 1: Create a Plain Secret YAML

Create a regular Kubernetes Secret YAML file (do NOT commit this):

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
  namespace: my-namespace
stringData:
  API_KEY: my-secret-value
  DB_PASSWORD: another-secret
```

### Step 2: Seal the Secret

Use `kubeseal` to encrypt the secret:

```bash
# Fetch the public certificate (optional - kubeseal can fetch automatically)
kubeseal --fetch-cert > /tmp/sealed-secrets-cert.pem

# Seal the secret
kubeseal --format=yaml --scope=cluster-wide \
  < my-secret.yaml > my-secret-sealed.yaml
```

### Step 3: Commit Only the SealedSecret

```bash
git add my-secret-sealed.yaml
git commit -m "Add sealed secret for my-app"
rm my-secret.yaml  # Clean up the plain secret!
```

### Step 4: Reference in Kustomization

Add the sealed secret to your kustomization.yaml:

```yaml
resources:
  - namespace.yaml
  - my-secret-sealed.yaml
  - deployment.yaml
```

## Sealing Secrets for Different Scopes

### Cluster-wide (Recommended)

Secrets can be used in any namespace:

```bash
kubeseal --format=yaml --scope=cluster-wide < secret.yaml > secret-sealed.yaml
```

### Namespace-wide

Secrets can only be used in the specified namespace:

```bash
kubeseal --format=yaml --scope=namespace-wide < secret.yaml > secret-sealed.yaml
```

### Strict

Secrets are bound to both name and namespace:

```bash
kubeseal --format=yaml < secret.yaml > secret-sealed.yaml
```

## Key Rotation

To rotate the sealed-secrets key and re-encrypt all secrets:

```bash
./cluster/scripts/rotate-seal-key.sh
```

This will:
1. Extract the current key from the cluster
2. Generate a new key pair
3. Re-encrypt all `*-sealed.yaml` files
4. Create backups of original files

After running the script:
1. Commit the changes
2. Apply the new key to the cluster
3. Restart the sealed-secrets controller

## Disaster Recovery

### Backup the Key

The sealed-secrets private key should be backed up:

```bash
# Get the latest key
kubectl get secrets -n sealed-secrets -l sealedsecrets.bitnami.com/sealed-secrets-key=active -o yaml > sealed-secrets-key-backup.yaml

# Store this file securely (NOT in git)
```

### Restore the Key

If the sealed-secrets controller loses its keys:

```bash
kubectl apply -f sealed-secrets-key-backup.yaml
kubectl -n sealed-secrets rollout restart deploy/sealed-secrets-controller
```

## Common Issues

### SealedSecret not being decrypted

Check that:
1. The sealed-secrets controller is running: `kubectl get pods -n sealed-secrets`
2. The SealedSecret has been created: `kubectl get sealedsecrets -A`
3. Check controller logs: `kubectl logs -n sealed-secrets -l app=sealed-secrets`

### Scope mismatch

If you see errors about scope:
- Ensure the annotation `sealedsecrets.bitnami.com/cluster-wide: "true"` matches the scope used during sealing
- Re-seal the secret with the correct scope

### Key rotation issues

If secrets fail to decrypt after rotation:
1. Verify the new key was applied to the cluster
2. Check that the controller was restarted
3. Ensure all sealed secrets were re-encrypted with the new key
