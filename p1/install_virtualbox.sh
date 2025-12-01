#!/bin/bash

# Script d'installation de VirtualBox sur Debian Trixie
# À exécuter avec sudo ou en tant que root

set -e

echo "=== Installation de VirtualBox sur Debian Trixie ==="
echo ""

# Vérification des privilèges root
if [ "$EUID" -ne 0 ]; then 
    echo "Erreur: Ce script doit être exécuté avec sudo ou en tant que root"
    exit 1
fi

# Nettoyage des anciennes configurations
echo "Nettoyage des anciennes configurations..."
rm -f /etc/apt/sources.list.d/virtualbox.list*
rm -f /usr/share/keyrings/oracle-virtualbox*.gpg

# Mise à jour de la liste des paquets
echo ""
echo "Étape 1: Mise à jour du système..."
apt update

# Installation des dépendances nécessaires
echo ""
echo "Étape 2: Installation des dépendances..."
apt install -y wget gnupg2 apt-transport-https ca-certificates curl lsb-release

# Installation des headers du kernel (nécessaires pour compiler les modules)
echo ""
echo "Étape 3: Installation des headers du kernel et dkms..."
apt install -y linux-headers-$(uname -r) dkms build-essential

# Méthode 1: Essayer avec le dépôt Sid (unstable)
echo ""
echo "Étape 4: Tentative d'installation depuis les dépôts Debian Sid..."

# Ajout temporaire du dépôt Sid avec basse priorité
cat > /etc/apt/sources.list.d/sid.list << EOF
deb http://deb.debian.org/debian sid main contrib non-free
EOF

# Configuration des priorités pour n'utiliser Sid qu'en dernier recours
cat > /etc/apt/preferences.d/sid << EOF
Package: *
Pin: release a=unstable
Pin-Priority: 100
EOF

apt update

# Tentative d'installation depuis Sid
if apt install -y -t unstable virtualbox virtualbox-dkms 2>/dev/null; then
    echo ""
    echo "✓ VirtualBox installé depuis les dépôts Debian Sid"
    INSTALL_METHOD="sid"
else
    echo ""
    echo "Installation depuis Sid impossible, tentative avec le dépôt Oracle..."
    
    # Nettoyage du dépôt Sid
    rm -f /etc/apt/sources.list.d/sid.list
    rm -f /etc/apt/preferences.d/sid
    apt update
    
    # Méthode 2: Dépôt Oracle avec correction pour Trixie
    echo ""
    echo "Étape 5: Configuration du dépôt Oracle VirtualBox..."
    
    # Téléchargement manuel et vérification des clés
    wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O /tmp/oracle_vbox_2016.asc
    wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O /tmp/oracle_vbox.asc
    
    # Conversion et installation des clés
    gpg --dearmor < /tmp/oracle_vbox_2016.asc > /usr/share/keyrings/oracle-virtualbox-2016.gpg
    gpg --dearmor < /tmp/oracle_vbox.asc > /usr/share/keyrings/oracle-virtualbox.gpg
    
    rm /tmp/oracle_vbox*.asc
    
    # Ajout du dépôt (utilise bookworm car trixie n'est pas encore supporté)
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox.gpg] https://download.virtualbox.org/virtualbox/debian bookworm contrib" > /etc/apt/sources.list.d/virtualbox.list
    
    # Mise à jour et installation
    apt update
    apt install -y virtualbox-7.0
    
    INSTALL_METHOD="oracle"
fi

# Ajout de l'utilisateur au groupe vboxusers
echo ""
echo "Configuration des permissions..."
CURRENT_USER=${SUDO_USER:-$USER}
if [ "$CURRENT_USER" != "root" ]; then
    usermod -aG vboxusers $CURRENT_USER
    echo "L'utilisateur $CURRENT_USER a été ajouté au groupe vboxusers"
fi

# Installation du pack d'extension (optionnel)
echo ""
read -p "Voulez-vous installer le VirtualBox Extension Pack ? (o/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[OoYy]$ ]]; then
    echo "Installation du Extension Pack..."
    VBOX_VERSION=$(vboxmanage --version | cut -dr -f1)
    wget -q "https://download.virtualbox.org/virtualbox/${VBOX_VERSION}/Oracle_VM_VirtualBox_Extension_Pack-${VBOX_VERSION}.vbox-extpack"
    echo "y" | vboxmanage extpack install --replace "Oracle_VM_VirtualBox_Extension_Pack-${VBOX_VERSION}.vbox-extpack" 2>/dev/null || true
    rm -f "Oracle_VM_VirtualBox_Extension_Pack-${VBOX_VERSION}.vbox-extpack"
fi

# Chargement du module kernel
echo ""
echo "Chargement des modules kernel..."
if modprobe vboxdrv 2>/dev/null; then
    echo "✓ Module vboxdrv chargé avec succès"
else
    echo "⚠ Module vboxdrv non chargé - un redémarrage sera nécessaire"
fi

echo ""
echo "=== Installation terminée avec succès ! ==="
echo ""
echo "Méthode d'installation: $INSTALL_METHOD"
echo ""
echo "IMPORTANT: Vous devez:"
echo "1. REDÉMARRER votre session (ou votre ordinateur)"
echo "2. Ensuite lancer VirtualBox avec: virtualbox"
echo ""
echo "Version installée:"
vboxmanage --version || echo "Exécutez 'vboxmanage --version' après redémarrage"