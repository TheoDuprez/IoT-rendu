#!/bin/bash

# Update package lists
sudo apt-get update

# Install Docker if necessary
echo "Checking for Docker installation..."
if ! command -v docker &> /dev/null
then
    echo "Docker is not installed. Installing Docker."
    sudo apt-get install -y docker.io
    sudo usermod -aG docker $USER
    if command -v docker &> /dev/null
    then
        echo "Docker installed successfully."
    else
        echo "Docker installation failed."
        exit 1
    fi
else
    echo "Docker is already installed."
fi

# Install K3d if necessary
echo "Checking for K3d installation..."
if ! command -v k3d &> /dev/null
then
    echo "K3d is not installed. Install in order to proceed."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=v5.0.0 bash
    if command -v k3d &> /dev/null
    then 
        echo "K3d installed successfully."
    else
        echo "K3d installation failed."
        exit 1
    fi
else 
    echo "K3d is already installed"
fi

# Install Kubectl if necessary
echo "Checking for Kubectl installation..."
if ! command -v kubectl &> /dev/null
then
    echo "Kubectl is not installed. Installing Kubectl."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl

    #&& argocd kubectl --client &> /dev/null
    if command -v kubectl &> /dev/null
    then
        echo "Kubectl installed successfully."
    else
        echo "Kubectl installation failed."
        exit 1
    fi
else
    echo "Kubectl is already installed."
fi

# Install Argo CD if necessary
echo "Checking for Argo CD installation..."
if ! command -v argocd &> /dev/null
then
    echo "Argo CD CLI is not installed. Installing now..."

    # Télécharger la dernière version stable (Linux AMD64)
    ARGOCD_VERSION=$(curl -s https://api.github.com/repos/argoproj/argo-cd/releases/latest | grep tag_name | cut -d '"' -f 4)
    curl -sSL -o argocd-linux-amd64 "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64"

    # Vérification de l'installation et du bon fonctionnement
    #&& argocd version --client &> /dev/null
    if command -v argocd &> /dev/null 
    then
        echo "Argo CD CLI installed and working successfully."
    else
        echo "Argo CD installation failed or not working properly."
        exit 1
    fi
else
    echo "Argo CD CLI is already installed."
fi

echo "Installation script completed."

