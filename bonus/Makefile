all:
	./scripts/install.sh
	./scripts/init_application.sh

upgrade_application:
	./scripts/upgrade_application.sh

downgrade_application:
	./scripts/downgrade_application.sh

get_argocd_password:
	argocd admin initial-password -n argocd | head -n 1

get_gitlab_password:
	kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -ojsonpath='{.data.password}' | base64 --decode

clean:
	sudo apt remove helm -y
	sudo apt remove glab -y
	k3d cluster delete k3s-cluster
	sudo rm -rf /usr/local/bin/k3d
	sudo rm -rf playground_application/.git

.PHONY: all clean