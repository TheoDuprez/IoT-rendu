#!/bin/bash

curl -sfL https://get.k3s.io | sh -s - --node-ip 192.168.56.110

cp /var/lib/rancher/k3s/server/node-token /vagrant/master_node_token.txt