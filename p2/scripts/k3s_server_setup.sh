#!/bin/bash

curl -sfL https://get.k3s.io | sh -s - server --node-ip 192.168.56.110

echo "Waiting 10s for k3s installation to complete...\n\n"
sleep 10

sudo kubectl apply -f /vagrant/confs/app1/app1.yaml
sudo kubectl apply -f /vagrant/confs/app2/app2.yaml
sudo kubectl apply -f /vagrant/confs/app3/app3.yaml

sudo kubectl get all