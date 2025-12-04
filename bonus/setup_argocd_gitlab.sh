#!/bin/bash

set -e

### Colors ###
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Argo CD + GitLab Configuration ===${NC}"

ARGOCD_NAMESPACE="argocd"
GITLAB_NAMESPACE="gitlab"
GITLAB_DOMAIN="gitlab.local"
GITHUB_REPO="${1:-}"  # Optional: GitHub repo for application

# Check if cluster is running
if ! kubectl cluster-info >/dev/null 2>&1; then
    echo -e "${RED}✗ Cluster is not running${NC}"
    exit 1
fi

# Install Argo CD if not already installed
echo -e "${BLUE}Setting up Argo CD...${NC}"

if kubectl get deployment argocd-server -n "$ARGOCD_NAMESPACE" >/dev/null 2>&1; then
    echo -e "${YELLOW}Argo CD already installed${NC}"
else
    echo -e "${BLUE}Installing Argo CD...${NC}"
    kubectl create namespace "$ARGOCD_NAMESPACE" 2>/dev/null || true
    kubectl apply -n "$ARGOCD_NAMESPACE" -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    
    echo -e "${YELLOW}Waiting for Argo CD to be ready...${NC}"
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n "$ARGOCD_NAMESPACE" --timeout=300s || true
fi

echo -e "${GREEN}✓ Argo CD is ready${NC}"

# Get Argo CD admin password
echo ""
echo -e "${YELLOW}Argo CD Initial Admin Password:${NC}"
ARGOCD_PASSWORD=$(kubectl -n "$ARGOCD_NAMESPACE" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "$ARGOCD_PASSWORD"

# Get GitLab root password
echo ""
echo -e "${YELLOW}GitLab Initial Root Password:${NC}"
GITLAB_PASSWORD=$(kubectl -n "$GITLAB_NAMESPACE" get secret gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 --decode 2>/dev/null || echo "Not found - check manually")
echo "$GITLAB_PASSWORD"

echo ""
echo -e "${BLUE}Configuring Argo CD to use GitLab...${NC}"

# Port-forward to Argo CD (if needed for further setup)
echo -e "${YELLOW}Argo CD Port Forwarding:${NC}"
echo "In another terminal, run:"
echo "  kubectl port-forward svc/argocd-server -n $ARGOCD_NAMESPACE 8080:443"
echo "Then access: https://localhost:8080"
echo "  Username: admin"
echo "  Password: $ARGOCD_PASSWORD"

echo ""
echo -e "${BLUE}GitLab Access Information:${NC}"
echo "Add to /etc/hosts:"
echo "  127.0.0.1 $GITLAB_DOMAIN"
echo ""
echo "Access GitLab at: http://$GITLAB_DOMAIN"
echo "  Username: root"
echo "  Password: (see above)"

# Create GitLab repository credentials secret (optional)
echo ""
echo -e "${BLUE}Creating GitLab credentials secret for Argo CD...${NC}"

# This secret will be used by Argo CD to access GitLab repositories
GITLAB_TOKEN="${GITLAB_PASSWORD}"  # You should generate a proper token

kubectl create secret generic gitlab-credentials \
    -n "$ARGOCD_NAMESPACE" \
    --from-literal=url="http://gitlab.local" \
    --from-literal=password="$GITLAB_TOKEN" \
    --from-literal=username="root" \
    --dry-run=client -o yaml | kubectl apply -f -

echo -e "${GREEN}✓ GitLab credentials secret created${NC}"

echo ""
echo -e "${GREEN}=== Configuration Complete ===${NC}"

echo ""
echo -e "${YELLOW}Manual Steps Required:${NC}"
echo ""
echo "1. Add to your /etc/hosts:"
echo "   127.0.0.1 gitlab.local"
echo ""
echo "2. Create a GitLab repository with your application manifests"
echo "   (deployment.yaml, service.yaml, etc.)"
echo ""
echo "3. Create an Argo CD Application via Argo CD UI:"
echo "   - Repository URL: http://gitlab.local/root/your-repo.git"
echo "   - Path: ./"
echo "   - Destination: https://kubernetes.default.svc"
echo "   - Namespace: dev"
echo ""
echo "4. Or apply Argo CD Application manifest:"
cat > /tmp/argocd-app-template.yaml <<'EOF'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: gitlab-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitlab.local/root/iot-application
    targetRevision: main
    path: .
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF
echo "   kubectl apply -f /tmp/argocd-app-template.yaml"
echo ""
echo "5. Verify everything is working:"
echo "   kubectl get namespaces"
echo "   kubectl get pods -n argocd"
echo "   kubectl get pods -n gitlab"
echo "   kubectl get pods -n dev"
