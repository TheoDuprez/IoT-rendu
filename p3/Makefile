# Part 3 : K3d and Argo CD

.PHONY: help install-tools create-cluster delete-cluster namespaces install-argocd docker k3d kubectl cluster namespaces \
        argocd app image test-app version-status password clean fclean all

.DEFAULT_GOAL := help

CLUSTER_NAME ?= mycluster
GITHUB_REPO ?= https://github.com/lciullo/lciullo-iot.git
APP_NAMESPACE ?= dev
ARGOCD_NAMESPACE ?= argocd
APP_PORT ?= 8080


help:
	@echo "\033[1;36m=== Inception of Things - Part 3 ===\033[0m"
	@echo "\033[1;36m(K3d and Argo CD)\033[0m"
	@echo ""
	@echo "\033[1;33mInstallation commands:\033[0m"
	@echo "  \033[1;32mmake install-tools\033[0m     	- Install Docker, K3d, kubectl, and other required tools"
	@echo "  \033[1;32mmake config-cluster\033[0m     	- Config K3d cluster"
	@echo ""
	@echo "\033[1;33mVerification commands:\033[0m"
	@echo "  \033[1;32mmake docker\033[0m      			- Verify Docker installation"
	@echo "  \033[1;32mmake k3d\033[0m         			- Verify K3d installation"
	@echo "  \033[1;32mmake kubectl\033[0m     			- Verify kubectl installation"
	@echo "  \033[1;32mmake cluster\033[0m     			- Verify K3d cluster is running"
	@echo "  \033[1;32mmake namespaces\033[0m  			- Verify namespaces exist"
	@echo "  \033[1;32mmake argocd\033[0m     			- Verify Argo CD deployment"
	@echo "  \033[1;32mmake app\033[0m         			- Verify application deployment"
	@echo "  \033[1;32mmake image\033[0m       			- Show deployed application image version"
	@echo ""
	@echo "\033[1;33mTesting commands:\033[0m"
	@echo "  \033[1;32mmake test-app\033[0m           	- Test application endpoint"
	@echo "  \033[1;32mmake password\033[0m           	- Show Argo CD initial admin password"
	@echo "  \033[1;32mmake version-status\033[0m     	- Show current application version"
	@echo ""
	@echo "\033[1;33mCleanup commands:\033[0m"
	@echo "  \033[1;32mmake clean\033[0m              	- Delete K3d cluster and kubeconfig"
	@echo "  \033[1;32mmake fclean\033[0m             	- Full cleanup (cluster + all Docker containers)"
	@echo ""
	@echo "\033[1;33mFull workflow:\033[0m"
	@echo "  \033[1;32mmake all\033[0m                	- Run complete setup (install → verify)"
	@echo ""

# ============================================================================
# INSTALLATION COMMANDS
# ============================================================================


config-cluster:
	@echo "\033[1;36m=== Config K3d Cluster ===\033[0m"
	@./config_cluster.sh
	@echo "\033[1;32m✓ Cluster created successfully!\033[0m"

# ============================================================================
# VERIFICATION COMMANDS
# ============================================================================

docker:
	@echo "\033[1;36m=== Docker Verification ===\033[0m"
	@docker --version
	@echo "\033[1;32m✓ Docker is installed\033[0m"
	@echo ""
	@echo "\033[1;36m=== Docker Daemon Status ===\033[0m"
	@docker ps > /dev/null 2>&1 && echo "\033[1;32m✓ Docker daemon is running\033[0m" || echo "\033[1;31m✗ Docker daemon is not running\033[0m"

k3d:
	@echo "\033[1;36m=== K3d Verification ===\033[0m"
	@k3d version
	@echo "\033[1;32m✓ K3d is installed\033[0m"

kubectl:
	@echo "\033[1;36m=== kubectl Verification ===\033[0m"
	@kubectl version --client 2>/dev/null
	@echo "\033[1;32m✓ kubectl is installed\033[0m"

cluster:
	@echo "\033[1;36m=== K3d Cluster Status ===\033[0m"
	@k3d cluster list
	@echo ""
	@echo "\033[1;36m=== Kubernetes Cluster Info ===\033[0m"
	@kubectl cluster-info 2>/dev/null || echo "\033[1;31m✗ No cluster connected\033[0m"
	@echo ""
	@echo "\033[1;36m=== Kubernetes Nodes ===\033[0m"
	@kubectl get nodes -o wide 2>/dev/null || echo "\033[1;31m✗ Failed to get nodes\033[0m"
	@echo "\033[1;32m✓ Expected: 1 node in Ready state\033[0m"

namespaces:
	@echo "\033[1;36m=== Kubernetes Namespaces ===\033[0m"
	@kubectl get namespaces
	@echo ""
	@if kubectl get namespace $(ARGOCD_NAMESPACE) > /dev/null 2>&1; then \
		echo "\033[1;32m✓ Namespace '$(ARGOCD_NAMESPACE)' exists\033[0m"; \
	else \
		echo "\033[1;31m✗ Namespace '$(ARGOCD_NAMESPACE)' not found\033[0m"; \
	fi
	@if kubectl get namespace $(APP_NAMESPACE) > /dev/null 2>&1; then \
		echo "\033[1;32m✓ Namespace '$(APP_NAMESPACE)' exists\033[0m"; \
	else \
		echo "\033[1;31m✗ Namespace '$(APP_NAMESPACE)' not found\033[0m"; \
	fi

argocd:
	@echo "\033[1;36m=== Argo CD Deployment Status ===\033[0m"
	@kubectl get pods -n $(ARGOCD_NAMESPACE) 2>/dev/null || echo "\033[1;31m✗ Argo CD not installed\033[0m"
	@echo ""
	@echo "\033[1;36m=== Argo CD Service ===\033[0m"
	@kubectl get service argocd-server -n $(ARGOCD_NAMESPACE) 2>/dev/null || echo "\033[1;31m✗ Argo CD server service not found\033[0m"
	@echo ""
	@echo "\033[1;32m✓ Expected: argocd-server, argocd-repo-server, argocd-application-controller pods in Running state\033[0m"

password:
	@echo "\033[1;36m=== Argo CD Initial Admin Password ===\033[0m"
	@kubectl -n $(ARGOCD_NAMESPACE) get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
	@echo "\033[1;33mUse this password to log into the Argo CD UI (username: admin)\033[0m"

app:
	@echo "\033[1;36m=== Application Deployment Status ===\033[0m"
	@kubectl get deployments -n $(APP_NAMESPACE) 2>/dev/null || echo "\033[1;33m[*] No deployments yet (waiting for Argo CD sync)\033[0m"
	@echo ""
	@echo "\033[1;36m=== Application Pods ===\033[0m"
	@kubectl get pods -n $(APP_NAMESPACE) -o wide 2>/dev/null || echo "\033[1;33m[*] No pods yet\033[0m"
	@echo ""
	@echo "\033[1;36m=== Application Services ===\033[0m"
	@kubectl get services -n $(APP_NAMESPACE) 2>/dev/null || echo "\033[1;33m[*] No services yet\033[0m"

image:
	@echo "\033[1;36m=== Deployed Application Image ===\033[0m"
	@if kubectl get deployment -n $(APP_NAMESPACE) > /dev/null 2>&1; then \
		echo "\033[1;33mImage:\033[0m"; \
		kubectl get deployment -n $(APP_NAMESPACE) -o jsonpath='{.items[0].spec.template.spec.containers[0].image}' 2>/dev/null; \
		echo ""; \
		echo ""; \
		echo "\033[1;32m✓ Version successfully retrieved\033[0m"; \
	else \
		echo "\033[1;33m[*] No application deployed yet\033[0m"; \
	fi

test-app:
	@echo "\033[1;36m=== Testing Application Endpoint ===\033[0m"
	@echo "\033[1;33mAttempting to connect to http://localhost:$(APP_PORT)/\033[0m"
	@echo ""
	@if timeout 5 curl -s http://localhost:$(APP_PORT)/ > /dev/null 2>&1; then \
		echo "\033[1;36m=== Application Response ===\033[0m"; \
		curl -s http://localhost:$(APP_PORT)/ | jq . 2>/dev/null || curl -s http://localhost:$(APP_PORT)/; \
		echo ""; \
		echo "\033[1;32m✓ Application is responding\033[0m"; \
	else \
		echo "\033[1;31m✗ Application not responding on port $(APP_PORT)\033[0m"; \
		echo "  If using wil42/playground, ensure it's deployed and running"; \
		echo "  You may need to port-forward: kubectl port-forward svc/wil-playground-service 8888:80 -n $(APP_NAMESPACE)"; \
	fi



# ============================================================================
# CLEANUP COMMANDS
# ============================================================================

delete-cluster:
	@echo "\033[1;36m=== Deleting K3d Cluster ===\033[0m"
	@if k3d cluster list | grep -q $(CLUSTER_NAME); then \
		echo "\033[1;33m[*] Deleting cluster: $(CLUSTER_NAME)\033[0m"; \
		k3d cluster delete $(CLUSTER_NAME); \
		echo "\033[1;32m✓ Cluster deleted\033[0m"; \
	else \
		echo "\033[1;33m⚠ Cluster $(CLUSTER_NAME) not found\033[0m"; \
	fi

clean: delete-cluster
	@echo "\033[1;36m=== Cleaning up kubeconfig ===\033[0m"
	@if [ -d ~/.k3d ]; then rm -rf ~/.k3d; fi
	@echo "\033[1;32m✓ Cleanup completed\033[0m"

fclean: clean
	@echo "\033[1;36m=== Full Cleanup (Docker Containers) ===\033[0m"
	@echo "\033[1;33m[*] Stopping and removing all Docker containers...\033[0m"
	@docker ps -a | grep k3d | awk '{print $$1}' | xargs -r docker rm -f 2>/dev/null || true
	@echo "\033[1;32m✓ Full cleanup completed\033[0m"


