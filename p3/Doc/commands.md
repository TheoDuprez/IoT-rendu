# Useful Commands for Part 3 (K3d and Argo CD)

This document contains commands to test and verify the K3d cluster setup with Argo CD and the deployed application.


# Installation Verification

# 1. Check Docker Installation

# Verify Docker is installed and running

- docker --version         
- docker ps

# Check if Docker daemon is active
systemctl status docker

# 2. Check K3d Installation
# Verify K3d is installed
- k3d version

# List all K3d clusters
- k3d cluster list

# Check cluster status
- k3d cluster list --verbose
                

# 3. Check kubectl Installation

# Verify kubectl is installed
- kubectl version --client

# Check cluster connectivity
- kubectl cluster-info


# Cluster Management

# Create K3d Cluster
- k3d cluster create mycluster

# Create cluster with specific name and port mapping
- k3d cluster create mycluster -p "8888:8888@loadbalancer"

# Create cluster with port mapping for both application and Argo CD
- k3d cluster create mycluster -p "8888:8888@loadbalancer" -p "8080:8080@loadbalancer"

# Delete K3d Cluster
- k3d cluster delete mycluster

# Delete all clusters
- k3d cluster delete --all

# Access K3d Cluster
# Get kubeconfig
- k3d kubeconfig get mycluster


# Application Verification

# Check Deployment Status

- kubectl get deployments -n dev

# Get detailed deployment info
- kubectl describe deployment -n dev

# Get deployment in YAML format
- kubectl get deployment -n dev -o yaml


# Check Pods
- kubectl get pods -n dev

# Get pods with more details
- kubectl get pods -n dev -o wide

# View pod logs
- kubectl logs <pod-name> -n dev

# Describe specific pod
- kubectl describe pod <pod-name> -n dev


### Check Services

# Get services in dev namespace
- kubectl get services -n dev

# Get service details
- kubectl describe service <service-name> -n dev

# Get service endpoints
- kubectl get endpoints -n dev

# Testing Application

# Test Application Endpoint (Port 8080)
- curl http://localhost:8080/

# Expected response (v1):
# {"status":"ok", "message":"v1"}

# Expected response (v2):
# {"status":"ok", "message":"v2"}

# Port Forwarding to Application

# Forward local port to application service
- kubectl port-forward svc/<service-name> 8888:8888 -n dev

# Get admin password for Argo CD
- kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# Then test in another terminal:
- 

# ccess Application via LoadBalancer
- kubectl get service -n dev

# Version Update Testing

# Update Application Version in GitHub

# Clone/update your GitHub repository locally
git clone https://github.com/lciullo/iot_lciullo.git
cd  $HOME/iot_lciullo/

# Edit deployment.yaml to change version (v1 → v2)
- sed -i 's/wil42\/playground:v1/wil42\/playground:v2/g' deployment.yaml

# Or manually edit the file:
# Change: image: wil42/playground:v1
# To:     image: wil42/playground:v2

# Commit and push changes
- git add deployment.yaml
- git commit -m "Update application to v2"
- git push origin main
