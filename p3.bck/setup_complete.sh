#!/bin/bash

set -e

echo "=========================================="
echo "Part 3: K3d and Argo CD Setup"
echo "=========================================="

# Delete existing cluster if it exists
if k3d cluster list | grep -q mycluster; then
    echo "Deleting existing cluster..."
    k3d cluster delete mycluster
fi

# Create K3d cluster with proper DNS configuration
echo "Creating K3d cluster..."
k3d cluster create mycluster \
    --agents 2 \
    --port 8080:80@loadbalancer \
    --port 8443:443@loadbalancer \
    --wait

# Wait for cluster to be ready
echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=120s

# Create namespaces
echo "Creating namespaces..."
kubectl create namespace argocd
kubectl create namespace dev

# Install ArgoCD
echo "Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait a bit for the deployment to be created
sleep 5

# Disable GPG to avoid crashes in K3d
echo "Disabling GPG in repo-server (K3d compatibility fix)..."
kubectl patch deployment argocd-repo-server -n argocd --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/containers/0/env/-", "value": {"name": "ARGOCD_GPG_ENABLED", "value": "false"}}]'

# Wait for ArgoCD to be ready
echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
kubectl wait --for=condition=available --timeout=300s deployment/argocd-repo-server -n argocd

# Apply your application
echo "Deploying application..."
kubectl apply -f https://raw.githubusercontent.com/lciullo/iot_lciullo/main/application.yaml

# Wait for the application to sync
echo "Waiting for application to sync..."
sleep 10

# Get initial admin password
echo ""
echo "=========================================="
echo "ArgoCD Initial Admin Password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""
echo "=========================================="
echo ""
echo "Username: admin"
echo ""
echo "Starting port-forward on localhost:8080..."
echo "Access ArgoCD at: https://localhost:8080"
echo "Press Ctrl+C to stop the port-forward"
echo ""

# Port-forward (this will block, which is expected)
kubectl port-forward svc/argocd-server -n argocd 8080:443
