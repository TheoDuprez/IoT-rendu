# Inception of Things — Bonus (GitLab Integration with ArgoCD)

## Objective
Extend Part 3 by adding GitLab to the local Kubernetes cluster and configure ArgoCD to work with the local GitLab instance instead of GitHub.

## Host Prerequisites
- Docker (required for K3d)
- K3d (lightweight Kubernetes in Docker)
- kubectl (Kubernetes command-line tool)
- helm (Kubernetes package manager)
- git (for version control)
- curl (for testing HTTP endpoints)
- jq (for JSON processing)

## Bonus Structure
```
bonus/
├── prerequis_installation.sh   - Install all required tools
├── setup_cluster.sh             - Create K3d cluster
├── install_gitlab.sh            - Deploy GitLab via Helm
├── install_argocd.sh            - Deploy ArgoCD
├── create_gitlab_pat.sh         - Create GitLab Personal Access Token
├── import_github_to_gitlab.sh   - Import GitHub repo to GitLab
├── connect_argocd_to_gitlab.sh  - Configure ArgoCD to use GitLab
├── switch_version.sh            - Switch application version (v1/v2)
├── Makefile                     - Automation commands
└── Doc/
    ├── README.md                - This file
    └── commands.md              - Useful commands
```

## Subject Specifications

### GitLab Requirements
- **Latest version** of GitLab from official sources (using Helm chart)
- Must run **locally** within the K3d cluster
- Dedicated namespace: `gitlab`
- All Part 3 functionality must work with local GitLab

### Namespaces
Three namespaces must be created:

1. **gitlab** - GitLab instance and related services
2. **argocd** - ArgoCD deployment and management
3. **dev** - Application deployment managed by ArgoCD

### Integration Flow
```
GitHub Repo → GitLab (local) → ArgoCD → Kubernetes (dev namespace)
```

1. Import the GitHub repository into local GitLab
2. Configure ArgoCD to watch the GitLab repository
3. Deploy application from GitLab repository
4. Support version switching (v1 ↔ v2)

## Installation Steps

### 1. Install Prerequisites
```bash
cd bonus
./prerequis_installation.sh
```
Installs: Docker, K3d, kubectl, helm, jq

### 2. Setup K3d Cluster
```bash
./setup_cluster.sh
```
Creates a K3d cluster named `iot-cluster` with proper port mappings.

### 3. Install GitLab
```bash
./install_gitlab.sh
```
- Deploys GitLab CE via Helm in `gitlab` namespace
- Uses minimal configuration for local development
- Exposes GitLab on `gitlab.local:8181`

**Important:** Add to `/etc/hosts`:
```
127.0.0.1 gitlab.local
```

### 4. Install ArgoCD
```bash
./install_argocd.sh
```
- Deploys ArgoCD in `argocd` namespace
- Configures admin access

### 5. Create GitLab Personal Access Token
```bash
./create_gitlab_pat.sh
```
- Creates a Personal Access Token via GitLab Rails Console
- Token saved to `/tmp/gitlab_pat.txt`
- Required scopes: `api`, `read_repository`, `write_repository`

### 6. Import GitHub Repository to GitLab
```bash
./import_github_to_gitlab.sh
```
- Imports `iot_lciullo` repository from GitHub to local GitLab
- Creates project under `root/iot_lciullo`

### 7. Connect ArgoCD to GitLab
```bash
./connect_argocd_to_gitlab.sh
```
- Registers GitLab repository in ArgoCD
- Creates ArgoCD Application `wil-playground-app`
- Configures automatic sync from GitLab

## Application Management

### Switch Between Versions
```bash
# Switch to version 1
./switch_version.sh v1

# Switch to version 2
./switch_version.sh v2
```

This script:
1. Clones the GitLab repository
2. Updates `deployment/deployment.yaml` with the new version tag
3. Commits and pushes changes to GitLab
4. ArgoCD automatically detects and syncs the change

## Accessing Services

### GitLab UI
```bash
# Port-forward GitLab
kubectl -n gitlab port-forward svc/gitlab-webservice-default 8181:8181

# Get root password
kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 -d

# Open browser
http://gitlab.local:8181
```

### ArgoCD UI
```bash
# Port-forward ArgoCD
kubectl -n argocd port-forward svc/argocd-server 8080:443

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Open browser
https://localhost:8080
```

### Application
```bash
# Port-forward application
kubectl -n dev port-forward svc/wil-playground-service 8888:80

# Test application
curl http://localhost:8888
# Response: {"status":"ok", "message": "v1"} or v2
```

## Validation

### Check All Namespaces
```bash
kubectl get ns
# Expected: gitlab, argocd, dev
```

### Check GitLab Pods
```bash
kubectl get pods -n gitlab
# All pods should be Running
```

### Check ArgoCD Application
```bash
kubectl get applications -n argocd
# NAME                  SYNC STATUS   HEALTH STATUS
# wil-playground-app    Synced        Healthy
```

### Check Application Deployment
```bash
kubectl get pods -n dev
# NAME                              READY   STATUS    RESTARTS   AGE
# wil-playground-xxxxxxxxxx-xxxxx   1/1     Running   0          5m
```

### Verify Version
```bash
# Check deployment manifest
kubectl get deployment -n dev wil-playground -o jsonpath='{.spec.template.spec.containers[0].image}'
# Expected: wil42/playground:v1 or v2

# Test application response
curl http://localhost:8888
# Expected: {"status":"ok", "message": "v1"} or {"status":"ok", "message": "v2"}
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    K3d Cluster (iot-cluster)                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐  │
│  │   Namespace  │  │  Namespace   │  │   Namespace     │  │
│  │    gitlab    │  │   argocd     │  │      dev        │  │
│  ├──────────────┤  ├──────────────┤  ├─────────────────┤  │
│  │              │  │              │  │                 │  │
│  │  GitLab CE   │  │  ArgoCD      │  │  Application    │  │
│  │  - webservice│  │  - server    │  │  (playground)   │  │
│  │  - gitaly    │  │  - repo-srv  │  │  - v1 or v2     │  │
│  │  - postgres  │  │  - app-ctrl  │  │                 │  │
│  │  - redis     │  │              │  │                 │  │
│  │              │  │              │  │                 │  │
│  └──────────────┘  └──────────────┘  └─────────────────┘  │
│         │                  │                    ▲          │
│         │                  └────────────────────┘          │
│         │                   GitOps Sync                    │
│         │                                                  │
└─────────┼──────────────────────────────────────────────────┘
          │
          ▼
   Git Repository
   (root/iot_lciullo)
```

## GitLab Configuration Details

### Helm Chart Configuration
- **Edition:** Community Edition (CE)
- **Ingress:** Nginx (disabled cert-manager for local setup)
- **Persistence:** Enabled for Gitaly
- **Resources:** Minimized for local development
  - Webservice: 512Mi RAM, 100m CPU
  - Sidekiq: 256Mi RAM, 50m CPU

### Why GitLab Rails Console?
- GitLab CE doesn't support Project Access Tokens via API
- Personal Access Tokens created via `gitlab-rails runner`
- Executed in toolbox or webservice pod

## Troubleshooting

### GitLab pods not starting
```bash
# Check pod status
kubectl get pods -n gitlab

# Check specific pod logs
kubectl logs -n gitlab <pod-name>

# Common issue: insufficient resources
# Solution: Ensure Docker has enough RAM allocated (8GB+ recommended)
```

### ArgoCD can't connect to GitLab
```bash
# Verify secret exists
kubectl get secret -n argocd gitlab-repo

# Check if secret has correct label
kubectl get secret -n argocd gitlab-repo -o yaml | grep argocd.argoproj.io

# Restart ArgoCD repo-server
kubectl rollout restart deployment argocd-repo-server -n argocd
```

### Application not syncing
```bash
# Check ArgoCD application status
kubectl get application -n argocd wil-playground-app -o yaml

# Force refresh
kubectl patch application wil-playground-app -n argocd \
  -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}' --type merge
```

### Port-forward issues
```bash
# Kill existing port-forwards
pkill -f "port-forward"

# Restart port-forwards
kubectl -n gitlab port-forward svc/gitlab-webservice-default 8181:8181 &
kubectl -n argocd port-forward svc/argocd-server 8080:443 &
```

## Cleanup

### Remove GitLab only
```bash
make clean-gitlab
```

### Full cleanup
```bash
make fclean
```
Removes:
- K3d cluster
- GitLab deployment
- ArgoCD deployment
- All namespaces
- Temporary files

## Key Differences from Part 3

| Aspect | Part 3 (GitHub) | Bonus (GitLab) |
|--------|----------------|----------------|
| Git Provider | GitHub (cloud) | GitLab (local) |
| Repository Access | Public GitHub repo | Local GitLab instance |
| Authentication | None (public) | Personal Access Token |
| Namespaces | 2 (argocd, dev) | 3 (gitlab, argocd, dev) |
| Setup Complexity | Simple | Complex (GitLab deployment) |
| Network | Internet required | Fully local (offline capable) |

## Technical Challenges Solved

1. **GitLab CE Limitation:** Project Access Tokens not available via API
   - Solution: Use Personal Access Token via Rails Console

2. **Internal Cluster DNS:** ArgoCD needs to access GitLab within cluster
   - Solution: Use internal service URL `gitlab-webservice-default.gitlab.svc.cluster.local`

3. **Secret Format:** ArgoCD requires specific label for repository secrets
   - Solution: Add label `argocd.argoproj.io/secret-type: repository`

4. **Version Switching:** Manual git operations from local machine
   - Solution: Automated script with port-forward detection

## Makefile Commands

```bash
make install           # Full installation (all steps)
make setup-cluster     # Create K3d cluster only
make install-gitlab    # Install GitLab only
make install-argocd    # Install ArgoCD only
make create-pat        # Create GitLab PAT
make import-repo       # Import GitHub to GitLab
make connect           # Connect ArgoCD to GitLab
make switch-v1         # Switch to version 1
make switch-v2         # Switch to version 2
make status            # Check all components status
make clean-gitlab      # Remove GitLab
make fclean            # Full cleanup
```

## Expected Demo Flow

1. Start from clean state: `make fclean`
2. Install everything: `make install`
3. Wait for all pods to be ready (~5-10 minutes)
4. Verify GitLab UI is accessible
5. Verify ArgoCD UI shows synced application
6. Check application is running: `curl http://localhost:8888`
7. Switch version: `make switch-v2`
8. Verify ArgoCD detects change and syncs
9. Check new version: `curl http://localhost:8888`

## Resources

- [GitLab Helm Chart](https://docs.gitlab.com/charts/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [K3d Documentation](https://k3d.io/)
- [Wil's Playground on DockerHub](https://hub.docker.com/r/wil42/playground)
