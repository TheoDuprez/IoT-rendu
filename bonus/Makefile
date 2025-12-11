all:
	./scripts/install.sh
	./scripts/init_application.sh

upgrade_application:
	./scripts/upgrade_application.sh

downgrade_application:
	./scripts/downgrade_application.sh

clean:
	sudo apt remove helm -y
	sudo apt remove glab -y
	k3d cluster delete k3s-cluster
	sudo rm -rf /usr/local/bin/k3d
	sudo rm -rf playground_application/.git

re: clean
	all

.PHONY: all clean fclean re