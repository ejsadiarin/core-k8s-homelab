# Implementation Plan: Single-Node K3s + Cilium (GitOps)

## 1. Architecture Decisions

### **Compute & OS**

*   **Nodes:** 1 (Single Node Cluster).
    *   *Role:* Acts as both Control Plane and Worker.
*   **OS:** Linux (Debian/Ubuntu implied)
*   **Network Transport:** **Standard Host Network** (Physical IP).
    *   *Simplicity:* No VPN overlays, no MTU hacks, no routing complexity.

### **Kubernetes Core**

*   **Distribution:** **K3s**
    *   *Flags:* `--flannel-backend=none` (for Cilium), `--disable-kube-proxy` (for Cilium), `--disable=traefik`, `--disable=servicelb`.
*   **CNI (Networking):** **Cilium**
    *   *Mode:* Kube-proxy replacement enabled.
    *   *Feature:* **Gateway API** enabled (for public ingress via Cloudflare).

### **Access & Ingress**

*   **Public Access:** **Cloudflare Tunnel** (`cloudflared`) -> Cilium Gateway.
    *   Traffic Flow: User -> Cloudflare -> `cloudflared` (pod) -> Cilium Gateway (Service) -> App.

### **GitOps**

*   **Tool:** **ArgoCD**
*   **Structure:** App of Apps pattern (`cluster/bootstrap`).

---

## 2. Proposed File Structure

```text
cluster/
├── bootstrap/              # ArgoCD Entrypoints
│   ├── argocd-appset.yaml  
│   ├── argocd-root-app.yaml
│   └── argocd-ui.yaml      
├── core/                   # Infrastructure Apps
│   ├── cilium/             
│   ├── cert-manager/       
│   ├── cloudflared/        
│   └── namespaces/         
├── apps/                   
```

---

## 3. Implementation Steps

### Phase 1: Clean Slate

1.  **Uninstall:** `k3s-uninstall.sh` (and `k3s-agent-uninstall.sh` if previously installed).
2.  **Cleanup:** `rm -rf /etc/cni/net.d /var/lib/rancher /var/lib/kubelet`.
3.  **Reboot:** `sudo reboot` (Highly recommended to flush network interfaces).

### Phase 2: Cluster Bootstrap (Manual)

1.  **Install K3s Server:**
    *   *Note:* Replace `<HOST_IP>` with your machine's main IP (e.g., `192.168.x.x` or Public IP).
    ```bash
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
      --flannel-backend=none \
      --disable-kube-proxy \
      --disable=traefik \
      --disable=servicelb \
      --node-ip=<HOST_IP> \
      --advertise-address=<HOST_IP>" sh -
    ```
    *   *Kubeconfig Location:* `/etc/rancher/k3s/k3s.yaml`. Copy this to your local machine.
        *   **Local Setup:** `mkdir -p ~/.kube && scp <USER>@<HOST_IP>:/etc/rancher/k3s/k3s.yaml ~/.kube/config && chmod 600 ~/.kube/config`. Edit `~/.kube/config` and replace `127.0.0.1` with `<HOST_IP>`.

2.  **Install Cilium CLI & Chart:**
    *   *Standard Install:* No hacks required.
    ```bash
    helm repo add cilium https://helm.cilium.io/
    helm repo update

    helm install cilium cilium/cilium \
       --namespace kube-system \
       --version 1.18.4 \
       --set k3s.enabled=true \
       --set kubeProxyReplacement=true \
       --set k8sServiceHost=192.168.10.171 \
       --set k8sServicePort=6443 \
       --set ipam.mode=kubernetes \
       --set gatewayAPI.enabled=true \
       --set hubble.enabled=true \
       --set hubble.relay.enabled=true \
       --set hubble.ui.enabled=true
    ```

### Phase 3: GitOps Initialization

1.  **Install ArgoCD:**
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

2.  **Apply Root App:**
    - IMPORTANT: wait until all pods are ready and "Status: Running"
```bash
kubectl apply -f cluster/bootstrap/argocd-root-app.yaml
```
    *   *Action:* Ensure your git repo's `cluster/core/cilium/app.yaml` matches the standard settings (remove any `mtu: 1200` or `devices: tailscale0` lines you might have added earlier).

### Phase 4: Migration

1.  **Cloudflare:** Setup secrets for public tunnel.
2.  **Apps:** Deploy your applications via ArgoCD.

---

## 4. Todo List

- [ ] **Uninstall & Reboot.**
- [ ] **Install K3s (Single Node).**
- [ ] **Install Cilium.**
- [ ] **Bootstrap ArgoCD.**
