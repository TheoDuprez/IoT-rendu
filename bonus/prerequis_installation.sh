#!/bin/bash

set -e

# Install prerequisites: Docker, k3d, kubectl, Helm, GitLab Helm repo
echo -e "=== Installing Prerequisites ==="

if command -v docker >/dev/null 2>&1; then
    echo "Docker is already installed."
else
    echo "Docker is not installed. Installing..."
    curl -fsSL https://get.docker.com | sudo sh
fi


if command -v k3d >/dev/null 2>&1; then
    echo "k3d is already installed."
else
    echo "k3d is not installed. Installing..."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi


if command -v kubectl >/dev/null 2>&1; then
    echo "kubectl is already installed."
else
    echo "kubectl is not installed. Installing..."
    curl -LO https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
fi


if command -v helm >/dev/null 2>&1; then
    echo "Helm is already installed."
else
    echo "Helm is not installed. Installing..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi


if helm repo list 2>/dev/null | grep -q gitlab; then
    echo "GitLab Helm repository is already configured."
else
    echo "Adding GitLab Helm repository..."
    helm repo add gitlab https://charts.gitlab.io/
    helm repo update
fi


if command -v glab >/dev/null 2>&1; then
    echo "glab (GitLab CLI) is already installed."
else
    echo "glab (GitLab CLI) is not installed. Installing..."
    curl -sL https://gitlab.com/gitlab-org/cli/-/releases/latest/downloads/glab_Linux_x86_64.tar.gz | tar xz
    sudo mv glab /usr/local/bin/
fi

echo "All tools are installed or already present."
