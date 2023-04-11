#!/bin/bash

# Define the repository URL and directory where the files will be downloaded
REPO_URL="https://github.com/mestadler/homecfg.git"
DOWNLOAD_DIR="$HOME/dotfiles"

# Create the directory if it doesn't exist
mkdir -p $DOWNLOAD_DIR

# Clone the repository into the download directory
git clone $REPO_URL $DOWNLOAD_DIR

# Copy the .bashrc, .vimrc, and .gitconfig files to your home directory
function backup_and_copy {
    if [[ -e "$HOME/$1" ]]; then
        echo "Backing up existing $1 file to $1.old"
        mv "$HOME/$1" "$HOME/$1.old"
    fi
    cp "$DOWNLOAD_DIR/$1" "$HOME/$1"
}
backup_and_copy .bashrc
backup_and_copy .vimrc
backup_and_copy .gitconfig

# Source the .bashrc file to apply the changes
source $HOME/.bashrc

# Remove the download directory
rm -rf $DOWNLOAD_DIR
