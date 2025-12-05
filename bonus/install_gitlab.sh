#!/bin/bash

set -e

### Colors ###
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' 

NAMESPACE="gitlab"
RELEASE_NAME="gitlab"
DOMAIN="local"

echo -e "${BLUE}=== GitLab Installation ===${NC}"
# Check if cluster is running
if ! kubectl cluster-info >/dev/null 2>&1; then
    echo -e "${RED}✗ Cluster is not running. Please run setup_cluster.sh first.${NC}"
    exit 1
fi

# Create namespace
echo -e "${BLUE}Creating gitlab namespace...${NC}"
kubectl create namespace "$NAMESPACE" 2>/dev/null || echo "Namespace already exists"

# Update Helm repos
echo -e "${BLUE}Updating Helm repositories...${NC}"
helm repo add gitlab https://charts.gitlab.io/ 2>/dev/null || true
helm repo update

# Check if GitLab is already installed
if helm list -n "$NAMESPACE" 2>/dev/null | grep -q "$RELEASE_NAME"; then
    echo -e "${YELLOW}GitLab is already installed${NC}"
    echo "Skipping installation..."
else
    echo -e "${BLUE}Installing GitLab (minimal)...${NC}"
    echo -e "${YELLOW}This may take several minutes...${NC}"
    
    helm install "$RELEASE_NAME" gitlab/gitlab \
        --namespace "$NAMESPACE" \
        --set global.hosts.domain="$DOMAIN" \
        --set global.edition=ce \
        --set certmanager.enabled=false \
        --set global.ingress.configureCertmanager=false \
        --set global.ingress.provider=nginx \
        --set postgresql.install=true \
        --set redis.install=true \
        --set gitaly.persistence.enabled=true \
        --set gitlab-runner.install=false \
        --set prometheus.install=false \
        --set installCertmanager=false \
        --set gitlab.webservice.resources.requests.memory=512Mi \
        --set gitlab.webservice.resources.requests.cpu=100m \
        --set gitlab.sidekiq.resources.requests.memory=256Mi \
        --set gitlab.sidekiq.resources.requests.cpu=50m \
        2>&1 | grep -v "deprecated"
    
    echo -e "${YELLOW}Installation lancée. Attendez que tous les pods soient Running...${NC}"
fi

echo -e "${BLUE}Waiting for GitLab pods to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=webservice -n "$NAMESPACE" --timeout=600s 2>/dev/null || true

# Get GitLab status
echo -e "${GREEN}=== GitLab Installation Status ===${NC}"
echo ""
echo -e "${YELLOW}Pods in gitlab namespace:${NC}"
kubectl get pods -n "$NAMESPACE"

echo ""
echo -e "${YELLOW}Services in gitlab namespace:${NC}"
kubectl get svc -n "$NAMESPACE"

echo ""
echo -e "${GREEN}✓ GitLab installation complete${NC}"

echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Add this to your /etc/hosts file:"
echo "   127.0.0.1 gitlab.local"
echo ""
echo "2. Access GitLab at: http://gitlab.local"
echo ""
echo "3. Get initial root password:"
echo "   kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo"
echo ""
echo "4. Monitor deployment:"
echo "   kubectl -n gitlab get pods"
echo "   helm status gitlab -n gitlab"
