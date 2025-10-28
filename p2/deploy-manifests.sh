

#!/bin/bash
# deploy-manifests.sh
set -e

echo "=== Attente du démarrage de K3s ==="
sleep 10

echo "=== Déploiement des applications ==="

# Déploiement de app1
echo "Déploiement de app1..."
sudo kubectl apply -f /vagrant/manifests/app1.yaml

# Déploiement de app2 (avec 3 replicas)
echo "Déploiement de app2..."
sudo kubectl apply -f /vagrant/manifests/app2.yaml

# Déploiement de app3
echo "Déploiement de app3..."
sudo kubectl apply -f /vagrant/manifests/app3.yaml

# Attente que les pods soient prêts
echo "Attente que les pods soient prêts..."
sleep 5

# Déploiement de l'Ingress
echo "Déploiement de l'Ingress..."
sudo kubectl apply -f /vagrant/manifests/ingress.yaml

echo "=== Déploiement terminé ==="
echo ""
echo "Vérification des ressources :"
sudo kubectl get pods
echo ""
sudo kubectl get services
echo ""
sudo kubectl get ingress