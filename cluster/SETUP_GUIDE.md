# 🛠️ Step-by-Step Cluster Setup Guide

This guide walks you through bootstrapping your cluster using the GitOps workflow.

---

## 🏗️ Stage 1: Initial Host & CNI Setup
Establish the foundation of your cluster. These steps are manual and imperative.

### 1. Host Preparation (All Nodes)
Install essential packages and kernel modules.
```bash
sudo apt update && sudo apt install -y zfsutils-linux nfs-kernel-server cifs-utils open-iscsi
sudo modprobe iptable_raw xt_socket
echo -e "xt_socket\niptable_raw" | sudo tee /etc/modules-load.d/cilium.conf

# Install kubeseal CLI (for Secret management)
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.5/kubeseal-0.24.5-linux-amd64.tar.gz
tar -xvzf kubeseal-0.24.5-linux-amd64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
rm kubeseal-0.24.5-linux-amd64.tar.gz kubeseal
```

### 2. K3s Installation (Master Node)
```bash
export SETUP_NODEIP=192.168.10.171  # Update to your NUC IP
export SETUP_CLUSTERTOKEN=your-strong-token

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.33.6+k3s1" \
  INSTALL_K3S_EXEC="--node-ip $SETUP_NODEIP \
  --disable=flannel,local-storage,metrics-server,servicelb,traefik \
  --flannel-backend='none' \
  --disable-network-policy \
  --disable-cloud-controller \
  --disable-kube-proxy" \
  K3S_TOKEN=$SETUP_CLUSTERTOKEN \
  K3S_KUBECONFIG_MODE=644 sh -s - 

# Setup kubeconfig
mkdir -p $HOME/.kube && sudo cp -i /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config && chmod 600 $HOME/.kube/config
```

### 3. CNI Bootstrap (Cilium)
We install Cilium manually first so that pods can actually communicate.
```bash
helm repo add cilium https://helm.cilium.io && helm repo update
helm install cilium cilium/cilium -n kube-system \
  -f cluster/infrastructure/networking/cilium/values.yaml \
  --version 1.18.4 \
  --set operator.replicas=1
```

---

## 🔄 Stage 2: GitOps Setup (Argo CD)
Now we install the tool that will manage everything else.

### 1. Install CRDs & Argo CD
```bash
# Gateway API CRDs (Crucial!)
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/standard-install.yaml

# Sealed Secrets CRD (Prevent sync race conditions)
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm repo update
helm show crds sealed-secrets/sealed-secrets --version 2.18.0 | kubectl apply -f -

# Argo CD
kubectl create namespace argocd
kubectl kustomize --enable-helm cluster/infrastructure/controllers/argocd | kubectl apply -f - 
kubectl apply -f cluster/infrastructure/controllers/argocd/projects.yaml
```

---

## 📂 Stage 3: Repository Configuration
**THIS IS THE MOST IMPORTANT PART.** You must tell the cluster to look at **your** repo.

### 1. Update your files
Open these files and ensure the `repoURL` points to `https://github.com/ejsadiarin/core-k8s-homelab.git` and the `targetRevision` is `cluster`.

*   `cluster/infrastructure/infrastructure-components-appset.yaml`
*   `cluster/apps/myapplications-appset.yaml`
*   `cluster/monitoring/monitoring-components-appset.yaml`
*   `cluster/infrastructure/controllers/argocd/projects.yaml`

### 2. 🏁 First Git Commit Checkpoint
Now, push your configuration to GitHub so ArgoCD can see it.
```bash
git add .
git commit -m "feat: initial cluster configuration for ejsadiarin repo"
git push origin cluster
```

---

## 🔐 Stage 4: Cloudflare Integration and Manual Secrets

Secrets are not stored in Git. You must create them once manually.

### 1. DNS API Token (Cloudflare)

```bash
# REQUIRED BROWSER STEPS FIRST:
# Navigate to Cloudflare Dashboard:
# 1. Profile > API Tokens
# 2. Create Token
# 3. Use "Edit zone DNS" template
# 4. Configure permissions:
#    - Zone - DNS - Edit
#    - Zone - Zone - Read
# 5. Set zone resources to your domain
# 6. Copy the token and your Cloudflare account email

# Set credentials - NEVER COMMIT THESE!
export CLOUDFLARE_API_TOKEN="your-api-token-here"
export CLOUDFLARE_EMAIL="your-cloudflare-email"
export DOMAIN="yourdomain.com"
export TUNNEL_NAME="k3s-homelab-tunnel" # Must match cluster/infrastructure/networking/cloudflared/config.yaml
```

### 2. Setup Cloudflare Tunnel (for External Access)

**THIS IS ONLY DONE ONE-TIME**

First, generate the credentials locally (requires `cloudflared` installed).

```bash
# 1. Install cloudflared (if not installed)
# Linux: wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && sudo dpkg -i cloudflared-linux-amd64.deb
# macOS: brew install cloudflare/cloudflare/cloudflared

# 2. Authenticate & Create Tunnel
export TUNNEL_NAME="k3s-homelab-tunnel" # Must match cluster/infrastructure/networking/cloudflared/config.yaml
cloudflared tunnel login
cloudflared tunnel create $TUNNEL_NAME
cloudflared tunnel token --cred-file tunnel-creds.json $TUNNEL_NAME

# 3. Configure DNS (Wildcard)
export DOMAIN="yourdomain.com" # Replace with your domain
TUNNEL_ID=$(cloudflared tunnel list | grep $TUNNEL_NAME | awk '{print $1}')
cloudflared tunnel route dns $TUNNEL_ID "*.$DOMAIN"
cloudflared tunnel route dns $TUNNEL_ID "$DOMAIN" # Optional: Root domain
```

Now upload the credentials to the cluster:
```bash
kubectl create namespace cloudflared
kubectl create secret generic tunnel-credentials -n cloudflared \
  --from-file=credentials.json=tunnel-creds.json
```

Clean up
```bash
rm -v tunnel-creds.json && echo "Credentials file removed"
```


### 3. Certificate Management

- Create Secret for the `cloudflare-api-token`
```bash
kubectl create namespace cert-manager
kubectl create secret generic cloudflare-api-token -n cert-manager \
  --from-literal=api-token=$CLOUDFLARE_API_TOKEN \
  --from-literal=email=$CLOUDFLARE_EMAIL
```

- Verify secrets
```bash
kubectl get secret cloudflare-api-token -n cert-manager -o jsonpath='{.data.email}' | base64 -d
kubectl get secret cloudflare-api-token -n cert-manager -o jsonpath='{.data.api-token}' | base64 -d
```

---

## 🚀 Stage 5: Triggering the Sync

Now we tell Argo CD to start building the world based on your repo.

### 1. Deploy Infrastructure

```bash
kubectl apply -f cluster/infrastructure/infrastructure-components-appset.yaml -n argocd

```
*Wait ~5-10 minutes. Use `kubectl get pods -A` to see Cilium, Longhorn, and Cert-Manager coming online.*

**Critical: Wait for Sealed Secrets**
Ensure the Sealed Secrets controller is running and the CRD is established before proceeding, otherwise applications will fail to sync.
```bash
kubectl wait --for=condition=Available deployment -l app.kubernetes.io/name=sealed-secrets -n sealed-secrets --timeout=300s
```

### 2. Deploy Monitoring & Apps

- Deploy monitoring components
```bash
kubectl apply -f cluster/monitoring/monitoring-components-appset.yaml -n argocd

# wait for monitoring components to initialize (may take a few minutes)
kubectl wait --for=condition=Available deployment -l app.kubernetes.io/name=grafana -n kube-prometheus-stack --timeout=600s
kubectl wait --for=condition=Available deployment -l app.kubernetes.io/name=kube-state-metrics -n kube-prometheus-stack --timeout=600s
kubectl wait --for=condition=Ready statefulset -l app.kubernetes.io/name=prometheus -n kube-prometheus-stack --timeout=600s
```

- Deploy apps
```bash
kubectl apply -f cluster/apps/myapplications-appset.yaml -n argocd
```

---

## 📱 Stage 6: Deploying Your First App (Nginx)

To deploy an app, you follow the GitOps flow: **Code -> Commit -> Sync**.

1.  **Modify/Create the app folder:** (You already have `cluster/apps/nginx`)
2.  **Verify local changes:**
    ```bash
    git status
    ```
3.  **🏁 Git Commit Checkpoint:**
    ```bash
    git add cluster/apps/nginx
    git commit -m "feat: deploy nginx-example application"
    git push origin cluster
    ```
4.  **Watch Argo CD:**
    Go to your Argo CD UI (or run `kubectl get pods -n nginx-example`). Argo CD will detect the new commit and deploy the app automatically.

---

## 📝 Summary of "When to Commit"
*   **Commit when:** You change a YAML manifest (Deployment, Service, PVC).
*   **Commit when:** You add a new application folder to `cluster/apps/`.
*   **DO NOT Commit when:** You are creating a Kubernetes Secret (`kubectl create secret`).
*   **DO NOT Commit when:** You are running one-time install commands (`helm install`, `curl | sh`).

---

## Commands

**Port-forward ArgoCD web and get admin password**
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443

# get admin password
ARGO_PASS=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)
echo "Initial Argo CD password: $ARGO_PASS"

**Manually Sync an Application**
If an application is stuck or OutOfSync, you can force a sync:
```bash
# Example: Sync the gateway application
kubectl patch application gateway -n argocd --type merge -p '{"operation": {"sync": {"prune": true}}}'
```
```
