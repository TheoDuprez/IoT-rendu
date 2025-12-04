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

# Create K3d cluster
echo "Checking for K3d cluster..."
if k3d cluster list | grep -q mycluster; then
    echo "K3d cluster 'mycluster' already exists"
else
    k3d cluster create mycluster
    k3d cluster start mycluster
fi


# Install K3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash


# Create namespaces
echo "Checking for argocd namespace..."
if kubectl get namespace argocd 2>/dev/null; then
    echo "Namespace 'argocd' already exists"
else
    echo "Creating namespace 'argocd'"
    kubectl create namespace argocd
fi

echo "Checking for dev namespace..."
if kubectl get namespace dev 2>/dev/null; then
    echo "Namespace 'dev' already exists"
else
    echo "Creating namespace 'dev'"
    kubectl create namespace dev
fi

# Install ArgoCD
echo "Installing Argo CD..."

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


kubectl apply -f https://raw.githubusercontent.com/lciullo/iot_lciullo/main/application.yaml

echo ""

echo " Waiting for Argo CD server pod to be running..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=600s
echo "✓ Argo CD server pod is ready!"


echo ""
echo "=== All pods are running ==="

kubectl port-forward svc/argocd-server -n argocd 8080:443