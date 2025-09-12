#!/bin/bash

curl -sfL https://get.k3s.io | sh -s - server --node-ip 192.168.56.110

TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)

echo $TOKEN > /vagrant/k3s_token