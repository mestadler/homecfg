#!/bin/bash

set -e

SCRIPT_VERSION="1.4"
LAST_UPDATED="2024-09-04"

# Function to display usage information
usage() {
    echo "Usage: $0 <path_to_env_file> [--dry-run]"
    echo "  <path_to_env_file>: Path to the local environment variables file"
    echo "  --dry-run: Optional flag to run the script without making changes"
    exit 1
}

# Check if env file path is provided
if [ "$#" -lt 1 ]; then
    usage
fi

ENV_FILE="$1"
shift

# Check if env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: Environment file $ENV_FILE does not exist."
    exit 1
fi

# Source the environment file
source "$ENV_FILE"

DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "Dry run mode enabled. No changes will be made."
fi

# Logging setup
LOG_FILE="$HOME/user_config_deploy.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starting user-config-deploy.sh version $SCRIPT_VERSION (Last updated: $LAST_UPDATED)"
echo "Deployment started at $(date)"

# Function to backup and copy files
backup_and_copy() {
    local file="$1"
    if [[ -e "$HOME/$file" ]]; then
        echo "Backing up existing $file to $file.old"
        $DRY_RUN || mv "$HOME/$file" "$HOME/$file.old"
    fi
    echo "Copying $file to $HOME"
    $DRY_RUN || cp "$file" "$HOME/$file"
}

# Function to backup and copy files to specific directories
backup_and_copy_to_dir() {
    local source_file="$1"
    local target_file="$2"
    local target_dir=$(dirname "$target_file")
    $DRY_RUN || mkdir -p "$target_dir"
    if [[ -e "$target_file" ]]; then
        echo "Backing up existing $(basename "$target_file") to $(basename "$target_file").old"
        $DRY_RUN || mv "$target_file" "$target_file.old"
    fi
    echo "Copying $source_file to $target_file"
    $DRY_RUN || cp "$source_file" "$target_file"
}

# Clone the repository
echo "Cloning configuration repository from $REPO_URL"
$DRY_RUN || git clone "$REPO_URL" "$HOME/config_temp"
cd "$HOME/config_temp"

# Deploy dotfiles
echo "Deploying dotfiles..."
IFS=' ' read -ra DOTFILE_ARRAY <<< "$DOTFILES"
for file in "${DOTFILE_ARRAY[@]}"; do
    backup_and_copy "$file"
done

# Handle special configuration files
echo "Deploying special configuration files..."
IFS=' ' read -ra SPECIAL_CONFIG_ARRAY <<< "$SPECIAL_CONFIGS"
for config in "${SPECIAL_CONFIG_ARRAY[@]}"; do
    IFS=':' read -ra CONFIG_PARTS <<< "$config"
    source_file="${CONFIG_PARTS[0]}"
    target_file="${CONFIG_PARTS[1]}"
    backup_and_copy_to_dir "$source_file" "$target_file"
done

# Source the .bashrc file to apply changes
if [[ -e "$HOME/.bashrc" ]]; then
    echo "Sourcing $HOME/.bashrc to apply changes"
    $DRY_RUN || source "$HOME/.bashrc"
fi

# Clean up
echo "Cleaning up temporary files"
$DRY_RUN || rm -rf "$HOME/config_temp"

echo "User configuration deployment complete."
echo "Deployment finished at $(date)"
