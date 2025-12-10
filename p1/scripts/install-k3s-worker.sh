#!/bin/bash
# install-k3s-worker.sh
set -e

echo "=== K3s Agent Installation ==="

MASTER_TOKEN=$(< /vagrant/node-token.txt)

echo "Token retrieved: $MASTER_TOKEN"

echo "Master is accessible! Installing agent..."

curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN="${MASTER_TOKEN}" sh -s - agent --node-ip 192.168.56.111


echo "=== Agent installed successfully ==="