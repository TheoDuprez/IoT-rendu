#!/bin/bash

echo "=========================================="
echo "Complete Cleanup - P3"
echo "=========================================="

# Stop any running port-forward
echo "Stopping port-forwards..."
pkill -f "port-forward" 2>/dev/null || true
lsof -ti:8080 | xargs kill -9 2>/dev/null || true

# Delete ArgoCD application
echo "Deleting ArgoCD application..."
kubectl delete application wil-playground-app -n argocd 2>/dev/null || true

# Delete namespaces
echo "Deleting namespaces..."
kubectl delete namespace argocd --timeout=60s 2>/dev/null || true
kubectl delete namespace dev --timeout=60s 2>/dev/null || true

# Delete K3d cluster
echo "Deleting K3d cluster..."
k3d cluster delete mycluster 2>/dev/null || true

# Clean up any leftover processes
echo "Cleaning up leftover processes..."
pkill -f kubectl 2>/dev/null || true

# Remove kubeconfig context
echo "Cleaning kubeconfig..."
kubectl config delete-context k3d-mycluster 2>/dev/null || true
kubectl config delete-cluster k3d-mycluster 2>/dev/null || true
kubectl config unset users.admin@k3d-mycluster 2>/dev/null || true

echo ""
echo "=========================================="
echo "✅ Complete cleanup done!"
echo "=========================================="
echo ""
echo "Your system is now clean. You can start fresh with:"
echo "  ./full_setup.sh"
echo ""
