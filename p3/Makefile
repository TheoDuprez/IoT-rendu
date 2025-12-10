all:
	./scripts/install.sh

upgrade_application:
	./scripts/upgrade_application.sh

downgrade_application:
	./scripts/downgrade_application.sh

clean:
	k3d cluster delete k3s-cluster
	sudo rm -rf /usr/local/bin/k3d
	rm -rf playground_application

.PHONY: all clean fclean re