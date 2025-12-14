#!/bin/bash

# refs:
# - https://pkg.cloudflare.com/index.html
# - https://github.com/filip-lebiecki/k3s-install?tab=readme-ov-file#cloudflared

set -e

# add cloudflare gpg key
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# stable
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list

sudo apt-get update && sudo apt-get install cloudflared

# next steps
echo -e "\nDo the following:"

echo -e "\nAuthenticate:"
echo "cloudflared tunnel login"

echo -e "\nCreate tunnel:"
echo "cloudflared tunnel create <any-tunnel-name>"

echo -e "\nCreate cloudflared namespace:"
echo "kubectl create namespace cloudflared"

echo -e "\nCreate the secret from the JSON file:"
echo "kubectl create secret generic cloudflare-tunnel-credentials \
  --from-file=credentials.json=$HOME/.cloudflared/<YOUR-TUNNEL-ID>.json \
  -n cloudflared"

cat <<EOF
[NEXT STEPS] Do the following:

1. Authenticate:
  $ cloudflared tunnel login

2. Create tunnel:
  $ cloudflared tunnel create <any-tunnel-name>

3. Create cloudflared namespace:
  $ kubectl create namespace cloudflared

4. Create the secret from the JSON file:
  $ kubectl create secret generic cloudflare-tunnel-credentials --from-file=credentials.json=\$HOME/.cloudflared/<YOUR-TUNNEL-ID>.json -n cloudflared
EOF
