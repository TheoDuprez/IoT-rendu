#!/bin/bash

# Update package lists
sudo apt-get update

# Install Docker
echo "Checking for Docker installation..."
if ! command -v docker &> /dev/null
then
    echo "Docker is not installed. Installing Docker."
    sudo apt-get install -y docker.io
    sudo usermod -aG docker $USER
    if command -v docker &> /dev/null
    then
        echo "Docker installed successfully."
    else
        echo "Docker installation failed."
        exit 1
    fi
else
    echo "Docker is already installed."
fi


# Install K3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash



kubectl create namespace argocd
kubectl create namespace dev

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl apply -f https://raw.githubusercontent.com/lciullo/iot_lciullo/main/application.yaml

kubectl port-forward svc/argocd-server -n argocd 8080:443