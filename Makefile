#PATHS
SCRIPTS_DIR = prerequis_installation

#Install VirtualBox
VB_INSTALLATION = install_virtualbox.sh 


install_vb:
	@echo "Exécution du script ${SCRIPTS_DIR}/${VB_INSTALLATION}..."
	@bash ${SCRIPTS_DIR}/${VB_INSTALLATION}
	@echo "VirtualBox installé ✅"

#Install Vagrant
VAGRANT_INSTALLATION = install_vagrant.sh 

install_vagrant:
	@echo "Exécution du script ${SCRIPTS_DIR}/${VAGRANT_INSTALLATION}..."
	@bash ${SCRIPTS_DIR}/${VAGRANT_INSTALLATION}
	@echo "Vagrant installé ✅"



# Clean vagrant dir
VAGRANT_DIR = .vagrant

clean_vagrant_dir:
	@if [ -d "${VAGRANT_DIR}" ]; then \
		echo "Le dossier '${VAGRANT_DIR}' existe. Suppression en cours..."; \
		rm -rf "${VAGRANT_DIR}"; \
		echo "Dossier supprimé avec succès."; \
	else \
		echo "Le dossier '${VAGRANT_DIR}' n'existe pas. Rien à faire."; \
	fi
