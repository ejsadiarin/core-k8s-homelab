#!/bin/bash

set -e

IP="100.117.44.99"
USER="ejs"

k3sup install \
  --ip $IP \
  --user $USER \
  --cluster \
  --k3s-extra-args '--cluster-init --disable=traefik --disable=servicelb --write-kubeconfig-mode "644"' \
  --ssh-key ~/.ssh/id_ed25519
