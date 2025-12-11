#!/bin/bash

# Install docker
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
  
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo groupadd docker
sudo usermod -aG docker $USER

if ! getent group docker > /dev/null; then 
  newgrp docker 
fi

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# Install k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Pull project
git clone git@github.com:TheoDuprez/tduprez_k3d_infra.git playground_application

# Set up project
k3d cluster create k3s-cluster

kubectl create namespace argocd
kubectl create namespace dev

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait -n argocd --for=condition=Available deployment --all --timeout=3m
nohup kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &

kubectl apply -f https://raw.githubusercontent.com/TheoDuprez/tduprez_k3d_infra/main/application.yaml

kubectl patch deployment argocd-server -n argocd --type=json -p='[
    {"op": "replace", "path": "/spec/template/spec/containers/0/args", "value": [
        "/usr/local/bin/argocd-server",
        "--insecure"
    ]}
  ]'

kubectl rollout status deployment argocd-server -n argocd

kubectl apply -f confs/ingress.yaml
