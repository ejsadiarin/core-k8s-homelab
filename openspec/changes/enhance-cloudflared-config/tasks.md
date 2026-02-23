## 1. Deployment Enhancements

- [x] 1.1 Add `reloader.stakater.com/auto: "true"` annotation to Deployment metadata
- [x] 1.2 Add pod labels `netpol.cilium.io/egress-to-cloudflare: "true"` and `netpol.cilium.io/egress-to-kube-dns: "true"`
- [x] 1.3 Add sysctl `net.ipv4.ping_group_range: "65532 65532"` to PodSecurityContext
- [x] 1.4 Add `readOnly: true` to config volumeMount
- [x] 1.5 Update CPU requests from 100m to 50m
- [x] 1.6 Update CPU limits from 500m to 200m

## 2. Metrics Service

- [x] 2.1 Create `service.yaml` with cloudflared-metrics Service on port 2000
- [x] 2.2 Add Service to kustomization.yaml resources

## 3. Network Policy

- [x] 3.1 Create `cilium-netpol.yaml` with explicit egress rules
- [x] 3.2 Allow egress to Gateway service on port 443
- [x] 3.3 Allow egress to Cloudflare edge (via cloudflare.com DNS)
- [x] 3.4 Allow egress to kube-dns on port 53
- [x] 3.5 Add CiliumNetworkPolicy to kustomization.yaml resources

## 4. Config Fixes

- [x] 4.1 Remove duplicate `CF-IPCountry` header entry
- [x] 4.2 Remove duplicate `CF-Ray` header entry (case-insensitive duplicate)

## 5. Kustomization Updates

- [x] 5.1 Add `app.kubernetes.io/*` labels to kustomization.yaml
- [x] 5.2 Include common Cilium network policies reference

## 6. GitOps Deployment

- [ ] 6.1 Commit all changes with descriptive message
- [ ] 6.2 Push to origin/cluster branch
- [ ] 6.3 Verify ArgoCD syncs successfully
- [ ] 6.4 Verify cloudflared pod is Running with new configuration
- [ ] 6.5 Verify metrics endpoint is accessible via Service
- [ ] 6.6 Verify tunnel connectivity is maintained
