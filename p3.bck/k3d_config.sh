#!/bin/bash

# Create namespaces
echo "Creating namespaces..."
kubectl create namespace argocd
kubectl create namespace dev

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
