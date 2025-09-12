#!/bin/bash

TOKEN=$(cat /vagrant/k3s_token)

curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=$TOKEN sh -s - agent --node-ip 192.168.56.111