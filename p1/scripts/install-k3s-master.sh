#!/bin/bash
# install-k3s-master.sh
set -e

echo "=== K3s Master Installation ==="
curl -sfL https://get.k3s.io | sh -s - server --node-ip 192.168.56.110

echo "=== Installation completed ==="
echo "Token for agents:"
sudo cat /var/lib/rancher/k3s/server/node-token

# Save token to /vagrant for worker
sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/node-token.txt