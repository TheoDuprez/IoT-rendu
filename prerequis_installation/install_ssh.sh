#!/bin/bash
#A copier dans la VM debian 

#Install ssh
sudo apt update
sudo apt install openssh-server

# Active le système ssh au démarrage 
sudo systemctl enable ssh

#Verifie l'installation de ssh
echo "$(systemctl status sshd)"
