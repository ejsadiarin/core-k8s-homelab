## 1. Cloudflared Configuration

- [x] 1.1 Update `config.yaml` wildcard ingress rule: change service URL from `https://cilium-gateway-gateway-external.gateway.svc.cluster.local:443` to `http://cilium-gateway-gateway-external.gateway.svc.cluster.local:80`
- [x] 1.2 Update `config.yaml` root domain ingress rule: change service URL from HTTPS:443 to HTTP:80
- [x] 1.3 Remove `noTLSVerify` from all ingress rules in `config.yaml`
- [x] 1.4 Remove `originServerName` from all ingress rules in `config.yaml`

## 2. Network Policy

- [x] 2.1 Update `cilium-netpol.yaml` egress to gateway: change port from 443 to 80

## 3. External Gateway HTTPRoutes

- [x] 3.1 Remove `sectionName: https` from `cluster/apps/bday-hannah/httproute.yaml`
- [x] 3.2 Remove `sectionName: https` from `cluster/apps/hello-world/http-route.yaml`
- [x] 3.3 Remove `sectionName: https` from `cluster/apps/glance/httproute.yaml`
- [x] 3.4 Remove `sectionName: https` from `cluster/apps/it-tools/httproute.yaml`
- [x] 3.5 Remove `sectionName: https` from `cluster/apps/nginx/httproute.yaml`

## 4. Internal Gateway HTTPRoutes

- [x] 4.1 Remove `sectionName: https` from `cluster/apps/homepage-dashboard/http-route.yaml`
- [x] 4.2 Remove `sectionName: https` from `cluster/monitoring/kube-prometheus-stack/http-route-grafana.yaml`
- [x] 4.3 Remove `sectionName: https` from `cluster/monitoring/kube-prometheus-stack/http-route-prometheus.yaml`

## 5. SealedSecret Ownership Fix (Runtime)

- [x] 5.1 Delete unmanaged `tunnel-credentials` secret in cloudflared namespace so SealedSecret controller recreates it with proper ownership
- [x] 5.2 Verify SealedSecret status condition shows `Synced: True`

## 6. Verification

- [x] 6.1 Commit and push changes to `cluster` branch
- [x] 6.2 Force ArgoCD refresh and sync for all affected applications
- [x] 6.3 Verify cloudflared pod restarts with new config and establishes 4 tunnel connections
- [x] 6.4 Verify all HTTPRoutes show no `sectionName` in cluster state
- [x] 6.5 Verify cloudflared ArgoCD application shows Synced/Healthy
- [x] 6.6 Test end-to-end connectivity from inside cluster: HTTP requests via gateway return 200 for all services
