#!/bin/bash

set -e

echo "=== Installing ArgoCD ==="

# Create argocd namespace
echo "Creating argocd namespace..."
kubectl create namespace argocd 2>/dev/null || echo "Namespace argocd already exists"

# Install ArgoCD
echo "Installing ArgoCD manifests..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD pods to be ready
echo "Waiting for ArgoCD pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

echo "ArgoCD installation complete"
echo ""
echo "To access ArgoCD UI:"
echo "1. Get admin password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
echo "2. Port-forward: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "3. Login at https://localhost:8080 (username: admin)"
