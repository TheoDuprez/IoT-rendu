#!/bin/bash

# https://dev.to/danielcristho/k3d-getting-started-with-argocd-5c6l

k3d cluster create p3 --agents 1
kubectl create namespace argocd
kubectl create namespace dev 

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait -n argocd --for=condition=available deployment --all --timeout=3m

# To print the initial password generated for admin user
echo "Password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"

# To access the ArgoCD UI
kubectl port-forward -n argocd svc/argocd-server 8080:443