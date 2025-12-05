.PHONY: install config-cluster setup-gitlab setup-argocd help 
.PHONY: cluster-list cluster-stop cluster-start cluster-delete cluster-show cluster-delete-namespaces
.PHONY: gitlab-status argocd-status pods-all
.PHONY: curl-gitlab password-gitlab uninstall-gitlab setup-gitlab-repo fclean clean-argocd

# Get cluster name
CLUSTER_NAME := $(shell k3d cluster list --no-headers | awk '{print $$1}')

# Default target
help:
	@echo "\033[1;36m=== Inception of Things - Bonus Part ===\033[0m"
	@echo "\033[1;33mSetup targets (run in order):\033[0m"
	@echo "  \033[1;32m1- make install\033[0m           - Install local prerequisites (Docker, k3d, kubectl, Helm)"
	@echo "  \033[1;32m2- make config-cluster\033[0m    - Create and configure K3d cluster with namespaces"
	@echo "  \033[1;32m3- make setup-gitlab\033[0m      - Install GitLab in the cluster"
	@echo "  \033[1;32m4- make setup-gitlab-repo\033[0m - Import IoT application repo into GitLab"
	@echo "  \033[1;32m5- make setup-argocd\033[0m      - Install and configure Argo CD with GitLab"
	@echo "\033[1;36m----------------------------------------------------------------\033[0m"
	@echo "\033[1;33mCluster management:\033[0m"
	@echo "  \033[1;32mmake cluster-show\033[0m         - Display active cluster name"
	@echo "  \033[1;32mmake cluster-list\033[0m         - List all K3d clusters"
	@echo "  \033[1;32mmake cluster-stop\033[0m         - Stop K3d cluster"
	@echo "  \033[1;32mmake cluster-start\033[0m        - Start K3d cluster"
	@echo "  \033[1;32mmake cluster-delete\033[0m       - Delete K3d cluster"
	@echo "\033[1;36m----------------------------------------------------------------\033[0m"
	@echo "\033[1;33mStatus and monitoring:\033[0m"
	@echo "  \033[1;32mmake gitlab-status\033[0m        - Check GitLab pods status"
	@echo "  \033[1;32mmake argocd-status\033[0m        - Check Argo CD pods status"
	@echo "  \033[1;32mmake pods-all\033[0m             - Show all pods in all namespaces"
	@echo "\033[1;36m----------------------------------------------------------------\033[0m"
	@echo "\033[1;33mGitLab testing and cleanup:\033[0m"
	@echo "  \033[1;32mmake curl-gitlab\033[0m          - Test GitLab with curl"
	@echo "  \033[1;32mmake password-gitlab\033[0m      - Get GitLab initial root password"
	@echo "  \033[1;32mmake uninstall-gitlab\033[0m     - Uninstall GitLab from cluster"
	@echo "\033[1;36m----------------------------------------------------------------\033[0m"
	@echo "  \033[1;32mmake fclean\033[0m               - Full cleanup (uninstall GitLab + delete cluster)"
	@echo ""


# Install prerequisites
install:
	@echo "\033[1;36m Stept 1 \033[0m"
	@echo "\033[1;36m=== Installing prerequisites ===\033[0m"
	@./prerequis_installation.sh
	@echo "\033[1;32m✓ Prerequisites installed\033[0m"

# Configure cluster
config-cluster:
	@echo "\033[1;36m Stept 2 \033[0m"
	@echo "\033[1;36m=== Configuring K3d cluster ===\033[0m"
	@./setup_cluster.sh
	@echo "\033[1;32m✓ Cluster configured\033[0m"

# Setup GitLab
setup-gitlab:
	@echo "\033[1;36m Stept 3 \033[0m"
	@echo "\033[1;36m=== Setting up GitLab ===\033[0m"
	@./install_gitlab.sh
	@echo "\033[1;32m✓ GitLab setup complete\033[0m"

# Import github repo into GitLab
setup-gitlab-repo:
	@echo "\033[1;36m=== Importing IoT application repo into GitLab ===\033[0m"
	@./import_github_to_gitlab.sh
	@echo "\033[1;32m✓ Repo imported into GitLab\033[0m"

# Setup Argo CD
setup-argocd:
	@echo "\033[1;36m Stept 4 \033[0m"
	@echo "\033[1;36m=== Setting up Argo CD ===\033[0m"
	@./setup_argocd_gitlab.sh
	@echo "\033[1;32m✓ Argo CD setup complete\033[0m"


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

cluster-delete-namespaces:
	@echo "\033[1;31m⚠ Deleting all namespaces in cluster '\033[1;33m$(CLUSTER_NAME)\033[1;31m'...\033[0m"
	@kubectl delete namespace gitlab argocd
	@echo "\033[1;32m✓ Namespaces deleted\033[0m"

cluster-delete:
	@echo "\033[1;31m⚠ Deleting K3d cluster '\033[1;33m$(CLUSTER_NAME)\033[1;31m'...\033[0m"
	@k3d cluster delete $(CLUSTER_NAME)
	@echo "\033[1;32m✓ Cluster deleted\033[0m"

# ------------------------------------------------
# GitLab useful commands

add-hosts-entry:
	@echo "\033[1;36m=== Add GitLab entry to /etc/hosts ===\033[0m"
	@echo "127.0.0.1 gitlab.local" | sudo tee -a /etc/hosts

curl-gitlab:
	@echo "\033[1;36m=== Curl GitLab homepage ===\033[0m"
	@curl -k http://gitlab.local

password-gitlab:
	@echo "\033[1;36m=== GitLab initial root password ===\033[0m"
	@kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo


show-values:
	@echo "\033[1;36m=== Show GitLab Helm chart values ===\033[0m"
	@helm show values gitlab/gitlab

uninstall-gitlab:
	@echo "\033[1;31m⚠ Uninstalling GitLab from cluster...\033[0m"
	@helm uninstall gitlab -n gitlab 2>/dev/null || true
	@kubectl delete namespace gitlab 2>/dev/null || true
	@echo "\033[1;32m✓ GitLab uninstalled\033[0m"

# ------------------------------------------------
# Pods useful commands

# Status checks
pods-all:
	@echo "\033[1;36m=== All pods in all namespaces ===\033[0m"
	@kubectl get pods -A

gitlab-status:
	@echo "\033[1;36m=== GitLab pods status ===\033[0m"
	@kubectl -n gitlab get pods

argocd-status:
	@echo "\033[1;36m=== Argo CD pods status ===\033[0m"
	@kubectl -n argocd get pods


# ------------------------------------------------
# Argo CD cleanup command

# Clean ArgoCD
clean-argocd:
	@echo "\033[1;36m=== Checking cluster status... ===\033[0m"
	@if ! kubectl cluster-info > /dev/null 2>&1; then \
		echo "\033[1;33mWarning: Cannot connect to Kubernetes cluster. Cleanup skipped.\033[0m"; \
	else \
		echo "\033[1;32m✓ Cluster is running. Proceeding with cleanup...\033[0m"; \
		echo "\033[1;36m=== Cleaning up ArgoCD ===\033[0m"; \
		if kubectl get application -n argocd wil-playground-app > /dev/null 2>&1; then \
			echo "--> Deleting ArgoCD application 'wil-playground-app'..."; \
			kubectl delete application -n argocd wil-playground-app; \
		else \
			echo "--> ArgoCD application 'wil-playground-app' not found, skipping deletion."; \
		fi; \
		echo "--> Deleting ArgoCD core components..."; \
		kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --ignore-not-found=true; \
		echo "--> Deleting namespaces..."; \
		kubectl delete namespace argocd --ignore-not-found=true; \
		kubectl delete namespace dev --ignore-not-found=true; \
		echo "\033[1;32m✓ ArgoCD cleanup complete\033[0m"; \
	fi

# Clean commands
fclean:
	@echo "\033[1;31m Full cleanup \033[0m"
	@$(MAKE) uninstall-gitlab
	@$(MAKE) cluster-delete
	@echo "\033[1;32m✓ Full cleanup complete\033[0m"

