
#!/bin/bash

# Vagrant installation script for Debian

# Requires root privileges
set -e

echo "=== Vagrant Installation for Debian ==="

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then 
    echo "Error: This script must be run as root (use sudo)"
    exit 1
fi

# Check if Vagrant is already installed
if command -v vagrant &> /dev/null; then
    echo "Vagrant is already installed:"
    vagrant --version
    exit 0
fi

# Update packages
echo "Updating package list..."
apt-get update

# Install dependencies
echo "Installing dependencies..."
apt-get install -y wget gnupg2 software-properties-common

# Download HashiCorp GPG key
echo "Adding HashiCorp GPG key..."
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository
echo "Adding HashiCorp repository..."
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

# Update and install Vagrant
echo "Installing Vagrant..."
apt-get update
apt-get install -y vagrant

# Verify installation
echo ""
echo "=== Installation completed ==="
vagrant --version

echo ""
echo "Vagrant has been successfully installed!"