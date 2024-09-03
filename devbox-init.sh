#!/bin/bash

# devbox-init.sh
# 
# Description:
#   This script initializes a dev box with necessary configurations,
#   packages, and user settings.
#
# Usage:
#   ./devbox-init.sh
#
# Note:
#   - This script should be run as a regular user with sudo privileges.
#   - The script expects a .env file in the same directory.
#
# /mes - https://github.com/mestadler/sans-devbox-bootstrap


#!/bin/bash

set -e

SCRIPT_VERSION="2.4"
LAST_UPDATED="2024-09-04"


# Ensure /usr/bin is in the PATH
export PATH="/usr/bin:$PATH"

ENV_FILE=".env"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: $ENV_FILE file does not exist in the current directory."
    exit 1
fi

# Function to read .env file
load_env() {
    set -a
    source "$ENV_FILE"
    set +a
}

# Load environment variables
load_env

echo "PATH after loading .env: $PATH"

export DEBIAN_FRONTEND=noninteractive

run_as_root() {
    sudo -E "$@" || { echo "Command failed: $*"; exit 1; }
}

# Test if common commands are accessible
for cmd in tee ls cat grep; do
    if command -v $cmd > /dev/null 2>&1; then
        echo "$cmd is available at $(which $cmd)"
    else
        echo "$cmd is not found in PATH"
    fi
done

LOG_FILE="./devbox_setup.log"
tee "$LOG_FILE" <<EOF
Starting devbox-init.sh version $SCRIPT_VERSION (Last updated: $LAST_UPDATED)
Setup started at $(date)
EOF

# root should not be used.
if [ "$(id -u)" -eq 0 ]; then
    echo "Please do not run this script directly as root."
    exit 1
fi

echo "Configuring locale and timezone..."
run_as_root locale-gen "$LANG"
run_as_root update-locale LANG="$LANG" LC_ALL="$LC_ALL"
run_as_root timedatectl set-timezone "$TZ"

echo "Configuring network settings..."
run_as_root hostnamectl set-hostname ""
run_as_root sed -i '/127.0.1.1/d' /etc/hosts
echo "127.0.0.1 localhost" | run_as_root tee -a /etc/hosts
echo "::1 localhost ip6-localhost ip6-loopback" | run_as_root tee -a /etc/hosts

echo "Updating package lists..."
run_as_root apt update

echo "Installing packages..."
# shellcheck disable=SC2086
run_as_root apt install -y $PACKAGES

echo "Performing full system upgrade..."
run_as_root apt dist-upgrade -y

echo "Configuring automatic security updates..."
run_as_root apt install -y unattended-upgrades
run_as_root dpkg-reconfigure -plow unattended-upgrades

echo "Setting up Starship globally"
curl -fsSL https://starship.rs/install.sh | run_as_root sh -s -- -y

echo "Setting up Kubernetes..."
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${KUBERNETES_VERSION}/deb/Release.key" | run_as_root gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBERNETES_VERSION}/deb/ /" | run_as_root tee /etc/apt/sources.list.d/kubernetes.list

run_as_root apt update
run_as_root apt install -y kubelet kubeadm kubectl
run_as_root apt-mark hold kubelet kubeadm kubectl
run_as_root systemctl enable --now kubelet

echo "Cloning configuration repository..."
git clone "$REPO_URL" ./homecfg || { echo "Failed to clone repository"; exit 1; }
cd ./homecfg || { echo "Failed to change directory to ./homecfg"; exit 1; }

echo "Running user-config-deploy.sh..."
if [ -f "user-config-deploy.sh" ]; then
    bash user-config-deploy.sh "../$ENV_FILE"
else
    echo "Error: user-config-deploy.sh not found in ./homecfg"
    exit 1
fi

cd ..

echo "Sourcing .bashrc..."
source ~/.bashrc

echo "System setup complete. Please reboot your system."
echo "Setup finished at $(date)"
