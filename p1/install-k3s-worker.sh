#!/bin/bash
# install-k3s-worker.sh
set -e

echo "=== Installation K3s Agent ==="

MASTER_TOKEN=$(< /vagrant/node-token.txt)

echo "Token récupéré : $MASTER_TOKEN"

echo "Master accessible ! Installation de l'agent..."

curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN="${MASTER_TOKEN}" sh -s - agent --node-ip 192.168.56.111


echo "=== Agent installé avec succès ==="
#sudo apt-get update && sudo apt-get install -y iptables iptables-persistent