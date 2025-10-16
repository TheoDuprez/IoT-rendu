#!/bin/bash
# install-k3s-master.sh
set -e

if command -v k3s >/dev/null 2>&1; then
  echo "K3s est déjà installé, rien à faire."
  exit 0
fi

# Fix ce warning : dpkg-preconfigure: unable to re-open stdin
export DEBIAN_FRONTEND=noninteractive

echo "=== Installation K3s Master ==="

sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y curl

curl -sfL https://get.k3s.io | sh -s - --node-ip 192.168.56.110 --flannel-iface eth1

echo "=== Installation terminée ==="
echo "Token pour les agents :"
sudo cat /var/lib/rancher/k3s/server/node-token

# Sauvegarder le token dans /vagrant pour le worker
sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/node-token