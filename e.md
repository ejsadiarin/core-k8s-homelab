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
**Solution:**
- Updated `HTTPRoute` manifests for `hello-world`, `nginx`, and `homepage-dashboard` to change `parentRefs` from `gateway-internal` to `gateway-external`.

## 2. Infrastructure: Gateway Stuck in "Pending"
**Timestamp:** 2025-12-18 14:28
**Problem:** `gateway-external` status remained `Pending` / `Waiting for controller`.
**Diagnosis:**
- Cilium Operator was running but not reconciling Gateway API resources.
- Suspect Gateway API CRDs were applied *after* Cilium installation, or Operator needed a restart to detect them.
**Solution:**
- Restarted Cilium Operator: `kubectl rollout restart deployment cilium-operator -n kube-system`.

## 3. Configuration: Gateway "AddressNotAssigned"
**Timestamp:** 2025-12-18 14:35
**Problem:** Gateway status `Programmed: False` with reason `AddressNotAssigned`.
**Diagnosis:**
- Gateway manifest requested static IP `192.168.10.171`.
- Cilium IPAM Pool (`main-pool`) was configured for `192.168.70.100/28`.
- The requested IP was not in the allowed pool range.
**Solution:**
- Removed the hardcoded `addresses` field from `gw-external.yaml` and `gw-internal.yaml`.
- Allowed Gateway to dynamically request an IP from the configured pool.

## 4. Stability: Cloudflared QUIC Timeouts
**Timestamp:** 2025-12-19 14:13
**Problem:** `cloudflared` pod logs showed repeated errors: `failed to dial to edge with quic: timeout`. Tunnel connection was unstable.
**Diagnosis:**
- Network environment (ISP or local firewall) was blocking or throttling UDP traffic required for QUIC protocol.
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
**Solution:**
- Renamed namespace in Longhorn manifests (`namespace.yaml`, `kustomization.yaml`, `httproute.yaml`) from `longhorn-system` to `longhorn` to align with the directory structure.

## 8. Infrastructure: Node Resource Exhaustion (Eviction)

**Timestamp:** 2025-12-20 17:23

**Problem:** Pods stuck in `Pending` or `Evicted`.

**Diagnosis:**
- Node `homelab` reported `DiskPressure: True`.
- Disk usage on root partition was 94%.
**Solution:**
- User performed disk cleanup (pruned images, logs).
- Restarted K3s service to refresh stats: `sudo systemctl restart k3s`.
- Deleted evicted pods to force rescheduling:
  ```bash
  kubectl delete pods --field-selector=status.phase=Failed -A
  ```

---

## 💡 Valuable Notes for Future

1.  **Argo CD Sidecar Resources:** When using `kustomize-build-with-helm` or any plugin, the sidecar needs significant memory (2Gi+) to render large charts like Prometheus, Longhorn, or Cilium due to CRD size.
2.  **Gateway API IPAM:** Ensure the Gateway's requested `addresses` match the `CiliumLoadBalancerIPPool` CIDR. If in doubt, remove the address request and let it allocate dynamically.
3.  **Cloudflare Tunnel Protocol:** If tunnel connectivity is flaky, always try `protocol: http2`. It's more robust against restrictive firewalls than the default QUIC.
4.  **AppSet Naming:** If using Argo CD ApplicationSets generating from folder names (`{{path.basename}}`), ensure the manifests inside use the **exact same namespace name**, or configure the AppSet to allow namespace overrides.
5.  **Single Node Longhorn:** For single-node clusters, always set `defaultClassReplicaCount: 1` and ensure `replica-soft-anti-affinity` is handled or irrelevant (1 replica).
6.  **Disk Pressure:** Monitor disk usage closely. Kubelet evicts pods aggressively at ~85% usage. `sudo k3s crictl rmi --prune` is your friend.
