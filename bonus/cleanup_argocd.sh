#!/bin/bash

set -e

echo "--- Cleaning up Argo CD and related resources ---"

ARGOCD_NAMESPACE="argocd"
DEV_NAMESPACE="dev"
APP_NAME="wil-playground-app"

# 1. Delete the Argo CD Application to ensure managed resources are cleaned up
echo "Deleting Argo CD application '$APP_NAME'..."
kubectl delete application -n "$ARGOCD_NAMESPACE" "$APP_NAME" --ignore-not-found=true

# Wait a few seconds for the deletion to be processed
sleep 5

# 2. Delete the Argo CD installation from the manifest
echo "Deleting Argo CD components..."
kubectl delete -n "$ARGOCD_NAMESPACE" -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --ignore-not-found=true

# 3. Delete the namespaces
echo "Deleting namespaces '$ARGOCD_NAMESPACE' and '$DEV_NAMESPACE'..."
kubectl delete namespace "$ARGOCD_NAMESPACE" --ignore-not-found=true
kubectl delete namespace "$DEV_NAMESPACE" --ignore-not-found=true

echo "--- Cleanup complete ---"
