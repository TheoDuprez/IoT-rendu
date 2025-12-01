#!/bin/bash

# Create namespaces
k3d cluster create mycluster

k3d cluster start mycluster

#k3d kubeconfig merge mycluster --kubeconfig-switch-context

# Vérifier que kubectl pointe vers le bon cluster
#kubectl cluster-info
#kubectl config current-context