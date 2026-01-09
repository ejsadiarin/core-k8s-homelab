# 💾 Storage Verification Guide

This guide details how to verify the persistence and behavior of your Kubernetes storage classes: **Longhorn** and **Local-Path**.

## 1. Prerequisites

Ensure the following changes have been synced by Argo CD:

- **Nginx** is deployed with `longhorn` storage (`nginx-storage` PVC).
- **Hello World** is deployed with `local-path` storage (`hello-world-local` PVC).

Check sync status:

```bash
kubectl get pods -n nginx
kubectl get pods -n hello-world
kubectl get pvc -n nginx
kubectl get pvc -n hello-world
```

---

## 2. Testing Longhorn Persistence (Block Storage)

**Goal:** Verify data survives pod deletion and moves across nodes (if multi-node).

1.  **Write Data:**
    Create a custom index file in the Nginx web root.

    ```bash
    # Get the pod name
    POD=$(kubectl get pod -n nginx -o jsonpath="{.items[0].metadata.name}")

    # Write a file
    kubectl exec -n nginx $POD -- sh -c "echo 'Persistence Verified: Longhorn' > /usr/share/nginx/html/index.html"
    ```

2.  **Verify Access:**
    Check if the file is served correctly.

    ```bash
    curl -k https://nginx.ejsadiarin.com
    # Expected Output: Persistence Verified: Longhorn
    ```

3.  **Kill the Pod:**
    Delete the pod to force a restart (and potentially reschedule).

    ```bash
    kubectl delete pod -n nginx $POD
    ```

4.  **Verify Persistence:**
    Wait for the new pod to be `Running`, then check the file again.

    ```bash
    # Wait for new pod
    kubectl wait --for=condition=Ready pod -l app=nginx -n nginx --timeout=60s

    # Verify file still exists
    curl -k https://nginx.ejsadiarin.com
    # Expected Output: Persistence Verified: Longhorn
    ```

---

## 3. Testing Local-Path Persistence (HostPath)

**Goal:** Verify data persists on the specific node's disk.

1.  **Write Data:**

    ```bash
    # Get the pod name
    POD=$(kubectl get pod -n hello-world -o jsonpath="{.items[0].metadata.name}")

    # Write a file to the mounted volume
    kubectl exec -n hello-world $POD -- sh -c "echo 'Persistence Verified: Local-Path' > /data/test.txt"
    ```

2.  **Kill the Pod:**

    ```bash
    kubectl delete pod -n hello-world $POD
    ```

3.  **Verify Persistence:**
    Wait for the new pod to start. **Note:** Since `local-path` is bound to a specific node, the pod _must_ be scheduled on the same node to access the data.

    ```bash
    # Get new pod name
    NEW_POD=$(kubectl get pod -n hello-world -o jsonpath="{.items[0].metadata.name}")

    # Read the file
    kubectl exec -n hello-world $NEW_POD -- cat /data/test.txt
    # Expected Output: Persistence Verified: Local-Path
    ```

---

## 4. Testing Limits (The "Full Disk" Test)

**Goal:** Demonstrate the difference between Block Storage enforcement and Local Path leniency.

### A. Longhorn Limit Enforcement

Your Nginx PVC is size `1Gi`. Let's try to write `1.2Gi`.

```bash
POD=$(kubectl get pod -n nginx -o jsonpath="{.items[0].metadata.name}")

# Try to create a 1.2GB file
kubectl exec -n nginx $POD -- dd if=/dev/zero of=/usr/share/nginx/html/largefile bs=1M count=1200
```

**Expected Result:**

> `dd: error writing '/usr/share/nginx/html/largefile': No space left on device`
> Only ~1Gi will be written. The application is strictly limited.

### B. Local-Path Limit Leniency

Your Hello World PVC is size `128Mi`. Let's try to write `200Mi`.

```bash
POD=$(kubectl get pod -n hello-world -o jsonpath="{.items[0].metadata.name}")

# Try to create a 200MB file (exceeding the 128Mi request)
kubectl exec -n hello-world $POD -- dd if=/dev/zero of=/data/largefile bs=1M count=200
```

**Expected Result:**

> The command usually **SUCCEEDS**.
> The `128Mi` limit is for scheduling only. Unless project quotas are enabled on the host OS, the pod can use as much disk space as the node has available.

---

## 5. Cleanup

Remove the large test files to free up space.

```bash
# Clean Nginx
kubectl exec -n nginx $(kubectl get pod -n nginx -o jsonpath="{.items[0].metadata.name}") -- rm /usr/share/nginx/html/largefile

# Clean Hello World
kubectl exec -n hello-world $(kubectl get pod -n hello-world -o jsonpath="{.items[0].metadata.name}") -- rm /data/largefile
```

---

## 6. FAQ

### Q: Does `resources.requests.storage` immediately reserve space on the node?

**Short Answer: No.** Both storage classes use **Thin Provisioning**.

- **Longhorn:** Creates a virtual block device. It takes up ~0 bytes initially and grows as you write data.
- **Local-Path:** Creates a simple directory on the host. It takes up 0 bytes initially and grows as you add files.

### Q: What happens if I exceed the requested volume size?

It depends on the storage class:

**A. Longhorn (Block Storage)**

- **Behavior:** The write operation will **FAIL** with "No space left on device".
- **Reason:** Longhorn enforces a hard limit matching your request (e.g., 1Gi) at the filesystem level.

**B. Local-Path (HostPath)**

- **Behavior:** The write operation will likely **SUCCEED** (Dangerous).
- **Reason:** Without advanced OS-level quotas, the pod is just writing to a directory on the host. It can potentially fill up the entire node's disk, regardless of the PVC limit.
- **Note:** The PVC limit is mainly used by Kubernetes for _scheduling_ decisions, not enforcement.
