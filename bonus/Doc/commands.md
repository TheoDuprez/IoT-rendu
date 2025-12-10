# Useful Commands for Bonus (GitLab + ArgoCD)

This document contains commands to test and verify the K3d cluster setup with GitLab, ArgoCD, and the deployed application.

## Installation Verification

### 1. Check Docker Installation
```bash
# Verify Docker is installed and running
docker --version
docker ps

# Check if Docker daemon is active
systemctl status docker
```

### 2. Check K3d Installation
```bash
# Verify K3d is installed
k3d version

# List all K3d clusters
k3d cluster list

# Check cluster status
k3d cluster list --verbose
```

### 3. Check kubectl Installation
```bash
# Verify kubectl is installed
kubectl version --client

# Check cluster connectivity
kubectl cluster-info
```

### 4. Check Helm Installation
```bash
# Verify Helm is installed
helm version

# List installed releases
helm list --all-namespaces
```

### 5. Check jq Installation
```bash
# Verify jq is installed
jq --version
```

## Cluster Management

### Create K3d Cluster
```bash
# Create cluster with port mappings for GitLab, ArgoCD, and application
k3d cluster create iot-cluster -p "8181:8181@loadbalancer" -p "8080:8080@loadbalancer" -p "8888:8888@loadbalancer"
```

### Delete K3d Cluster
```bash
# Delete specific cluster
k3d cluster delete iot-cluster

# Delete all clusters
k3d cluster delete --all
```

### Access K3d Cluster
```bash
# Get kubeconfig
k3d kubeconfig get iot-cluster

# Merge with existing kubeconfig
k3d kubeconfig merge iot-cluster
```

## Namespace Management

### Check Namespaces
```bash
# List all namespaces
kubectl get namespaces

# Expected namespaces: gitlab, argocd, dev
kubectl get ns | grep -E "gitlab|argocd|dev"
```

### Create Namespaces
```bash
# Create gitlab namespace
kubectl create namespace gitlab

# Create argocd namespace
kubectl create namespace argocd

# Create dev namespace
kubectl create namespace dev
```

## GitLab Management

### Check GitLab Installation
```bash
# Check GitLab pods
kubectl get pods -n gitlab

# Check all pods are running
kubectl get pods -n gitlab | grep Running

# Check GitLab services
kubectl get svc -n gitlab

# Check GitLab Helm release
helm list -n gitlab
```

### GitLab Pod Logs
```bash
# Get webservice logs
kubectl logs -n gitlab -l app=webservice --tail=50

# Get gitaly logs
kubectl logs -n gitlab -l app=gitaly --tail=50

# Get all pods logs
kubectl logs -n gitlab --all-containers=true -l release=gitlab --tail=100
```

### GitLab Secrets
```bash
# Get root password
kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 --decode
echo ""

# List all secrets
kubectl get secrets -n gitlab
```

### GitLab Access
```bash
# Port-forward GitLab webservice
kubectl -n gitlab port-forward svc/gitlab-webservice-default 8181:8181

# Access GitLab in browser
# http://gitlab.local:8181

# Check /etc/hosts entry
grep gitlab.local /etc/hosts
# Should contain: 127.0.0.1 gitlab.local
```

### GitLab Rails Console
```bash
# Find toolbox pod
TOOLBOX_POD=$(kubectl get pods -n gitlab -l app=toolbox -o jsonpath='{.items[0].metadata.name}')

# Or find webservice pod
WEBSERVICE_POD=$(kubectl get pods -n gitlab -l app=webservice -o jsonpath='{.items[0].metadata.name}')

# Access Rails console
kubectl exec -it -n gitlab $TOOLBOX_POD -- gitlab-rails console

# Run Rails command
kubectl exec -n gitlab $TOOLBOX_POD -- gitlab-rails runner "puts User.count"
```

### GitLab Personal Access Token
```bash
# Check if PAT file exists
cat /tmp/gitlab_pat.txt

# Create new PAT via script
./create_gitlab_pat.sh

# Verify PAT works
curl --insecure --header "PRIVATE-TOKEN: $(cat /tmp/gitlab_pat.txt)" \
  "http://gitlab.local:8181/api/v4/user"
```

### GitLab Projects
```bash
# List projects via API
curl --insecure --header "PRIVATE-TOKEN: $(cat /tmp/gitlab_pat.txt)" \
  "http://gitlab.local:8181/api/v4/projects" | jq

# Get specific project
curl --insecure --header "PRIVATE-TOKEN: $(cat /tmp/gitlab_pat.txt)" \
  "http://gitlab.local:8181/api/v4/projects/root%2Fiot_lciullo" | jq

# Check repository tree
curl --insecure --header "PRIVATE-TOKEN: $(cat /tmp/gitlab_pat.txt)" \
  "http://gitlab.local:8181/api/v4/projects/root%2Fiot_lciullo/repository/tree" | jq
```

## ArgoCD Management

### Check ArgoCD Installation
```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# Check ArgoCD services
kubectl get svc -n argocd

# Check ArgoCD Helm/manifest installation
kubectl get all -n argocd
```

### ArgoCD Access
```bash
# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""

# Port-forward ArgoCD server
kubectl -n argocd port-forward svc/argocd-server 8080:443

# Access ArgoCD in browser
# https://localhost:8080
# Username: admin
# Password: (from command above)
```

### ArgoCD Applications
```bash
# List applications
kubectl get applications -n argocd

# Get application details
kubectl get application wil-playground-app -n argocd -o yaml

# Describe application
kubectl describe application wil-playground-app -n argocd

# Check application sync status
kubectl get application wil-playground-app -n argocd -o jsonpath='{.status.sync.status}'
```

### ArgoCD Repositories
```bash
# List repository secrets
kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=repository

# Get repository secret details
kubectl get secret gitlab-repo -n argocd -o yaml

# Check repository URL
kubectl get secret gitlab-repo -n argocd -o jsonpath='{.data.url}' | base64 -d
echo ""

# Check repository password (PAT)
kubectl get secret gitlab-repo -n argocd -o jsonpath='{.data.password}' | base64 -d
echo ""
```

### ArgoCD Sync Operations
```bash
# Force sync application
kubectl patch application wil-playground-app -n argocd \
  -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}' --type merge

# Restart ArgoCD components
kubectl rollout restart deployment argocd-server -n argocd
kubectl rollout restart deployment argocd-repo-server -n argocd
kubectl rollout restart statefulset argocd-application-controller -n argocd
```

### ArgoCD Logs
```bash
# Server logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server --tail=50

# Repo server logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-repo-server --tail=50

# Application controller logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller --tail=50
```

## Application Management

### Check Application Deployment
```bash
# Get deployments in dev namespace
kubectl get deployments -n dev

# Get detailed deployment info
kubectl describe deployment wil-playground -n dev

# Get deployment image version
kubectl get deployment wil-playground -n dev -o jsonpath='{.spec.template.spec.containers[0].image}'
```

### Check Application Pods
```bash
# Get pods in dev namespace
kubectl get pods -n dev

# Get pods with more details
kubectl get pods -n dev -o wide

# View pod logs
kubectl logs -n dev -l app=wil-playground --tail=50

# Describe specific pod
kubectl describe pod -n dev <pod-name>
```

### Check Application Services
```bash
# Get services in dev namespace
kubectl get services -n dev

# Get service details
kubectl describe service wil-playground-service -n dev

# Get service endpoints
kubectl get endpoints -n dev
```

### Test Application
```bash
# Port-forward to application
kubectl port-forward -n dev svc/wil-playground-service 8888:80

# Test application endpoint
curl http://localhost:8888

# Expected response (v1):
# {"status":"ok", "message":"v1"}

# Expected response (v2):
# {"status":"ok", "message":"v2"}
```

## Version Switching

### Manual Git Operations
```bash
# Clone GitLab repository
git clone http://gitlab.local:8181/root/iot_lciullo.git /tmp/iot_lciullo

# Change to repository directory
cd /tmp/iot_lciullo

# Check current version
grep "image:" deployment/deployment.yaml

# Switch to v2
sed -i 's/wil42\/playground:v1/wil42\/playground:v2/g' deployment/deployment.yaml

# Or switch to v1
sed -i 's/wil42\/playground:v2/wil42\/playground:v1/g' deployment/deployment.yaml

# Configure git
git config user.email "admin@local"
git config user.name "Admin"

# Commit and push
git add deployment/deployment.yaml
git commit -m "Switch to v2"
git push http://root:$(cat /tmp/gitlab_pat.txt)@gitlab.local:8181/root/iot_lciullo.git main
```

### Using Switch Script
```bash
# Switch to version 1
./switch_version.sh v1

# Switch to version 2
./switch_version.sh v2
```

### Verify Version Change
```bash
# Check ArgoCD detects change
kubectl get application wil-playground-app -n argocd -o jsonpath='{.status.sync.status}'

# Wait for sync
watch kubectl get application wil-playground-app -n argocd

# Check new pod is created
kubectl get pods -n dev -w

# Verify new version
curl http://localhost:8888
```

## Troubleshooting

### Check All Components Status
```bash
# Check all pods in all namespaces
kubectl get pods --all-namespaces

# Check only gitlab, argocd, dev
kubectl get pods -n gitlab
kubectl get pods -n argocd
kubectl get pods -n dev
```

### Check Resource Usage
```bash
# Node resources
kubectl top nodes

# Pod resources in gitlab
kubectl top pods -n gitlab

# Pod resources in argocd
kubectl top pods -n argocd

# Pod resources in dev
kubectl top pods -n dev
```

### Check Events
```bash
# All events
kubectl get events --all-namespaces --sort-by='.lastTimestamp'

# Events in specific namespace
kubectl get events -n gitlab
kubectl get events -n argocd
kubectl get events -n dev
```

### Check Persistent Volumes
```bash
# List PVCs
kubectl get pvc --all-namespaces

# Check GitLab PVCs
kubectl get pvc -n gitlab

# Describe specific PVC
kubectl describe pvc -n gitlab <pvc-name>
```

### Network Debugging
```bash
# Test DNS resolution from within cluster
kubectl run -it --rm debug --image=alpine --restart=Never -- nslookup gitlab-webservice-default.gitlab.svc.cluster.local

# Test HTTP connectivity
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
  curl http://gitlab-webservice-default.gitlab.svc.cluster.local:8181

# Check network policies
kubectl get networkpolicies --all-namespaces
```

### Clean Up
```bash
# Delete application
kubectl delete application wil-playground-app -n argocd

# Delete repository secret
kubectl delete secret gitlab-repo -n argocd

# Delete GitLab
helm uninstall gitlab -n gitlab

# Delete ArgoCD
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Delete namespaces
kubectl delete namespace gitlab
kubectl delete namespace argocd
kubectl delete namespace dev

# Delete cluster
k3d cluster delete iot-cluster

# Remove temporary files
rm -f /tmp/gitlab_pat.txt
rm -rf /tmp/iot_lciullo
```

## Useful Aliases
```bash
# Add to ~/.bashrc or ~/.zshrc
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kl='kubectl logs'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods --all-namespaces'
alias kgn='kubectl get nodes'
alias kgsvc='kubectl get svc'

# GitLab specific
alias gitlab-pods='kubectl get pods -n gitlab'
alias gitlab-logs='kubectl logs -n gitlab'
alias gitlab-pf='kubectl -n gitlab port-forward svc/gitlab-webservice-default 8181:8181'

# ArgoCD specific
alias argocd-pods='kubectl get pods -n argocd'
alias argocd-apps='kubectl get applications -n argocd'
alias argocd-pf='kubectl -n argocd port-forward svc/argocd-server 8080:443'

# Application specific
alias app-pods='kubectl get pods -n dev'
alias app-logs='kubectl logs -n dev -l app=wil-playground'
alias app-pf='kubectl -n dev port-forward svc/wil-playground-service 8888:80'
```

## Complete Validation Checklist
```bash
# 1. Cluster running
k3d cluster list | grep iot-cluster

# 2. Namespaces exist
kubectl get ns | grep -E "gitlab|argocd|dev"

# 3. GitLab running
kubectl get pods -n gitlab | grep Running

# 4. ArgoCD running
kubectl get pods -n argocd | grep Running

# 5. Application running
kubectl get pods -n dev | grep Running

# 6. ArgoCD application synced
kubectl get application wil-playground-app -n argocd -o jsonpath='{.status.sync.status}'

# 7. Application responds
curl http://localhost:8888

# 8. Version switch works
./switch_version.sh v2
sleep 30
curl http://localhost:8888 | grep v2
```
