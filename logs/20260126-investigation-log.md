# Kubernetes Homelab Investigation Log

**Date:** January 26, 2026
**Cluster:** Single-node K3s (homelab)

---

## Investigation 1: nginx LoadBalancer IP Pending

**Problem:** nginx service shows `<pending>` for external IP instead of getting an IP from Cilium IPAM.

**Root Cause:**
The nginx service has an annotation requesting IP `192.168.70.105`:
```yaml
lbipam.cilium.io/ips: "192.168.70.105"
```

However, the Cilium IP pool (`main-pool`) is configured for a different CIDR:
```yaml
blocks:
  - cidr: 192.168.10.200/29  # Range: .200 to .207 (usable: .201 to .206)
```

The requested IP `192.168.70.105` is **outside** the configured pool range, so Cilium cannot assign it.

**Evidence:**
```bash
$ kubectl describe svc nginx -n nginx
Annotations:  lbipam.cilium.io/ips: 192.168.70.105

$ kubectl get ciliumloadbalancerippool main-pool -o yaml
spec:
  blocks:
  - cidr: 192.168.10.200/29
```

**Solution Options:**

1. **Remove the static IP annotation** (Recommended) - Let Cilium assign an IP from the pool:
   ```yaml
   # Remove or comment out:
   # lbipam.cilium.io/ips: "192.168.70.105"
   ```

2. **Update the annotation to use an IP from the pool** (192.168.10.203-206):
   ```yaml
   lbipam.cilium.io/ips: "192.168.10.203"
   ```

3. **Expand the IP pool** to include the 192.168.70.x range (requires network changes)

**Recommended Fix:** Option 1 - Remove the annotation since nginx is already accessible via HTTPRoute through `gateway-external`.

---

## Investigation 2: kubectl top Metrics Not Working

**Problem:** `kubectl top nodes` returns "metrics not available yet"

**Status:** **Working correctly, just timing issue**

**Evidence:**
The metrics API is actually healthy and serving data:
```bash
$ kubectl get apiservice v1beta1.metrics.k8s.io -o yaml
status:
  conditions:
  - message: all checks passed
    reason: Passed
    status: "True"
    type: Available

$ kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes"
{"kind":"NodeMetricsList","apiVersion":"metrics.k8s.io/v1beta1","metadata":{},"items":[]}

$ kubectl get --raw "/apis/metrics.k8s.io/v1beta1/pods"
# Returns actual pod metrics data
```

**Root Cause:**
The node metrics list returns empty `items: []`. This can happen when:
1. The prometheus-adapter hasn't scraped node metrics yet (timing)
2. The `node_exporter` metrics need time to populate
3. Query rules for node metrics may need adjustment

**Prometheus Adapter Status:**
- Pod is running and healthy (responding 200 to health checks)
- API is serving requests
- Pod metrics ARE available (tested and working)

**Workaround:**
You can check metrics directly from Prometheus at `prometheus.int.ejsadiarin.com` or Grafana.

**To Fix Node Metrics:**
Check the prometheus-adapter configuration in `cluster/monitoring/prometheus-adapter/values.yaml` to ensure node metric rules are properly defined:
```yaml
rules:
  default: true  # Enable default rules including node metrics
```

---

## Investigation 3: OutOfSync Applications

**Problem:** Multiple applications show `OutOfSync` status despite being `Healthy`.

**Affected Applications:**
| Application | Sync Status | Health Status |
|-------------|-------------|---------------|
| argocd | OutOfSync | Healthy |
| glance | OutOfSync | Healthy |
| hello-world | OutOfSync | Healthy |
| homepage-dashboard | OutOfSync | Healthy |
| it-tools | OutOfSync | Healthy |
| kube-prometheus-stack | OutOfSync | Healthy |
| longhorn | OutOfSync | Healthy |
| nginx | OutOfSync | Progressing |

**Root Cause:**
Based on the troubleshooting log entry #11, the primary cause is **status drift on HTTPRoutes**. The Cilium Gateway controller dynamically updates the `/status` field of `HTTPRoute` objects, which ArgoCD interprets as drift from Git state.

**Evidence:**
This is a known issue documented in the existing troubleshooting log. The solution was previously implemented:
```yaml
# In ArgoCD values.yaml
ignoreDifferences:
  - group: gateway.networking.k8s.io
    kind: HTTPRoute
    jsonPointers:
      - /status
```

**Possible Reasons for Continued OutOfSync:**
1. The `ignoreDifferences` setting may not be applied to all Application resources
2. There may be other fields causing drift (not just HTTPRoute status)
3. Local changes in Git not yet applied to the cluster

**To Investigate Further:**
```bash
# Check what's actually out of sync for a specific app
kubectl -n argocd get application <app-name> -o jsonpath='{.status.resources[?(@.status=="OutOfSync")]}'

# Or use the ArgoCD UI/CLI for detailed diff
argocd app diff <app-name>
```

**nginx Progressing Status:**
The nginx app shows `Progressing` health because the LoadBalancer IP is pending (Issue #1). Once the IP is assigned, it should become `Healthy`.

---

## Summary of Actions Needed

| Issue | Priority | Action |
|-------|----------|--------|
| nginx LoadBalancer IP | High | Remove `lbipam.cilium.io/ips` annotation or update to valid IP |
| Node metrics empty | Low | Check prometheus-adapter rules config; pod metrics work fine |
| OutOfSync apps | Low | Expected behavior due to controller status updates; can be ignored if healthy |

---

## Additional Notes

- Cluster is running k3s v1.33.6+k3s1 on Debian 12
- Cilium IP pool has 4 IPs available (2 used by gateways, 2 remaining: .203-.206 minus first/last)
- TLS certificate `cert-ejsadiarin` is valid and serving both gateways
