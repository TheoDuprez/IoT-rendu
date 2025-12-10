#!/bin/bash

set -e

### Configuration ###
ARGOCD_NAMESPACE="argocd"
DEV_NAMESPACE="dev"
GITLAB_USER="root"
GITLAB_PROJECT_NAME="iot_lciullo"
GITLAB_PORT="8181"

# GitLab Personal Access Token
GITLAB_PAT=$(cat /tmp/gitlab_pat.txt 2>/dev/null || echo "")

if [ -z "$GITLAB_PAT" ]; then
    echo "Error: GitLab PAT not found in /tmp/gitlab_pat.txt"
    exit 1
fi

# Configure GitLab repository URL
GITLAB_REPO_URL="http://gitlab-webservice-default.gitlab.svc.cluster.local:${GITLAB_PORT}/${GITLAB_USER}/${GITLAB_PROJECT_NAME}.git"

# Register GitLab repository in ArgoCD
kubectl delete secret gitlab-repo -n "$ARGOCD_NAMESPACE" --ignore-not-found=true

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-repo
  namespace: $ARGOCD_NAMESPACE
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: $GITLAB_REPO_URL
  username: root
  password: $GITLAB_PAT
  insecure: "true"
EOF

# Create ArgoCD Application

kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: wil-playground-app
  namespace: $ARGOCD_NAMESPACE
spec:
  project: default
  source:
    repoURL: $GITLAB_REPO_URL
    targetRevision: main
    path: deployment
  destination:
    server: https://kubernetes.default.svc
    namespace: $DEV_NAMESPACE
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF

echo "ArgoCD connected to GitLab successfully!"
echo "Repository: $GITLAB_REPO_URL"
echo "Application: wil-playground-app -> $DEV_NAMESPACE namespace"
echo ""
echo "Access ArgoCD UI:"
echo "  kubectl -n argocd port-forward svc/argocd-server 8080:443"
echo "  https://localhost:8080"
