#!/bin/bash
# install-k3s-worker.sh
set -e

if command -v k3s >/dev/null 2>&1; then
  echo "K3s est déjà installé, rien à faire."
  exit 0
fi

# Fix ce warning : dpkg-preconfigure: unable to re-open stdin
export DEBIAN_FRONTEND=noninteractive

echo "=== Installation K3s Agent ==="

sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y curl

# Attendre que le token soit disponible
echo "Attente du token du master..."
while [ ! -f /vagrant/node-token ]; do
  echo "Token non disponible, attente..."
  sleep 5
done

MASTER_IP="192.168.56.110"
MASTER_TOKEN=$(cat /vagrant/node-token)

echo "Token récupéré : $MASTER_TOKEN"

# Attendre que le master soit vraiment accessible
echo "Vérification que le master est accessible..."
RETRY=0
MAX_RETRY=30
until curl -k -s https://${MASTER_IP}:6443 >/dev/null 2>&1; do
  RETRY=$((RETRY+1))
  if [ $RETRY -ge $MAX_RETRY ]; then
    echo "ERREUR: Le master n'est pas accessible après ${MAX_RETRY} tentatives"
    exit 1
  fi
  echo "Master pas encore prêt, attente... (${RETRY}/${MAX_RETRY})"
  sleep 10
done

echo "Master accessible ! Installation de l'agent..."

curl -sfL https://get.k3s.io | K3S_URL="https://${MASTER_IP}:6443" K3S_TOKEN="${MASTER_TOKEN}" sh -s - --node-ip 192.168.56.111 --flannel-iface eth1

echo "=== Agent installé avec succès ==="