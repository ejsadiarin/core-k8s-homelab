# Secure Remote Access with Tailscale

This guide explains how to access your internal services (served via `gateway-internal`) securely from anywhere using Tailscale, without exposing them to the public internet.

## Architecture

*   **Public Access:** Cloudflare Tunnel -> `gateway-external` (192.168.10.201) -> Public Apps
*   **Private Access:** Tailscale VPN -> Subnet Router (NUC) -> `gateway-internal` (192.168.10.202) -> Private Apps

## Prerequisites

*   Tailscale installed on your Node (NUC).
*   AdGuard Home running on your Node (or another DNS server accessible via Tailscale).

## Step 1: Configure Subnet Router (On NUC)

Tell Tailscale to advertise the IP range used by your Cilium Gateways (`192.168.10.200/29`).

```bash
# Advertise the LoadBalancer pool range
sudo tailscale up --advertise-routes=192.168.10.200/29 --accept-routes
```

1.  Go to the **Tailscale Admin Console**.
2.  Find your NUC machine.
3.  Click **Edit Route Settings**.
4.  **Approve** the `192.168.10.200/29` route.

*Now, any device on your Tailnet can ping `192.168.10.202`.*

## Step 2: Configure DNS Strategy

You need a way to map domain names (e.g., `*.int.ejsadiarin.com`) to the internal gateway IP (`192.168.10.202`).

### Option A: Split DNS (Recommended)

This uses your existing AdGuard Home to resolve internal domains for Tailscale clients.

1.  **Configure AdGuard Home:**
    *   Add a DNS Rewrite: `*.int.ejsadiarin.com` -> `192.168.10.202`

2.  **Configure Tailscale DNS:**
    *   Go to **Tailscale Admin Console > DNS**.
    *   Under **Nameservers**, add a **Global Nameserver** (or "Split DNS" if you only want it for specific domains).
    *   **Split DNS:**
        *   **Domain:** `int.ejsadiarin.com`
        *   **Nameserver:** `100.x.y.z` (Your NUC's **Tailscale IP**, not LAN IP).
        *   *Note: Ensure AdGuard is listening on the Tailscale interface (`tailscale0`) or all interfaces (`0.0.0.0`).*

### Option B: Public DNS with Private IPs

If you don't want to mess with Split DNS, you can actually use Cloudflare DNS!

1.  Go to **Cloudflare Dashboard (DNS)**.
2.  Add an `A` record: `*.int.ejsadiarin.com` -> `192.168.10.202`.

*   **How this works:** Even though it's a private IP, your device (connected to Tailscale) knows how to route to it thanks to Step 1.
*   **Pros:** Very simple. No AdGuard config needed on the client side.
*   **Cons:** Leaks your internal IP structure to public DNS records (low risk for `192.168.x.x`).

## Step 3: Configure Applications

Update your HTTPRoutes to use the internal gateway for private apps.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: longhorn
spec:
  parentRefs:
    - name: gateway-internal # Secure gateway
      namespace: gateway
  hostnames:
    - "longhorn.int.ejsadiarin.com" # Use the internal domain
# ...
```

## Summary

*   **Connect to Tailscale.**
*   **Visit:** `https://longhorn.int.ejsadiarin.com`
*   **Traffic Flow:** Your Device -> Tailscale Tunnel -> NUC -> Cilium Gateway (`.202`) -> Longhorn.
*   **Security:** Encrypted WireGuard tunnel. No ports open on your router.
