#!/bin/bash

kubectl apply -f ./confs/app_wil_argoCD.yaml

echo "Waiting for ArgoCD to sync the application..."
kubectl wait -n argocd --for=jsonpath='{.status.health.status}'=Healthy application/playground-app --timeout=5m 2>/dev/null || true

while ! kubectl get svc playground-service -n dev >/dev/null 2>&1; do
    echo "Waiting for service playground-service..."
    sleep 5
done

kubectl wait -n dev --for=condition=available deployment/playground --timeout=2m 2>/dev/null

nohup kubectl port-forward -n dev svc/playground-service 8081:8888 > will_playground.log 2>&1 &