#!/bin/bash

# VirtualBox installation script for Debian Trixie
# Must be run with sudo or as root

set -e

echo "=== VirtualBox Installation for Debian Trixie ==="
echo ""

# Check root privileges
if [ "$EUID" -ne 0 ]; then 
    echo "Error: This script must be run with sudo or as root"
    exit 1
fi

# Check if VirtualBox is already installed
if command -v vboxmanage &> /dev/null; then
    echo "VirtualBox is already installed:"
    vboxmanage --version
    exit 0
fi

# Clean old configurations
echo "Cleaning old configurations..."
rm -f /etc/apt/sources.list.d/virtualbox.list*
rm -f /usr/share/keyrings/oracle-virtualbox*.gpg

# Update package list
echo ""
echo "Step 1: Updating system..."
apt update

# Install required dependencies
echo ""
echo "Step 2: Installing dependencies..."
apt install -y wget gnupg2 apt-transport-https ca-certificates curl lsb-release

# Install kernel headers (required to compile modules)
echo ""
echo "Step 3: Installing kernel headers and dkms..."
apt install -y linux-headers-$(uname -r) dkms build-essential

# Method 1: Try with Sid repository (unstable)
echo ""
echo "Step 4: Attempting installation from Debian Sid repositories..."

# Temporarily add Sid repository with low priority
cat > /etc/apt/sources.list.d/sid.list << EOF
deb http://deb.debian.org/debian sid main contrib non-free
EOF

# Configure priorities to use Sid only as last resort
cat > /etc/apt/preferences.d/sid << EOF
Package: *
Pin: release a=unstable
Pin-Priority: 100
EOF

apt update

# Try installation from Sid
if apt install -y -t unstable virtualbox virtualbox-dkms 2>/dev/null; then
    echo ""
    echo "✓ VirtualBox installed from Debian Sid repositories"
    INSTALL_METHOD="sid"
else
    echo ""
    echo "Installation from Sid failed, trying Oracle repository..."
    
    # Clean Sid repository
    rm -f /etc/apt/sources.list.d/sid.list
    rm -f /etc/apt/preferences.d/sid
    apt update
    
    # Method 2: Oracle repository with Trixie correction
    echo ""
    echo "Step 5: Configuring Oracle VirtualBox repository..."
    
    # Manual download and key verification
    wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O /tmp/oracle_vbox_2016.asc
    wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O /tmp/oracle_vbox.asc
    
    # Convert and install keys
    gpg --dearmor < /tmp/oracle_vbox_2016.asc > /usr/share/keyrings/oracle-virtualbox-2016.gpg
    gpg --dearmor < /tmp/oracle_vbox.asc > /usr/share/keyrings/oracle-virtualbox.gpg
    
    rm /tmp/oracle_vbox*.asc
    
    # Add repository (uses bookworm as trixie is not yet supported)
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox.gpg] https://download.virtualbox.org/virtualbox/debian bookworm contrib" > /etc/apt/sources.list.d/virtualbox.list
    
    # Update and install
    apt update
    apt install -y virtualbox-7.0
    
    INSTALL_METHOD="oracle"
fi

# Add user to vboxusers group
echo ""
echo "Configuring permissions..."
CURRENT_USER=${SUDO_USER:-$USER}
if [ "$CURRENT_USER" != "root" ]; then
    usermod -aG vboxusers $CURRENT_USER
    echo "User $CURRENT_USER has been added to vboxusers group"
fi

# Install Extension Pack (optional)
echo ""
read -p "Do you want to install the VirtualBox Extension Pack? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[OoYy]$ ]]; then
    echo "Installing Extension Pack..."
    VBOX_VERSION=$(vboxmanage --version | cut -dr -f1)
    wget -q "https://download.virtualbox.org/virtualbox/${VBOX_VERSION}/Oracle_VM_VirtualBox_Extension_Pack-${VBOX_VERSION}.vbox-extpack"
    echo "y" | vboxmanage extpack install --replace "Oracle_VM_VirtualBox_Extension_Pack-${VBOX_VERSION}.vbox-extpack" 2>/dev/null || true
    rm -f "Oracle_VM_VirtualBox_Extension_Pack-${VBOX_VERSION}.vbox-extpack"
fi

# Load kernel module
echo ""
echo "Loading kernel modules..."
if modprobe vboxdrv 2>/dev/null; then
    echo "✓ vboxdrv module loaded successfully"
else
    echo "⚠ vboxdrv module not loaded - reboot will be required"
fi

echo ""
echo "=== Installation completed successfully! ==="
echo ""
echo "Installation method: $INSTALL_METHOD"
echo ""
echo "IMPORTANT: You must:"
echo "1. RESTART your session (or your computer)"
echo "2. Then launch VirtualBox with: virtualbox"
echo ""
echo "Installed version:"
vboxmanage --version || echo "Run 'vboxmanage --version' after reboot"