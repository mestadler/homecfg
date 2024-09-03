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

# ... (rest of the script remains the same)

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
