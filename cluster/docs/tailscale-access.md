# Secure Remote Access with Tailscale

This guide explains how to access your internal services (served via `gateway-internal`) securely from anywhere using Tailscale, without exposing them to the public internet.

## Architecture

- **Public Access:** Cloudflare Tunnel -> `gateway-external` (192.168.10.201) -> Public Apps
- **Private Access:** Tailscale VPN -> Subnet Router (NUC) -> `gateway-internal` (192.168.10.202) -> Private Apps

## Prerequisites

- Tailscale installed on your Node (NUC).
- AdGuard Home running on your Node (or another DNS server accessible via Tailscale).

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

_Now, any device on your Tailnet can ping `192.168.10.202` (the internal gateway IP)._

### Verification

On a different device (e.g., your laptop), verify the route is active:

```bash
# Check if the route to the gateway IP goes via Tailscale (tun0/tailscale0)
# Linux/macOS
ip route get 192.168.10.202
```

If it returns a local interface (like `wlan0` or `eth0`) and you are NOT on the home network, the subnet route is **not working**. It should return `tailscale0`.

On the Node itself, verify it is advertising:

```bash
tailscale status
# Look for: "offers: 192.168.10.200/29" next to your node name.
```

## Step 2: Configure DNS Strategy

You need a way to map domain names (e.g., `*.int.ejsadiarin.com`) to the internal gateway IP (`192.168.10.202`).

### Option A: Split DNS (Recommended)

This uses your existing AdGuard Home to resolve internal domains for Tailscale clients.

1.  **Configure AdGuard Home:**
    - Add a DNS Rewrite: `*.int.ejsadiarin.com` -> `192.168.10.202` (The Internal Gateway IP).

2.  **Configure Tailscale DNS:**
    - Go to **Tailscale Admin Console > DNS**.
    - Under **Nameservers**, add a **Global Nameserver** (or "Split DNS").
    - **Split DNS:**
        - **Domain:** `int.ejsadiarin.com`
        - **Nameserver:** `100.x.y.z` (Your NUC's **Tailscale IP**).
        - _Explanation:_ This tells Tailscale to ask your NUC (AdGuard) "Where is grafana.int...?". AdGuard replies "It's at 192.168.10.202". Your device then routes to 192.168.10.202 via the Subnet Router.
        - _Note: Ensure AdGuard is listening on the Tailscale interface (`tailscale0`) or all interfaces (`0.0.0.0`)._

### Option B: Public DNS with Private IPs

If you don't want to mess with Split DNS, you can actually use Cloudflare DNS!

1.  Go to **Cloudflare Dashboard (DNS)**.
2.  Add an `A` record: `*.int.ejsadiarin.com` -> `192.168.10.202`.

- **How this works:** Even though it's a private IP, your device (connected to Tailscale) knows how to route to it thanks to Step 1.
- **Pros:** Very simple. No AdGuard config needed on the client side.
- **Cons:** Leaks your internal IP structure to public DNS records (low risk for `192.168.x.x`).

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

- **Connect to Tailscale.**
- **Visit:** `https://longhorn.int.ejsadiarin.com`
- **Traffic Flow:** Your Device -> Tailscale Tunnel -> NUC -> Cilium Gateway (`.202`) -> Longhorn.
- **Security:** Encrypted WireGuard tunnel. No ports open on your router.
