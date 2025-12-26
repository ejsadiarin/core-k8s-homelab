November 1, 2025 
- start
- use gemini deep research for the setup docs
  - **insert first prompt here**
- refined backup script, immich pics
- v1 docs
- goal: k3s, migrate existing docker-based homelab, just wanna migrate immich, GITOPS (argocd vs flux, went with argocd for the UI and beginner-friendly)

November 2-7, 2025
- reiterate on the plan
- keep prompting and researching
- HELMMMMMM
- mostly got sidetracked by my dotfiles and neovim configs because I WANT THE OPTIMAL YAML/DEVOPS setuip
  - lspconfig, schemastore conflicts
  - yaml-companion is archived nooooooo
  - eventually just settled with adding schemas in yamlls in lspconfig itself
  - ALSO the yaml-language-server schema at top of file
    - made cute little snippet:
    ```snippets
    snippet ini specify a schema
      # yaml-language-server: \$schema=${1}
    ```
- got lazy for a while (analysis-paralysis hits hard as fuck)
- stumbled upon ansible-based k3s from timmy/tom and k3s-ansible
  - went with timmy/tom ansible (configured with kube-vip, metallb, etc. fast)
- researched `kube-vip` and moving parts in that ansible
- gemini deep research literally crashed and made my laptop hang/freeze
  - can't handle all that thinking lmao
- v2 docs (deleted it though)

November 8, 2025
- tried installing it via ansible, got error
  - got crictl error
  - sudo perms error, had to edit `visudo` with `NOPASSWD` for my user only of course
- reiterate again, and again, and again
- got lazy and hopeless
- tried k3s-ansible, some obscure error
- dantree.io/CRD-catalog is a life saver for schemas for yaml-language-server (cause i use neovim btw)
- v3 docs

November 9-10, 2025
- fuck this, ill just install via k3sup
  - it worked yes finally (atleast for the server/controlplane)
- now lets research how to do gitops with argocd... gemini help me 
- but then... for the agent/worker node, there were errors
  - the FIREWALL (but i have no firewall on my worker node though) 
- cloudflared
  - realized i need to manually configure it first
  - boom cloudflare api token, tunnel logins, etc.
- what if tailscale?
- v4 docs with cloudflare setup

2025-11-11-1902 (November 7, 2025 07:02:52 PM): 
- KUBECTL
- argocd UI yay so nice
- upped metallb finally
  - OutOfSync !!!!!!! of courseeeeeee
  - speaker pod on `node-1` isn't working - status 502: Bad Gateway
  - but the argocd controller notif running on there is working though
- i realized networking part for controlplane->worker is not working (*pun intended*) properly
  - can't connect to ports
  - maybe firewall?
- then here comes the REINSTALL ARC

2025-11-11-2051 (November 11, 2025 08:51:47 PM): 
- so i reinstalled like 4-5 or 6-7 times
  - until i just went and used the curl installation.
- researched i needed to configure traefik properly 
  - Gateway API vs Ingress vs IngressRoute
    - went with Gateway because its the FUTURE (we run things out of hype here ok?)
    - i mean Ingress is being "frozen"
- i realized i want to segregate private/public traffic and services
- cloudflared more setup - went from `http01` challenge to `dns01` challenge
- had running parts, but CRASHLOOPBACKOFF of courseeeeeee 
  - realized kubernetes is sooooooooooooo hehe, i wanna give up 
  - huge career crisis as always, should i just pivot to pure SWE?
    - realized i like, no, LOVE automation and devops so yeah no choice i stay here
- realized i needed proper certs, so `cert-manager` rabbit-hole it is.

2025-11-11-2230 (November 11, 2025 10:30:31 PM): 
- checked k3s docs (networking, multi-cloud setup)
- maybe `sudo modprobe ip_vs` isn't configured on the agent/worker node?
  - doesn't matter
- checked iptable entries
- let's just install `ufw` and add the necessary ports
- maybe i need a flannel-backend compatible with tailscale IPs (most likely wireguard-native)?
- saw there's a literal tailscale integration with k3s (experimental though)
  - i mean, i wanted just the tailscale ip with its native integration with k3s though (idk why, dumbass me strikes again)
  - edit ACL, configured ts-auth-key, autoApprovers, tags
- so I REINSTALLED AGAIN, tear everything down again, start from scratch while doing docs
- just need `--vpn-auth` with a `joinKey`
  - it preserves the existing tailscale ip (if you manually configured tailscale on your machine before)
  - tried adding the flag through `/etc/rancher/k3s/config.yaml`, then reload via systemd
    - didn't work as expected, `kubectl get nodes -A -o wide` shows old Internal IP (not from tailscale)
      - maybe old cache data?
      - eh let's just REINSTALL, everything, again.

2025-11-11-2302 (November 11, 2025 11:02:52 PM): 
- its working!!! atleast the networking part (controlplane + agent setup)
  - just needed to use tailscale with its --vpn-auth PROPERLY

now im here 2025-11-12-0000 (November 12, 2025 12:00:01 AM)
- up cert-manager
  - boom another problem: Failed to load target state: failed to generate manifest for source 1 of 1: rpc error: code = Unknown desc = failed to resolve revision "v1.19.1": cannot get digest for revision v1.1 │ │ 9.1: HEAD "https://quay.io/v2/jetstack/charts/manifests/v1.19.1": response status code 401: Unauthorized
  - lets just use charts.jetstack.io

2025-11-12-0124 (November 12, 2025 01:24:03 AM)
- syncwave supremacy
- upped traefik, cert-manager components properly
- upped traefik-gateway
  - realized i have existing traefik running in the same machine
    - so theres entrypoint/port conflict
    ```logs
    2025-11-11T17:21:08Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
    ```
  - i need to learn kubectl lmao ive been relying on k9s
- ok so before i do this (migrating old traefik to new traefik in k3s), i need to backup immich once again and yeah the pics


## traefik-gateway logs when conflicting (2025-11-12-0127 (November 12, 2025 01:27:45 AM)
```logs
2025-11-11T17:00:53Z INF Traefik version 3.5.3 built on 2025-09-26T09:20:06Z version=3.5.3
2025-11-11T17:00:53Z INF 
Stats collection is disabled.
Help us improve Traefik by turning this feature on :)
More details on: https://doc.traefik.io/traefik/contributing/data-collection/

2025-11-11T17:00:53Z INF Label selector is: "" providerName=kubernetesgateway
2025-11-11T17:00:53Z INF Creating in-cluster Provider client endpoint= providerName=kubernetesgateway
2025-11-11T17:00:53Z INF Starting provider aggregator *aggregator.ProviderAggregator
2025-11-11T17:00:53Z INF Starting provider *traefik.Provider
2025-11-11T17:00:53Z INF Starting provider *ingress.Provider
2025-11-11T17:00:53Z INF ingress label selector is: "" providerName=kubernetes
2025-11-11T17:00:53Z INF Creating in-cluster Provider client providerName=kubernetes
2025-11-11T17:00:53Z INF Starting provider *crd.Provider
2025-11-11T17:00:53Z INF label selector is: "" providerName=kubernetescrd
2025-11-11T17:00:53Z INF Creating in-cluster Provider client providerName=kubernetescrd
2025-11-11T17:00:53Z INF Starting provider *acme.ChallengeTLSALPN
2025-11-11T17:00:53Z INF Starting provider *gateway.Provider
2025-11-11T17:10:55Z WRN A new release of Traefik has been found: 3.6.0. Please consider updating.
2025-11-11T17:17:05Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:17:05Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:17:06Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:17:06Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:17:08Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:17:08Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:17:14Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:17:14Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:17:28Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:17:32Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:17:32Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:18:26Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:18:26Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:20:53Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:20:53Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:20:53Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:20:53Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:20:53Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:20:53Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:20:53Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:20:53Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:21:08Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:21:08Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:26:08Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
2025-11-11T17:26:08Z ERR Gateway Not Accepted error="2 errors occurred:\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 80 and protocol \"HTTP\"\n\t* Cannot find entryPoint for Gateway: no matching entryPoint for port 443 and protocol \"HTTPS\"\n\n" gateway=traefik namespace=traefik providerName=kubernetesgateway
```
