#!/bin/bash

set -e

echo "=========================================="
echo "Full Setup - Inception of Things Part 3"
echo "=========================================="

# Delete existing cluster if it exists
echo "Cleaning up existing cluster..."
k3d cluster delete mycluster 2>/dev/null || true

# Create a new K3d cluster with proper DNS configuration
echo "Creating new K3d cluster with proper DNS..."
k3d cluster create mycluster \
  --servers 1 \
  --agents 2 \
  --port "8080:80@loadbalancer" \
  --wait

# Wait for cluster to be ready
echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=60s

# Create namespaces
echo "Creating namespaces..."
kubectl create namespace argocd
kubectl create namespace dev

# Install ArgoCD
echo "Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD deployments to be created
echo "Waiting for ArgoCD deployments to be created..."
sleep 15

# Disable GPG to avoid crashes in K3d
echo "Disabling GPG in repo-server (K3d compatibility fix)..."
kubectl patch deployment argocd-repo-server -n argocd --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/env/-", "value": {"name": "ARGOCD_GPG_ENABLED", "value": "false"}}]'

# Wait for ArgoCD to be ready
echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
kubectl wait --for=condition=available --timeout=300s deployment/argocd-repo-server -n argocd

# Apply your application
echo "Deploying application..."
kubectl apply -f https://raw.githubusercontent.com/lciullo/iot_lciullo/main/application.yaml

# Wait for application to sync
echo "Waiting for application to synchronize..."
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

# Check application status
echo "Application status:"
kubectl get application -n argocd

echo ""
echo "Pods in dev namespace:"
kubectl get pods -n dev

echo ""
echo "=========================================="
echo "Setup complete!"
echo "To access ArgoCD UI, run:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "Then open: https://localhost:8080"
echo "=========================================="
