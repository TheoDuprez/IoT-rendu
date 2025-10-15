#!/bin/bash

curl -sfL https://get.k3s.io | sh -s - server --node-ip 192.168.56.110

echo $'Waiting 5s for k3s installation to complete...\n'
sleep 5

sudo kubectl apply -f /vagrant/confs/app1/app1.yaml
sudo kubectl apply -f /vagrant/confs/app2/app2.yaml
sudo kubectl apply -f /vagrant/confs/app3/app3.yaml
sudo kubectl apply -f /vagrant/confs/ingress.yaml

sleep 5

sudo kubectl get all