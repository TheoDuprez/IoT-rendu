.PHONY: install setup-cluster install-gitlab install-argocd create-pat import-repo connect-argocd-to-gitlab help
.PHONY: cluster-list cluster-stop cluster-start cluster-delete cluster-show
.PHONY: gitlab-status argocd-status dev-status pods-all
.PHONY: password-gitlab uninstall-gitlab switch-v1 switch-v2 fclean clean-argocd clean-temp

# Get cluster name
CLUSTER_NAME := $(shell k3d cluster list --no-headers | awk '{print $$1}')

# Default target
help:
	@echo "\033[1;36m=== Inception of Things - Bonus Part ===\033[0m"
	@echo "\033[1;33mSetup targets (run in order):\033[0m"
	@echo "  \033[1;32m1- make install\033[0m              - Install prerequisites (Docker, k3d, kubectl, Helm, jq)"
	@echo "  \033[1;32m2- make setup-cluster\033[0m        - Create K3d cluster"
	@echo "  \033[1;32m3- make install-gitlab\033[0m       - Install GitLab"
	@echo "  \033[1;32m4- make install-argocd\033[0m       - Install ArgoCD"
	@echo "  \033[1;32m5- make create-pat\033[0m           - Create GitLab Personal Access Token"
	@echo "  \033[1;32m6- make import-repo\033[0m          - Import GitHub repo to GitLab"
	@echo "  \033[1;32m7- make connect-argocd-to-gitlab\033[0m - Connect ArgoCD to GitLab"
	@echo "\033[1;36m----------------------------------------------------------------\033[0m"
	@echo "\033[1;33mCluster management:\033[0m"
	@echo "  \033[1;32mmake cluster-show\033[0m            - Display active cluster name"
	@echo "  \033[1;32mmake cluster-list\033[0m            - List all K3d clusters"
	@echo "  \033[1;32mmake cluster-stop\033[0m            - Stop K3d cluster"
	@echo "  \033[1;32mmake cluster-start\033[0m           - Start K3d cluster"
	@echo "  \033[1;32mmake cluster-delete\033[0m          - Delete K3d cluster"
	@echo "\033[1;36m----------------------------------------------------------------\033[0m"
	@echo "\033[1;33mStatus and monitoring:\033[0m"
	@echo "  \033[1;32mmake gitlab-status\033[0m           - Check GitLab pods"
	@echo "  \033[1;32mmake argocd-status\033[0m           - Check ArgoCD pods"
	@echo "  \033[1;32mmake dev-status\033[0m              - Check application pods"
	@echo "  \033[1;32mmake pods-all\033[0m                - Show all pods"
	@echo "\033[1;36m----------------------------------------------------------------\033[0m"
	@echo "\033[1;33mApplication version switching:\033[0m"
	@echo "  \033[1;32mmake switch-v1\033[0m               - Switch to version 1"
	@echo "  \033[1;32mmake switch-v2\033[0m               - Switch to version 2"
	@echo "\033[1;36m----------------------------------------------------------------\033[0m"
	@echo "\033[1;33mUtilities:\033[0m"
	@echo "  \033[1;32mmake password-gitlab\033[0m         - Get GitLab root password"
	@echo "  \033[1;32mmake uninstall-gitlab\033[0m        - Uninstall GitLab"
	@echo "  \033[1;32mmake clean-argocd\033[0m            - Clean ArgoCD"
	@echo "  \033[1;32mmake fclean\033[0m                  - Full cleanup"
	@echo ""

# Install prerequisites
install:
	@echo "\033[1;36m=== Step 1: Installing prerequisites ===\033[0m"
	@./prerequis_installation.sh
	@echo "\033[1;32m✓ Prerequisites installed\033[0m"

# Setup cluster
setup-cluster:
	@echo "\033[1;36m=== Step 2: Setting up K3d cluster ===\033[0m"
	@./setup_cluster.sh
	@echo "\033[1;32m✓ Cluster configured\033[0m"

# Install GitLab
install-gitlab:
	@echo "\033[1;36m=== Step 3: Installing GitLab ===\033[0m"
	@./install_gitlab.sh
	@echo "\033[1;32m✓ GitLab installed\033[0m"

# Install ArgoCD
install-argocd:
	@echo "\033[1;36m=== Step 4: Installing ArgoCD ===\033[0m"
	@./install_argocd.sh
	@echo "\033[1;32m✓ ArgoCD installed\033[0m"

# Create GitLab PAT
create-pat:
	@echo "\033[1;36m=== Step 5: Creating GitLab Personal Access Token ===\033[0m"
	@./create_gitlab_pat.sh
	@echo "\033[1;32m✓ PAT created\033[0m"

# Import GitHub repo
import-repo:
	@echo "\033[1;36m=== Step 6: Importing GitHub repo to GitLab ===\033[0m"
	@./import_github_to_gitlab.sh
	@echo "\033[1;32m✓ Repo imported\033[0m"

# Connect ArgoCD to GitLab
connect-argocd-to-gitlab:
	@echo "\033[1;36m=== Step 7: Connecting ArgoCD to GitLab ===\033[0m"
	@./connect_argocd_to_gitlab.sh
	@echo "\033[1;32m✓ ArgoCD connected to GitLab\033[0m"


# ------------------------------------------------
# Cluster management commands

cluster-show:
	@echo "\033[1;36mActive cluster: \033[1;33m$(CLUSTER_NAME)\033[0m"

cluster-list:
	@k3d cluster list

cluster-stop:
	@echo "\033[1;36mStopping K3d cluster '\033[1;33m$(CLUSTER_NAME)\033[1;36m'...\033[0m"
	@k3d cluster stop $(CLUSTER_NAME)
	@echo "\033[1;32m✓ Cluster stopped\033[0m"

cluster-start:
	@echo "\033[1;36mStarting K3d cluster '\033[1;33m$(CLUSTER_NAME)\033[1;36m'...\033[0m"
	@k3d cluster start $(CLUSTER_NAME)
	@echo "\033[1;32m✓ Cluster started\033[0m"

cluster-delete:
	@echo "\033[1;31m⚠ Deleting K3d cluster '\033[1;33m$(CLUSTER_NAME)\033[1;31m'...\033[0m"
	@k3d cluster delete $(CLUSTER_NAME)
	@echo "\033[1;32m✓ Cluster deleted\033[0m"

# ------------------------------------------------
# Status checks

gitlab-status:
	@echo "\033[1;36m=== GitLab pods status ===\033[0m"
	@kubectl -n gitlab get pods

argocd-status:
	@echo "\033[1;36m=== ArgoCD pods status ===\033[0m"
	@kubectl -n argocd get pods

dev-status:
	@echo "\033[1;36m=== Application pods status ===\033[0m"
	@kubectl -n dev get pods

pods-all:
	@echo "\033[1;36m=== All pods in all namespaces ===\033[0m"
	@kubectl get pods -A

# ------------------------------------------------
# GitLab utilities

# GitLab utilities

password-gitlab:
	@echo "\033[1;36m=== GitLab root password ===\033[0m"
	@kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode
	@echo ""

uninstall-gitlab:
	@echo "\033[1;31m⚠ Uninstalling GitLab...\033[0m"
	@helm uninstall gitlab -n gitlab 2>/dev/null || true
	@kubectl delete namespace gitlab 2>/dev/null || true
	@echo "\033[1;32m✓ GitLab uninstalled\033[0m"

# ------------------------------------------------
# Application version switching

switch-v1:
	@echo "\033[1;36m=== Switching to version 1 ===\033[0m"
	@./switch_version.sh v1

switch-v2:
	@echo "\033[1;36m=== Switching to version 2 ===\033[0m"
	@./switch_version.sh v2

# ------------------------------------------------
# Cleanup
# Cleanup

clean-argocd:
	@echo "\033[1;36m=== Cleaning ArgoCD ===\033[0m"
	@kubectl delete application -n argocd wil-playground-app --ignore-not-found=true
	@kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --ignore-not-found=true
	@kubectl delete namespace argocd --ignore-not-found=true
	@kubectl delete namespace dev --ignore-not-found=true
	@echo "\033[1;32m✓ ArgoCD cleaned\033[0m"

clean-temp:
	@echo "\033[1;36m=== Cleaning temporary files ===\033[0m"
	@if [ -f /tmp/gitlab_pat.txt ]; then rm -f /tmp/gitlab_pat.txt && echo "  Removed /tmp/gitlab_pat.txt"; fi
	@if [ -d /tmp/iot_lciullo ]; then rm -rf /tmp/iot_lciullo && echo "  Removed /tmp/iot_lciullo"; fi
	@echo "\033[1;32m✓ Temporary files cleaned\033[0m"

fclean: clean-argocd uninstall-gitlab cluster-delete clean-temp
	@echo "\033[1;32m✓ Full cleanup complete\033[0m"
