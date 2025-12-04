# Inception of Things — Part 3 (K3d and Argo CD)

# Objective  
Set up a local Kubernetes cluster using K3d and implement continuous deployment using Argo CD. 
Deploy an application in two versions from a public GitHub repository and automatically manage updates through Argo CD.

# Host prerequisites
- Docker (required for K3d)
- K3d (lightweight Kubernetes in Docker)
- kubectl (Kubernetes command-line tool)
- git (for version control)
- curl or similar HTTP client (for testing)
- Public GitHub repository access
- Public Docker Hub repository (if using a custom application)

# p3 structure
- installation.sh - Script to install all necessary packages and tools (Docker, K3d, kubectl, etc.)
- k3d_config.sh - Script to configure and create the K3d cluster
In iot_lciullo public repository gitHub.com/lciullo/iot_lciullo : 
- manifests/` - Kubernetes YAML configuration files
  - deployment.yaml- Application deployment with version tags
  - application.yaml - Argo CD application configuration
  - service.yam - Service configuration for the application

# p3 Doc structure
- README.md - This file, project overview and specifications
- commands.md - Useful commands for verification and testing

# Subject specifications

# K3d Cluster
- **K3d** is a lightweight wrapper around K3s that runs in Docker containers
- Difference from K3s: K3s is a standalone Kubernetes distribution, K3d runs K3s inside Docker
- Create a single-node K3d cluster for this project
- No Vagrant required (runs directly on the host with Docker)

# Namespaces
Two namespaces must be created:

1. **argocd** - Dedicated to Argo CD deployment and management
2. **dev** - Contains the application deployment managed by Argo CD

# Argo CD Setup
- Install Argo CD in the `argocd` namespace
- Configure Argo CD to watch a public GitHub repository
- Automatically deploy and update the application when the repository changes
- Application must support version changes (v1, v2, etc.)

# Application Requirements
Two options are available for the application:
Option 1: Pre-made Application (Wil's Playground)
Option 2: Custom Application

# GitHub Repository
- Create a public GitHub repository with your login in the name
- Example: `lciullo-iot` or `lciullo-argocd`
- Store the deployment configuration files (deployment.yaml, application.yaml, service.yaml)
- Must be publicly accessible for Argo CD to pull from it

# Version Control & Continuous Deployment
1. Deployment manifests stored in GitHub (e.g., deployment.yaml with image tag v1)
2. Update the GitHub repository to change the application version (e.g., v1 → v2)
3. Argo CD automatically detects the change and syncs the cluster
4. Application is updated without manual kubectl intervention

# Validation
To verify the setup is complete:

1. K3d cluster is running and accessible
2. Docker and required tools are installed
3. Both `argocd` and `dev` namespaces exist
4. Argo CD is deployed and accessible
5. Application is running in the `dev` namespace with correct version
6. Argo CD successfully syncs the GitHub repository
7. Version changes in GitHub repository automatically update the running application

# Expected Output Examples

```bash
# Check namespaces
$ kubectl get ns
NAME      STATUS   AGE
argocd    Active   2h
dev       Active   2h

# Check pods in dev namespace
$ kubectl get pods -n dev
NAME                               READY   STATUS    RESTARTS   AGE
wil-playground-6779d9458d-bfpx6   1/1     Running   0          5m

# Check services
$ kubectl get svc -n dev
NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
wil-playground-service   ClusterIP   10.43.253.76   <none>        80/TCP    5m


