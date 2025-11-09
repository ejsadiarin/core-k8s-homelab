#!/bin/bash

set -e

AGENT_IP="100.75.212.53"
USER="ejs"
SERVER_IP="100.117.44.99"

k3sup join \
  --ip $AGENT_IP \
  --user $USER \
  --server-ip $SERVER_IP \
  --ssh-key ~/.ssh/id_ed25519
