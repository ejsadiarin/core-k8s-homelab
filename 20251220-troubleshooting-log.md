# 🛠️ Kubernetes Homelab Troubleshooting Log

**Date:** December 18-20, 2025
**Cluster:** Single-node K3s (NUC)
**Key Components:** Cilium, Argo CD, Cloudflare Tunnel, Longhorn, Kube-Prometheus-Stack

---

## 1. Connectivity: Cloudflare Tunnel Error 1033

**Timestamp:** 2025-12-18 14:00

**Problem:** Applications (`hello-world`, `nginx`) accessible via `kubectl port-forward` but failing with `Error 1033: Argo Tunnel error` when accessed via public subdomains.

**Diagnosis:**
- `cloudflared` was configured to route traffic to the **Gateway External** service (`cilium-gateway-gateway-external`).
- Applications' `HTTPRoute` manifests were attached to `gateway-internal`.
- Traffic flow was broken: Cloudflare -> Tunnel -> Gateway External (No Routes) -> 404/Error.

**Diagnosis Steps:**

1.  **Checked Tunnel Config:** Read `cluster/infrastructure/networking/cloudflared/config.yaml`. Found it pointing to `https://cilium-gateway-gateway-external...`.

2.  **Checked App Routes:** Read `cluster/apps/hello-world/http-route.yaml`.
    ```bash
    kubectl get httproute hello-world -n hello-world -o yaml
    ```
    * Found `parentRefs` pointing to `gateway-internal`.

3.  **Conclusion:** Traffic flow mismatch. Tunnel sends to External Gateway, App listens on Internal Gateway.

**Solution:**
- Updated `HTTPRoute` manifests for `hello-world`, `nginx`, and `homepage-dashboard` to change `parentRefs` from `gateway-internal` to `gateway-external`.

## 2. Infrastructure: Gateway Stuck in "Pending"

**Timestamp:** 2025-12-18 14:28

**Problem:** `gateway-external` status remained `Pending` / `Waiting for controller`.

**Diagnosis:**
- Cilium Operator was running but not reconciling Gateway API resources.
- Suspect Gateway API CRDs were applied *after* Cilium installation, or Operator needed a restart to detect them.

**Diagnosis Steps:**

1.  **Checked Gateway Status:**
    ```bash
    kubectl get gateway gateway-external -n gateway -o yaml
    ```
    * Status: `Pending`. Message: `Waiting for controller`.

2.  **Checked Cilium Logs:**
    ```bash
    kubectl -n kube-system logs -l name=cilium-operator
    ```
    * No logs related to Gateway API reconciliation found, suggesting it wasn't watching the resources.

**Solution:**
- Restarted Cilium Operator: `kubectl rollout restart deployment cilium-operator -n kube-system`.

## 3. Configuration: Gateway "AddressNotAssigned"

**Timestamp:** 2025-12-18 14:35

**Problem:** Gateway status `Programmed: False` with reason `AddressNotAssigned`.

**Diagnosis:**
- Gateway manifest requested static IP `192.168.10.171`.
- Cilium IPAM Pool (`main-pool`) was configured for `192.168.70.100/28`.
- The requested IP was not in the allowed pool range.

**Diagnosis Steps:**
1.  **Described Gateway:**
    ```bash
    kubectl describe gateway gateway-external -n gateway
    ```
    * Status: `False`. Reason: `AddressNotAssigned`.

2.  **Checked IP Pool:**
    ```bash
    kubectl get ciliumloadbalancerippool main-pool -o yaml
    ```
    * Pool CIDR: `192.168.70.100/28`.

3.  **Checked Gateway Spec:**
    * Gateway requested IP: `192.168.10.171`.

4.  **Conclusion:** Requested IP was outside the allowed pool range.

**Solution:**
- Removed the hardcoded `addresses` field from `gw-external.yaml` and `gw-internal.yaml`.
- Allowed Gateway to dynamically request an IP from the configured pool.

## 4. Stability: Cloudflared QUIC Timeouts

**Timestamp:** 2025-12-19 14:13

**Problem:** `cloudflared` pod logs showed repeated errors: `failed to dial to edge with quic: timeout`. Tunnel connection was unstable.

**Diagnosis:**
- Network environment (ISP or local firewall) was blocking or throttling UDP traffic required for QUIC protocol.

**Diagnosis Steps:**

1.  **Checked Pod Logs:**
    ```bash
    kubectl logs -n cloudflared -l app=cloudflared --tail=50
    ```
    * Log output: `ERR Failed to dial a quic connection ... timeout: no recent network activity`.

2.  **Reasoning:** QUIC uses UDP. If UDP is blocked or throttled (common in some networks/ISPs), the tunnel fails.
**Solution:**
- Forced HTTP2 (TCP) protocol in `cloudflared` config:
  ```yaml
  protocol: http2
  ```

## 5. Deployment: Argo CD OOM on Large Charts

**Timestamp:** 2025-12-20 07:42

**Problem:** `longhorn` and `kube-prometheus-stack` applications stuck in `Unknown` state.

**Error:** `rpc error: code = Unknown desc = error generating manifests ... failed signal: killed`

**Diagnosis:**
- Argo CD Repo Server sidecar (`kustomize-build-with-helm`) was running out of memory (OOM) while rendering the massive CRDs for Longhorn and Prometheus.
- Default resources were insufficient.

**Diagnosis Steps:**

1.  **Checked Application Status:**
    ```bash
    kubectl get application longhorn -n argocd -o yaml
    ```
    * Status Message: `rpc error: code = Unknown desc = error generating manifests ... failed signal: killed`.

2.  **Analyzed "Signal Killed":** In Kubernetes, "Signal Killed" (SIGKILL) during a process execution usually implies OOM (Out Of Memory) Killer.

3.  **Checked Argo Config:** Reviewed `values.yaml` for `argocd`. Found `repoServer` had limits, but the sidecar `kustomize-build-with-helm` had **no** explicit resources defined, likely defaulting to low limits or starving.

**Solution:**
- Increased memory limits for the Argo CD Repo Server sidecar in `values.yaml`:
  ```yaml
  repoServer:
    extraContainers:
      - name: kustomize-build-with-helm
        resources:
          limits:
            memory: "2Gi"
  ```

## 6. Configuration: Longhorn Helm Template Error

**Timestamp:** 2025-12-20 08:18

**Problem:** Longhorn failed to render manifest: `defaultSettings.guaranteedInstanceManagerCPU must be a string`.

**Diagnosis:**
- `values.yaml` contained an integer `5`.
- Helm chart strict typing required a string `"5"`.

**Diagnosis Steps:**

1.  **Checked App Status (Again):**
    ```bash
    kubectl get application longhorn -n argocd -o yaml
    ```
    * New Error Message: `Error: execution error at (longhorn/templates/default-setting.yaml:257:8): defaultSettings.guaranteedInstanceManagerCPU must be a string`.

2.  **Checked Values File:** Checked `cluster/infrastructure/storage/longhorn/values.yaml`. Found `guaranteedInstanceManagerCPU: 5` (Integer).

**Solution:**
- Quoted the value in `values.yaml`:
  ```yaml
  guaranteedInstanceManagerCPU: "5"
  ```

## 7. GitOps: Longhorn Namespace Mismatch

**Timestamp:** 2025-12-20 09:04

**Problem:** Sync failed with `error getting namespace longhorn: namespaces "longhorn" not found`.

**Diagnosis:**
- Argo CD AppSet named the application `longhorn` (based on folder name), setting destination namespace to `longhorn`.
- Manifests inside the folder were configured for `longhorn-system`.
- Argo CD tried to reconcile RBAC for the App destination (`longhorn`), which didn't exist.

**Diagnosis Steps:**

1.  **Forced Sync:**
    ```bash
    kubectl patch application longhorn -n argocd --type merge -p '{"operation": {"sync": {"prune": true}}}'
    ```

2.  **Checked Sync Error:**
    ```bash
    kubectl get application longhorn -n argocd -o jsonpath='{.status.conditions}'
    ```
    * Message: `error running kubectl auth reconcile: error getting namespace longhorn: namespaces "longhorn" not found`.

3.  **Analyzed Mismatch:**
    - AppSet generates App named `longhorn` -> Destination Namespace: `longhorn`.
    - Manifests in `cluster/infrastructure/storage/longhorn` defined Namespace: `longhorn-system`.
    - Argo CD attempted to reconcile RBAC for namespace `longhorn` (which didn't exist).

**Solution:**
- Renamed namespace in Longhorn manifests (`namespace.yaml`, `kustomization.yaml`, `httproute.yaml`) from `longhorn-system` to `longhorn` to align with the directory structure.

## 8. Infrastructure: Node Resource Exhaustion (Eviction)

**Timestamp:** 2025-12-20 17:23

**Problem:** Pods stuck in `Pending` or `Evicted`.

**Diagnosis:**
- Node `homelab` reported `DiskPressure: True`.
- Disk usage on root partition was 94%.

**Diagnosis Steps:**
1.  **Checked Pod Status:**
    ```bash
    kubectl get pods -n longhorn
    ```
    * Status: `Evicted` and `Pending`.
2.  **Checked Node Conditions:**
    ```bash
    kubectl describe node homelab | grep -E "MemoryPressure|DiskPressure"
    ```
    * Output: `DiskPressure True`.
3.  **Checked Disk Usage:**
    ```bash
    ssh user@node "df -h /"
    ```
    * Usage was **94%**.

**Solution:**
- User performed disk cleanup (pruned images, logs).
- Restarted K3s service to refresh stats: `sudo systemctl restart k3s`.
- Deleted evicted pods to force rescheduling:
  ```bash
  kubectl delete pods --field-selector=status.phase=Failed -A
  ```

## 9. Deployment: Prometheus Adapter API Version Mismatch

**Timestamp:** 2025-12-21 05:37

**Problem:** `prometheus-adapter` application failed to sync with a `SyncFailed` error on the `APIService` resource.

**Diagnosis:** The Helm chart was attempting to use `apiregistration.k8s.io/v1beta1` for the `APIService` object, which is removed in newer Kubernetes versions (K3s 1.32+). Even with a modern chart version, the Kustomize-Helm rendering environment failed to detect the correct API capabilities.

**Diagnosis Steps:**
1.  **Checked App Status:**
    ```bash
    kubectl describe application prometheus-adapter -n argocd
    ```
2.  **Read Error:** `The Kubernetes API could not find version "v1beta1" of apiregistration.k8s.io/APIService for requested resource... Version "v1" is installed.`

**Solution:**
- Added a Kustomize patch to `kustomization.yaml` to force the `apiVersion` to `apiregistration.k8s.io/v1` for the `APIService` resources.

## 10. Stability: Prometheus Adapter CrashLoopBackOff (OOM)

**Timestamp:** 2025-12-21 06:47

**Problem:** `prometheus-adapter` pod in `CrashLoopBackOff` state.

**Diagnosis:** The pod was being OOMKilled (Exit Code 137). The default memory limit (128Mi) and a second attempt (256Mi) were insufficient for the adapter to cache the large volume of metrics from Prometheus on this node.

**Diagnosis Steps:**
1.  **Checked Pod Events:**
    ```bash
    kubectl describe pod -n kube-prometheus-stack -l app.kubernetes.io/name=prometheus-adapter
    ```
2.  **Observed Termination:** `Last State: Terminated, Reason: Error, Exit Code: 137`.

**Solution:**
- Increased memory limit to `512Mi` in the adapter's `values.yaml`.

## 11. GitOps: Persistent "OutOfSync" on HTTPRoutes

**Timestamp:** 2025-12-21 08:00

**Problem:** Applications (nginx, argocd, hello-world) remained in `OutOfSync` state despite being healthy and Synced.

**Diagnosis:** The Cilium Gateway controller dynamically updates the `/status` field of `HTTPRoute` objects. Argo CD interprets these controller-managed updates as "drift" from the Git state.

**Diagnosis Steps:**
1.  **Checked App Resources:**
    ```bash
    kubectl get application nginx -n argocd -o jsonpath='{.status.resources[?(@.status=="OutOfSync")]}'
    ```
2.  **Observed Resource:** Only the `HTTPRoute` was flagged as `OutOfSync`.

**Solution:**
- Added a global `ignoreDifferences` rule for `gateway.networking.k8s.io/HTTPRoute` in Argo CD's `values.yaml` to ignore the `/status` JSON pointer.

## 12. GitOps: ApplicationSet Configuration Drift

**Timestamp:** 2025-12-21 05:23

**Problem:** Newly added applications (like `prometheus-adapter`) were not appearing in Argo CD even after pushing the directories to Git.

**Diagnosis:** The `ApplicationSet` resources themselves were not managed by Argo CD. Changes to the AppSet YAML files in Git were not being applied to the cluster automatically, meaning the "Git Generator" was stuck using the old directory list.

**Diagnosis Steps:**
1.  **Checked AppSet Status:**
    ```bash
    kubectl describe applicationset monitoring-components -n argocd
    ```
2.  **Observed Spec:** The `Spec.Generators.Git.Directories` list in the cluster was missing the new paths present in the local repository.

**Solution:** Manually reapplied the AppSet manifests using `kubectl apply -f cluster/monitoring/monitoring-components-appset.yaml` to synchronize the generator logic.

## 13. Deployment: Homepage Dashboard "mkdir /app/config/logs" Error

**Timestamp:** 2025-12-21 06:10

**Problem:** `homepage-dashboard` pod failed to start with `Error: ENOENT: no such file or directory, mkdir '/app/config/logs'`.

**Diagnosis:** The dashboard configuration was mounted as a read-only ConfigMap at `/app/config`. The application attempts to create a `logs` directory within that same path on startup, which is impossible on a read-only volume.

**Diagnosis Steps:**
1.  **Checked Pod Logs:**
    ```bash
    kubectl logs -n homepage-dashboard <pod-name>
    ```
2.  **Observed Trace:** Node.js error pointing to a `mkdirSync` failure at `/app/config/logs`.

**Solution:** Implemented an **Init Container pattern**. The ConfigMap is now mounted to a temporary source path, and an init container copies the files to a writable `emptyDir` mounted at `/app/config` before the main application starts.

## 14. Infrastructure: Sticky Service Annotations on Gateways

**Timestamp:** 2025-12-21 07:15

**Problem:** `gateway-internal` and `external` remained in `Pending` state even after the IP pool was fixed.

**Diagnosis:** The `Service` objects of type `LoadBalancer` created by the Cilium Gateway controller still had the `io.cilium/lb-ipam-ips` annotation pointing to the old, invalid hardcoded IP. The controller did not automatically update or remove the annotation when the Gateway manifest changed.

**Diagnosis Steps:**
1.  **Described Services:**
    ```bash
    kubectl describe svc cilium-gateway-gateway-internal -n gateway
    ```
2.  **Observed Annotations:** Found `io.cilium/lb-ipam-ips: 192.168.10.171` still present.

**Solution:** Manually deleted the LoadBalancer services. The Gateway controller immediately recreated them without the stale annotations, allowing them to pull valid IPs from the new LAN pool.

## 15. Deployment: AdGuard Home Web UI Inaccessible

**Timestamp:** 2025-12-21 10:21

**Problem:** `curl http://localhost:3000` on the host returned `Connection reset by peer` even though the port was listening.

**Diagnosis:** AdGuard Home's internal configuration defaulted the web interface to port 80, but the Docker Compose file was mapping host `3000` to container `3000`. The connection was reset because nothing was listening on port 3000 inside the container.

**Diagnosis Steps:**
1.  **Checked Host Ports:** `netstat -tulpn` showed Docker proxy listening on 3000.
2.  **Checked Container Logs:**
    ```bash
    docker compose logs adguardhome
    ```
3.  **Observed Output:** `[info] go to http://127.0.0.1:80`.

**Solution:** Updated `AdGuardHome.yaml` to explicitly set the `http.address` to `0.0.0.0:3000` to match the expected port mapping.

## 16. Deployment: Glance Application Sync Failure

**Timestamp:** 2026-01-10 16:35

**Problem:** `glance` application stuck in `Unknown` sync status in ArgoCD.

**Error:** `rpc error: code = Unknown desc = error generating manifests ... lstat .../cluster/apps/glance/namespace.yaml: no such file or directory`

**Diagnosis:**
- Argo CD failed to generate manifests for the `glance` application.
- The error message clearly indicated that `kustomization.yaml` was referencing `namespace.yaml`, but the file was missing from the repository.

**Diagnosis Steps:**
1.  **Checked Application Status:**
    ```bash
    kubectl get application glance -n argocd -o yaml
    ```
    * Status Message confirmed the missing file error.

2.  **Verified Directory Content:**
    * Checked `cluster/apps/glance/` and confirmed `namespace.yaml` was missing.

**Solution:**
- Created the missing `cluster/apps/glance/namespace.yaml` file.
- Committed and pushed the changes to the `cluster` branch.
- Argo CD automatically picked up the change and synced the application.

---

## 💡 Valuable Notes for Future

1.  **Argo CD Sidecar Resources:** When using `kustomize-build-with-helm` or any plugin, the sidecar needs significant memory (2Gi+) to render large charts like Prometheus, Longhorn, or Cilium due to CRD size.

2.  **Gateway API IPAM:** Ensure the Gateway's requested `addresses` match the `CiliumLoadBalancerIPPool` CIDR. If in doubt, remove the address request and let it allocate dynamically.

3.  **Cloudflare Tunnel Protocol:** If tunnel connectivity is flaky, always try `protocol: http2`. It's more robust against restrictive firewalls than the default QUIC.

4.  **AppSet Naming:** If using Argo CD ApplicationSets generating from folder names (`{{path.basename}}`), ensure the manifests inside use the **exact same namespace name**, or configure the AppSet to allow namespace overrides.

5.  **Single Node Longhorn:** For single-node clusters, always set `defaultClassReplicaCount: 1` and ensure `replica-soft-anti-affinity` is handled or irrelevant (if 1 replica `defaultClassReplicaCount: 1` is set).

6.  **Disk Pressure:** Monitor disk usage closely. Kubelet evicts pods aggressively at ~85% usage. `sudo k3s crictl rmi --prune` is your friend.

7.  **API Version Hardening:** When rendering Helm charts via Kustomize in Argo CD, be prepared to use `patches` to fix deprecated `apiVersion` fields that the renderer might miss.

8.  **Status Drift:** For Gateway API or other dynamic controllers, proactively add `ignoreDifferences` for `/status` fields in Argo CD to avoid dashboard noise.

9.  **Init Container for Config:** When using read-only ConfigMaps for applications that need to write to their config directory (like Homepage or AdGuard), use an init container to copy the config to a writable `emptyDir`.


