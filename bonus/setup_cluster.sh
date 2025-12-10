#!/bin/bash

set -e

### Colors ###
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== K3d Cluster Setup ===${NC}"

CLUSTER_NAME="iot-cluster"

# Check if cluster already exists
if k3d cluster list | grep -q "$CLUSTER_NAME"; then
    echo -e "${YELLOW}Cluster '$CLUSTER_NAME' already exists.${NC}"
    echo "Starting cluster..."
    k3d cluster start "$CLUSTER_NAME" || true
else
    echo -e "${BLUE}Creating K3d cluster '$CLUSTER_NAME'...${NC}"
    # Create cluster with Traefik disabled and ports configured
    k3d cluster create "$CLUSTER_NAME" \
        --k3s-arg "--disable=traefik@server:0" \
        -p "80:80@loadbalancer" \
        -p "443:443@loadbalancer" \
        -p "8888:8888@loadbalancer" \
        --wait
fi

echo -e "${BLUE}Waiting for cluster to be ready...${NC}"
sleep 5

# Verify cluster is running
if kubectl cluster-info >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Cluster is ready${NC}"
else
    echo -e "${RED}✗ Failed to connect to cluster${NC}"
    exit 1
fi

# Create namespaces
echo -e "${BLUE}Creating namespaces...${NC}"

if kubectl get namespace gitlab >/dev/null 2>&1; then
    echo -e "${YELLOW}Namespace 'gitlab' already exists${NC}"
else
    kubectl create namespace gitlab
    echo -e "${GREEN}✓ Namespace 'gitlab' created${NC}"
fi

if kubectl get namespace argocd >/dev/null 2>&1; then
    echo -e "${YELLOW}Namespace 'argocd' already exists${NC}"
else
    kubectl create namespace argocd
    echo -e "${GREEN}✓ Namespace 'argocd' created${NC}"
fi

if kubectl get namespace dev >/dev/null 2>&1; then
    echo -e "${YELLOW}Namespace 'dev' already exists${NC}"
else
    kubectl create namespace dev
    echo -e "${GREEN}✓ Namespace 'dev' created${NC}"
fi

echo -e "${GREEN}=== Cluster Setup Complete ===${NC}"
echo ""
echo -e "${YELLOW}Cluster info:${NC}"
kubectl cluster-info
echo ""
echo -e "${YELLOW}Available namespaces:${NC}"
kubectl get namespaces

