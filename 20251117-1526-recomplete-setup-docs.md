## Architecture

* Tailscale for **node-to-node** communication
* Cilium for **pod-to-pod** communication
* Cloudflare Tunnel for public websites


* Has private services -> `*.local.ejsadiarin.com`

```
Private Traffic -> Traefik -> Service 
```

* Has public services -> `*.ejsadiarin.com`

```
Public Traffic -> Cloudflare Tunnel (cloudflared) -> Traefik -> Service 
```

## Prerequisites

- Tailscale
  * Here we use the `tailscale ip -4` for each node
    * Install `tailscale` for each node -> Authenticate via `tailscale login`
    * Get the IPv4 address of the node via `tailscale ip -4` (should be `100.X.X.X`)
    * Configure ACL:
      * ACL -> autoApprovers.routes
      * *From k3s docs*: If you have ACLs activated in Tailscale, you need to add an "accept" rule to allow pods to communicate with each other. Assuming the auth key you created automatically tags the Tailscale nodes with the tag testing-k3s, the rule should look like this:
        ```json
        "acls": [
          {
            "action": "accept",
            "src":    ["tag:testing-k3s", "10.42.0.0/16"],
            "dst":    ["tag:testing-k3s:*", "10.42.0.0/16:*"],
          },
        ],
        ```

- Cloudflare
  * own DNS
  * Configure API Token

## Installation

1. install using k3sup (see `initialize/` directory for scripts)
  * server/controlplane
    - on `first install`: for `--tls-san`, the VIP can be near the metallb pool (ex. 192.168.70.100-110 then VIP can be 192.168.70.99) 
      - `--tls-san` is a must for future HA setups
      > [!NOTE]
      > Get the `kubeconfig` at `/etc/rancher/k3s/k3s.yaml`
    - on `existing clusters`: install `kube-vip` first for HA virtual IP (to be put in `--tls-san`)
  * agent/worker node:
    - get `K3S_TOKEN` from: `/var/lib/rancher/k3s/server/node-token` (on the controlplane node)
    - get `joinKey` from Tailscale Dashboard -> Settings -> Keys -> Generate auth key...
```bash
# server (controlplane) - first install
# Get your Tailscale IP
TS_IP=$(tailscale ip -4)

# Run the K3s installer with these flags
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=" \
    --flannel-backend=none \
    --disable-kube-proxy \
    --node-ip=${TS_IP} \
    --bind-address=${TS_IP} \
    --advertise-address=${TS_IP}" \
    sh -
```

<!-- TODO: controlplane install with existing clusters already -->
- TODO: controlplane install with existing clusters already
```bash
# server (controlplane) - has existing cluster already
curl -sfL https://get.k3s.io | \
K3S_URL=https://<IP_OF_YOUR_FIRST_SERVER>:6443 \
K3S_TOKEN=<YOUR_K3S_JOIN_TOKEN> \
INSTALL_K3S_EXEC="server \
  --vpn-auth=name=tailscale,joinKey=<YOUR_TS_KEY> \
  --tls-san <YOUR_VIP_IP_FOR_HA> \
  --disable=traefik \
  --disable=servicelb" \
sh -
```

- agent installation
```bash
# agent
# Get the agent's Tailscale IP
TS_IP=$(tailscale ip -4)

# Get your K3s server token (from the server node)
K3S_TOKEN="YOUR_SERVER_TOKEN_HERE"

# Get your server's Tailscale IP (from Step 2)
SERVER_TS_IP="100.x.x.x"

# Run the agent installer
curl -sfL https://get.k3s.io | K3S_URL="https://{SERVER_TS_IP}:6443" \
    K3S_TOKEN="${K3S_TOKEN}" \
    INSTALL_K3S_EXEC=" \
    --flannel-backend=none \
    --disable-kube-proxy \
    --node-ip=${TS_IP}" \
    sh -
```

2. Install Cilium (CNI) - in `kube-system` namespace
- This is our `flannel` and `kube-proxy` replacement
- Must be installed before ArgoCD, so **one-time manual installation** is REQUIRED
```bash
helm install cilium cilium/cilium \
   --namespace kube-system \
   --set k3s.enabled=true \
   --set kubeProxyReplacement=true
```

3. Configure ArgoCD manifests (argocd-root-app.yaml & argocd-appset.yaml) 
  - Install ArgoCD CRD 
  ```bash
  kubectl create namespace argocd
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml 
  ```

  - Apply the root manifest for ArgoCD first
  ```bash
  kubectl apply -f ./cluster/bootstrap/argocd-root-app.yaml
  ```
  
  - Afterwards, everything will be applied via GitOps.
  - so push the `argocd-appset.yaml`
  ```bash
  git push origin main
  ```

  * To access the UI via `localhost:8080` do:
  ```bash
  kubectl port-forward svc/argocd-server -n argocd 8080:443
  ```
  * Get password for user `admin`:
  ```bash
  # NOTE: we run base64 decode to get the actual password
  kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
  ```


3. Configure core components (networking, certs, etc.) - `metallb-app.yaml`, `metallb-config.yaml`, `traefik-.yaml`, `cloudflared.yaml`
  * For this cluster, it is configured to expose 
  * Apply manifests via GitOps (`git push`) in this order: 
    * MetalLB (app) - `metallb-app.yaml`
    * MetalLB (config) - `metallb-config.yaml`

    * Cert-Manager (app) - `cert-manager-app.yaml`

    * Create a secret `cloudflare-secret.yaml` to be used in `letsencrypt-clusterissuer.yaml`:
      - **DO NOT COMMIT THIS TO GIT**
      ```yaml
      apiVersion: v1
      kind: Secret
      metadata:
        name: cloudflare-api-token-secret
        namespace: cert-manager     # <-- Must be in the cert-manager namespace
      stringData:
        api-token: "PASTE_YOUR_NEW_TOKEN_HERE" # <-- API Token from Cloudflare
      ```
      - then do: `kubectl apply -f cloudflare-secret.yaml`

    * Traefik (app) - `traefik-app.yaml`
    * Let's Encrypt ClusterIssuer - `letsencrypt-clusterissuer.yaml`
      > [!NOTE]
      > For `cert-manager`, we use `dns01` challenge with cloudflare since we will handle private/public traffic through wildcard subdomains 
      * For `dns01` challenge, we need to get an API Token with Zone permissions from Cloudflare (as our DNS provider)
      1. Go to Cloudflare dashboard -> Profile -> API Tokens -> Create custom token 
        - Set permissions: `Zone Zone Read` and `Zone DNS Edit`
        - Set zone resources: `Include - All zones` (if planning to add other domains) or `Include - Specific zone - your-domain.com`

    * Certificate (ejsadiarin-com) - `certificate-homelab.yaml`
    
    * Traefik (GatewayClass + Gateway) - `traefik-gateway.yaml`

    * Cloudflared (app) - `cloudflared.yaml`
      > [!NOTE]
      > Before deploying `cloudflared`, you should do the step below (step 4) first to configure the tunnel.


4. Install `cloudflared`, authenticate, and create tunnel token
  - Run the `./initialize/install-cloudflared-apt.sh` script
  - Authenticate
    ```bash
    cloudflared tunnel login
    ```

  - Create tunnel (`k3s-homelab-tunnel`)
    ```bash
    cloudflared tunnel create k3s-homelab-tunnel
    ```

  - Create `cloudflared` namespace
    ```bash
    kubectl create namespace cloudflared
    ```

  - Create `cloudflared` secret (`cloudflared-tunnel-secret-credentials`)
    ```bash
    kubectl create secret generic cloudflared-tunnel-secret-credentials \
    --from-file=credentials.json=$HOME/.cloudflared/<tunnel-id>.json \
    -n cloudflared
    ```

5. Expose the services via DNS Cloudflare Tunnel
  - can specify hostname or wildcard
  ```bash
  cloudflared tunnel route dns k3s-homelab-tunnel immich.your-domain.com
  cloudflared tunnel route dns k3s-homelab-tunnel "*.your-domain.com"
  ```
  > [!NOTE]
  > This will create a CNAME record on your Cloudflare `Domain` -> `Records` (see in your dashboard)
