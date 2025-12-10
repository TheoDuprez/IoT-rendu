#!/bin/bash

# https://dev.to/danielcristho/k3d-getting-started-with-argocd-5c6l

k3d cluster create p3 --agents 1
kubectl create namespace argocd
kubectl create namespace dev 

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait -n argocd --for=condition=available deployment --all --timeout=3m

# Configure ArgoCD for faster sync (30 seconds instead of 3 minutes)
echo "Configuring ArgoCD sync interval..."
kubectl patch configmap argocd-cm -n argocd --type merge -p '{"data":{"timeout.reconciliation":"30s"}}'
kubectl rollout restart deployment argocd-application-controller -n argocd
kubectl wait -n argocd --for=condition=available deployment argocd-application-controller --timeout=2m

# To print the initial password generated for admin user
echo "Password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"

# To access the ArgoCD UI ; 'nohup' unlinks the process from terminal ; '&' runs it in background
nohup kubectl port-forward -n argocd svc/argocd-server 8080:443 > will_argocd.log 2>&1 &

kubectl apply -f ./confs/app_wil_argoCD.yaml

while ! kubectl get svc playground-service -n dev >/dev/null 2>&1; do
    echo "Waiting for service playground-service..."
    sleep 5
done

kubectl wait -n dev --for=condition=available deployment/playground --timeout=2m 2>/dev/null

nohup kubectl port-forward -n dev svc/playground-service 8081:8888 > will_playground.log 2>&1 &