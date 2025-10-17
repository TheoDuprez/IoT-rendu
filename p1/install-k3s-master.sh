#!/bin/bash
# install-k3s-master.sh
set -e

echo "=== Installation K3s Master ==="
curl -sfL https://get.k3s.io | sh -s - server --node-ip 192.168.56.110

echo "=== Installation terminée ==="
echo "Token pour les agents :"
sudo cat /var/lib/rancher/k3s/server/node-token

# Sauvegarder le token dans /vagrant pour le worker
sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/node-token.txt