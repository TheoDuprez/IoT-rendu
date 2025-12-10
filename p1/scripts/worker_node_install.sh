#!/bin/bash

MASTER_NODE_TOKEN=$(cat /vagrant/master_node_token.txt)

curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=$MASTER_NODE_TOKEN sh -s - --node-ip 192.168.56.111