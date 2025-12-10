#!/bin/bash

curl -sfL https://get.k3s.io | sh -s - --node-ip 192.168.56.110

kubectl apply -f /home/vagrant/config/app1.yaml
kubectl apply -f /home/vagrant/config/app2.yaml
kubectl apply -f /home/vagrant/config/app3.yaml
kubectl apply -f /home/vagrant/config/ingress.yaml