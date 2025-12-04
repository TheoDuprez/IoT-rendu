#!/bin/bash

# Install docker
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
  
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo groupadd docker
sudo usermod -aG docker $USER

if ! getent group docker > /dev/null; then 
  newgrp docker 
fi

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# Install helm
sudo apt-get install curl gpg apt-transport-https --yes
curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

# Install k3d and setup k3s cluster
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
k3d cluster create k3s-cluster --k3s-arg "--disable=traefik@server:0"
k3d cluster start k3s-cluster

# Install glab (gitlab CLI)
cd /tmp
curl -L -O https://gitlab.com/gitlab-org/cli/-/releases/v1.78.3/downloads/glab_1.78.3_linux_amd64.deb
sudo apt-get install ./glab_1.78.3_linux_amd64.deb
rm glab_1.78.3_linux_amd64.deb
cd -

# Create namespaces
kubectl create namespace argocd
kubectl create namespace dev
kubectl create namespace gitlab

# Update hosts config
cat /etc/hosts | grep "172.18.0.2 gitlab.iot.com iot.com registry.iot.com minio.iot.com" > /dev/null

if [ $? -eq 1 ]; then
  sudo sh -c 'echo "172.18.0.2 gitlab.iot.com iot.com registry.iot.com minio.iot.com" >> /etc/hosts'
fi

# Create argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait -n argocd --for=condition=Available deployment --all --timeout=3m

# Install gitlab release
helm repo add gitlab http://charts.gitlab.io/
echo "\nInstalling gitlab...\n"
helm upgrade --install iot gitlab/gitlab -f confs/values.yaml -n gitlab

while true; do
    if [ $(curl -m 0.5 -s -o /dev/null -w "%{http_code}" -k https://gitlab.iot.com/users/sign_in) -eq "200" ]; then
        break
    fi
    sleep 1
done

echo "Gitlab successfully installed!"