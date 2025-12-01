
#!/bin/bash

# Script d'installation de Vagrant sous Debian
# Nécessite les privilèges root

set -e

echo "=== Installation de Vagrant sous Debian ==="

# Vérifier si le script est exécuté en root
if [ "$EUID" -ne 0 ]; then 
    echo "Erreur: Ce script doit être exécuté en tant que root (utilisez sudo)"
    exit 1
fi

# Mise à jour des paquets
echo "Mise à jour de la liste des paquets..."
apt-get update

# Installation des dépendances
echo "Installation des dépendances..."
apt-get install -y wget gnupg2 software-properties-common

# Téléchargement de la clé GPG HashiCorp
echo "Ajout de la clé GPG HashiCorp..."
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Ajout du dépôt HashiCorp
echo "Ajout du dépôt HashiCorp..."
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

# Mise à jour et installation de Vagrant
echo "Installation de Vagrant..."
apt-get update
apt-get install -y vagrant

# Vérification de l'installation
echo ""
echo "=== Installation terminée ==="
vagrant --version

echo ""
echo "Vagrant a été installé avec succès !"