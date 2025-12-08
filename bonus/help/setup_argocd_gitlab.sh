#!/bin/bash

ARGOCD_NAMESPACE="argocd"
GITLAB_NAMESPACE="gitlab"
# --- ACTION REQUISE ---
# Remplacez la ligne ci-dessous par votre Jeton d'Accès Personnel GitLab
# Via interface => edit profile 
# Puis a gauche => Personnal access tokens
# Créez un token avec les scopes "api" et "read_repository"
# bien ajouter le token 
# Exemple: GITLAB_PAT="glpat-xxxxxxxxxxxxxxxxxxxx"
# A automatiser via glab ou API GitLab si besoin
GITLAB_PAT=""

# --------------------

# Use internal Kubernetes DNS for GitLab
GITLAB_IP=$(kubectl get svc -n gitlab gitlab-webservice-default -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
GITLAB_PORT="8181" # Port HTTP interne de GitLab
GITLAB_REPO="http://${GITLAB_IP}:${GITLAB_PORT}/root/iot_lciullo.git"

# Adresse du dépôt GitLab via le service interne Kubernetes
# http://ip:8181/root/iot-lciullo.git

# Install Argo CD
echo "Installing Argo CD..."

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo ""
echo "Waiting for Argo CD server pod to be running..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=600s
echo "✓ Argo CD server pod is ready!"

# Create a secret for the private GitLab repository
echo ""
echo "Creating GitLab repository secret for Argo CD..."
kubectl apply -n argocd -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-repo-secret
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: ${GITLAB_REPO}
  username: root
  password: ${GITLAB_PAT}
  insecure: "true"
EOF

# Create and apply Argo CD Application
echo ""
echo "Creating Argo CD Application..."

kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: wil-playground-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: $GITLAB_REPO
    targetRevision: main
    path: deployment
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

echo "✓ Application created"

echo ""
echo "=== Argo CD setup complete ==="

# Get passwords
echo ""
echo "Argo CD Initial Admin Password:"
kubectl -n "$ARGOCD_NAMESPACE" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""

echo ""
echo "GitLab Initial Root Password:"
kubectl -n "$GITLAB_NAMESPACE" get secret gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 --decode 2>/dev/null || echo "Not found - check manually"
echo ""

echo ""
echo "To access Argo CD UI:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "  Then open: https://localhost:8080"
