# 

## Encrypting vault file (ansible)

1. **Create and encrypt the vault file:**
   ```sh
   ansible-vault create ansible/vault.yml
   ```

   - Add your sensitive variables:
   ```yaml
   k3s_token: "YOUR_VERY_SECURE_CLUSTER_TOKEN"
   tailscale_auth_key: "tskey-auth-..."
   ```

2. **Modify your inventory file to use `vars_files`:**
   Replace the sensitive variables with a reference to the vault file.

   ```yaml
   # filepath: ansible/inventory.yml
   ---
   k3s_cluster:
     children:
       server:
         hosts:
           100.x.x.100:
             ansible_user: homelab-admin
       agent:
         hosts:
           100.x.x.200:
             ansible_user: root
     vars_files:
       - vault.yml
     vars:
       # --- Server Configuration ---
       k3s_extra_server_args: >-
         --cluster-init
         --tls-san={{ hostvars[groups['server']]['inventory_hostname'] }}
         --tls-san={{ kube_vip_address }}
         --node-external-ip={{ hostvars[groups['server']]['inventory_hostname'] }}
         --vpn-auth="name=tailscale,joinKey={{ tailscale_auth_key }}"
         --disable=traefik
         --disable=servicelb
         --write-kubeconfig-mode "644"
         --kube-apiserver-arg "default-not-ready-toleration-seconds=30"
         --kube-apiserver-arg "default-unreachable-toleration-seconds=30"
         --kubelet-arg "node-status-update-frequency=5s"
       # --- Agent Configuration ---
       k3s_extra_agent_args: >-
         --node-external-ip={{ inventory_hostname }}
         --vpn-auth="name=tailscale,joinKey={{ tailscale_auth_key }}"
         --kubelet-arg "node-status-update-frequency=5s"
       # --- Global Variables ---
       kube_vip_address: "192.168.70.100"
   ```

3. **Use your vault file with Ansible commands:**
   ```sh
   ansible-playbook -i ansible/inventory.yml playbook.yml --ask-vault-pass
   ```

   ```
## Run setup (ansible)

- decrypt the vault
```bash
ansible-playbook -i ansible/inventory.yml playbook.yml --ask-vault-pass
```
