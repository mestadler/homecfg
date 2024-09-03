#!/bin/bash

set -e

SCRIPT_VERSION="1.3"
LAST_UPDATED="2024-09-04"

# Function to display usage information
usage() {
    echo "Usage: $0 <path_to_env_file>"
    echo "  <path_to_env_file>: Path to the local environment variables file"
    exit 1
}

# Check if env file path is provided
if [ "$#" -ne 1 ]; then
    usage
fi

ENV_FILE="$1"

# Check if env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: Environment file $ENV_FILE does not exist."
    exit 1
fi

# Source the environment file
source "$ENV_FILE"

# Function to run commands as root
run_as_root() {
    sudo -E "$@" || { echo "Command failed: $*"; exit 1; }
}

# Logging setup
LOG_FILE="/var/log/devbox_setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starting devbox-init.sh version $SCRIPT_VERSION (Last updated: $LAST_UPDATED)"
echo "Setup started at $(date)"

# Ensure the script is not run directly as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Please do not run this script directly as root."
    echo "Run it as your regular user. The script will use sudo when necessary."
    exit 1
fi

# Locale and timezone configuration
echo "Configuring locale and timezone..."
run_as_root locale-gen "$LANG"
run_as_root update-locale LANG="$LANG"
run_as_root timedatectl set-timezone "$TZ"

# Network configuration
echo "Configuring network settings..."
run_as_root hostnamectl set-hostname ""
run_as_root sed -i '/127.0.1.1/d' /etc/hosts
echo "127.0.0.1 localhost" | run_as_root tee -a /etc/hosts
echo "::1 localhost ip6-localhost ip6-loopback" | run_as_root tee -a /etc/hosts

# Package installation
echo "Updating package lists..."
run_as_root apt update

echo "Installing packages..."
run_as_root apt install -y $PACKAGES

# Full system upgrade
echo "Performing full system upgrade..."
run_as_root apt dist-upgrade -y

# Automatic security updates configuration
echo "Configuring automatic security updates..."
run_as_root apt install -y unattended-upgrades
run_as_root dpkg-reconfigure --priority=low unattended-upgrades

# Kubernetes installation
echo "Setting up Kubernetes..."
run_as_root curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | run_as_root apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | run_as_root tee /etc/apt/sources.list.d/kubernetes.list
run_as_root apt update
run_as_root apt install -y kubelet="$KUBERNETES_VERSION" kubeadm="$KUBERNETES_VERSION" kubectl="$KUBERNETES_VERSION"
run_as_root apt-mark hold kubelet kubeadm kubectl

# Clone and execute user configuration deployment script
echo "Cloning configuration repository and running the deployment script..."
git clone "$REPO_URL" ~/homecfg
cd ~/homecfg
bash user-config-deploy.sh "$ENV_FILE"

# Source the user's .bashrc file
echo "Sourcing .bashrc to apply changes..."
source ~/.bashrc

echo "System setup complete. Please reboot your system."
echo "Setup finished at $(date)"
