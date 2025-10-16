#!/bin/bash

set -e

echo "Mise à jour des paquets..."
sudo apt update && sudo apt upgrade -y

echo "Installation des dépendances nécessaires..."
sudo apt install -y curl gnupg software-properties-common

# Récupération de la dernière version de Vagrant (adapté pour Debian 12 / Trixie)
VAGRANT_VERSION="latest"

echo "Téléchargement de Vagrant..."
# On peut prendre directement la dernière version stable depuis HashiCorp :
# On peut aussi spécifier une version fixe si besoin, ici on récupère la dernière stable en dur.
# Par défaut, on télécharge la version 2.3.7 par exemple (à adapter si besoin)

VAGRANT_DEB="vagrant_2.3.7_amd64.deb"
DOWNLOAD_URL="https://releases.hashicorp.com/vagrant/2.3.7/${VAGRANT_DEB}"

curl -o /tmp/${VAGRANT_DEB} ${DOWNLOAD_URL}

echo "Installation de Vagrant..."
sudo dpkg -i /tmp/${VAGRANT_DEB} || sudo apt-get install -f -y

echo "Nettoyage..."
rm /tmp/${VAGRANT_DEB}

echo "Vagrant version installée :"
vagrant --version

echo "Installation terminée avec succès."
