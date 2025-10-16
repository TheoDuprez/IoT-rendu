#!/bin/bash

#A copier dans la VM debian 
# Vérifier si l'utilisateur est bien spécifié
if [ -z "$1" ]; then
  echo "Usage: $0 nom_utilisateur"
  exit 1
fi

UTILISATEUR="$1"

# Vérifier si l'utilisateur existe
if id "$UTILISATEUR" &>/dev/null; then
  # Ajouter l'utilisateur au groupe sudo
  sudo usermod -aG sudo "$UTILISATEUR"

  if [ $? -eq 0 ]; then
    echo "L'utilisateur $UTILISATEUR a été ajouté au groupe sudo avec succès."
  else
    echo "Une erreur s'est produite lors de l'ajout de $UTILISATEUR au groupe sudo."
  fi
else
  echo "L'utilisateur $UTILISATEUR n'existe pas."
  exit 1
fi
