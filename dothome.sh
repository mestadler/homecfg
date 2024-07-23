#!/bin/bash

# Define the repository URL and directory where the files will be downloaded
REPO_URL="https://github.com/mestadler/homecfg.git"
DOWNLOAD_DIR="$HOME/dotfiles"
LOG_FILE="$HOME/homecfg_update.log"
DRY_RUN=false

# Function to print and log messages
log() {
    echo "$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check for required commands
for cmd in git mv cp; do
    if ! command_exists "$cmd"; then
        log "Error: $cmd is not installed."
        exit 1
    fi
done

# Function to backup and copy files
backup_and_copy() {
    local file="$1"
    if [[ -e "$HOME/$file" ]]; then
        log "Backing up existing $file to $file.old"
        $DRY_RUN || mv "$HOME/$file" "$HOME/$file.old"
    fi
    log "Copying $file to $HOME"
    $DRY_RUN || cp "$DOWNLOAD_DIR/$file" "$HOME/$file"
}

# Function to backup and copy files to specific directories
backup_and_copy_to_dir() {
    local source_file="$1"
    local target_dir="$2"
    local target_file="$target_dir/$(basename $source_file)"
    mkdir -p $target_dir
    if [[ -e "$target_file" ]]; then
        log "Backing up existing $(basename $source_file) to $(basename $source_file).old"
        $DRY_RUN || mv "$target_file" "$target_file.old"
    fi
    log "Copying $source_file to $target_dir"
    $DRY_RUN || cp "$DOWNLOAD_DIR/$source_file" "$target_file"
}

# Check for dry-run option
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    log "Dry run mode enabled. No changes will be made."
fi

# Create the directory if it doesn't exist
log "Creating download directory $DOWNLOAD_DIR"
$DRY_RUN || mkdir -p $DOWNLOAD_DIR

# Clone the repository into the download directory
log "Cloning repository from $REPO_URL"
if $DRY_RUN; then
    log "[Dry run] git clone $REPO_URL $DOWNLOAD_DIR"
else
    git clone $REPO_URL $DOWNLOAD_DIR || { log "Error: Failed to clone repository."; exit 1; }
fi

# List of files to backup and copy
files=(
    .bashrc
    .bashrc-developer
    .gitconfig
    .vimrc
    .sgptrc
)

# Loop through the list of files and apply the backup and copy function
for file in "${files[@]}"; do
    backup_and_copy "$file"
done

# Backup and copy init.nvim to the correct location
backup_and_copy_to_dir "init.nvim" "$HOME/.config/nvim"

# Backup and copy kitty.conf to the correct location
backup_and_copy_to_dir "kitty.conf" "$HOME/.config/kitty"

# Backup and copy .sgptrc to the correct location
backup_and_copy_to_dir ".sgptrc" "$HOME/.config/shell_gpt"

# Source the .bashrc file to apply the changes if it exists
if [[ -e "$HOME/.bashrc" ]]; then
    log "Sourcing $HOME/.bashrc"
    $DRY_RUN || source $HOME/.bashrc
fi

# Remove the download directory
log "Removing download directory $DOWNLOAD_DIR"
$DRY_RUN || rm -rf $DOWNLOAD_DIR

log "Script completed successfully."

