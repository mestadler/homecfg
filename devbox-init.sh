#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Ensure the script is not run directly as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Please do not run this script directly as root."
    echo "Run it as your regular user. The script will switch to root where necessary."
    exit 1
fi

# Prompt for user details if not already set
if [ -z "$GITHUB_USERNAME" ]; then
    read -p "Enter your GitHub username: " GITHUB_USERNAME
    export GITHUB_USERNAME
fi

if [ -z "$DEBFULLNAME" ]; then
    read -p "Enter your full name (e.g., John Doe): " DEBFULLNAME
    export DEBFULLNAME
fi

if [ -z "$DEBEMAIL" ]; then
    read -p "Enter your email address: " DEBEMAIL
    export DEBEMAIL
fi

# Function to run commands as root using su
run_as_root() {
    su -c "$1" || { echo "Command failed: $1"; exit 1; }
}

LOG_FILE="/var/log/setup_script.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starting setup at $(date)"

# Locale, Language, and Keyboard Configuration
echo "Configuring locale, language, and keyboard..."
run_as_root "locale-gen en_GB.UTF-8"
run_as_root "update-locale LANG=en_GB.UTF-8"
run_as_root "localectl set-locale LANG=en_GB.UTF-8"
run_as_root "localectl set-keymap gb"

# Network Configuration
echo "Configuring network settings..."
run_as_root "echo '' > /etc/hostname"
run_as_root "sed -i 's/#\(send host-name .*\)/\1/; s/#\(do-not-configure .*\)/\1/; s/#\(request subnet-mask, broadcast-address, time-offset, routers, domain-name, domain-name-servers, host-name\)/\1/' /etc/dhcp/dhclient.conf"
run_as_root "sed -i '/127.0.1.1/d' /etc/hosts"
run_as_root "echo '127.0.0.1 localhost' >> /etc/hosts"
run_as_root "echo '::1 localhost ip6-localhost ip6-loopback' >> /etc/hosts"

# Timezone and Clock Configuration
echo "Configuring timezone and clock..."
run_as_root "timedatectl set-timezone Europe/London"
run_as_root "timedatectl set-ntp true"
run_as_root "ntpdate 0.uk.pool.ntp.org"

# Software Installation
echo "Installing packages..."
run_as_root "apt update"
run_as_root "apt install -y \
    apt-transport-https \
    apt-utils \
    autofs \
    bashtop \
    bless \
    build-essential \
    ca-certificates \
    cargo \
    ccache \
    ctop \
    curl \
    debian-archive-keyring \
    debian-keyring \
    debsums \
    dh-cargo \
    dstat \
    duf \
    duff \
    duc \
    ethtool \
    fakeroot \
    fastfetch \
    fio \
    flex \
    firmware-linux \
    firmware-linux-free \
    firmware-linux-nonfree \
    fzf \
    fwupd \
    fwupdmgr \
    gnupg \
    gawk \
    gettext \
    git \
    hexcurse \
    htop \
    hwinfo \
    iperf3 \
    kernel-package \
    libaio \
    libblkid \
    libclang \
    libfuse3-dev \
    libkeyutils \
    liblz4 \
    libncurses-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libscrypt-dev \
    libsodium \
    libssl-dev \
    liburcu \
    libuuid \
    libzstd \
    lsb-release \
    markdownlint \
    nala \
    ncdu \
    neovim \
    netselect-apt \
    net-tools \
    nfs-common \
    nmap \
    openssh-server \
    pkg-config \
    postmark \
    python3 \
    python3-pyclipper \
    python3-pytest \
    r8168-dkms \
    rsync \
    rustc \
    smbios-utils \
    software-properties-common \
    speedtest-cli \
    sysstat \
    thefuck \
    tldr \
    tweak \
    unzip \
    valgrind \
    wget \
    whois \
    zlib1g \
    zlib1g-dev"

# Full System Upgrade
echo "Performing full system upgrade..."
run_as_root "apt dist-upgrade -y"

# Automatic Security Updates Configuration
echo "Configuring automatic security updates..."
run_as_root "apt install -y unattended-upgrades"
run_as_root "dpkg-reconfigure --priority=low unattended-upgrades"

# Kubernetes Installation
KUBERNETES_VERSION="1.26.0-00"
echo "Setting up Kubernetes..."
run_as_root "curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -"
run_as_root "echo 'deb https://apt.kubernetes.io/ kubernetes-xenial main' | tee /etc/apt/sources.list.d/kubernetes.list"
run_as_root "apt update"
run_as_root "apt install -y kubelet=$KUBERNETES_VERSION kubeadm=$KUBERNETES_VERSION kubectl=$KUBERNETES_VERSION"
run_as_root "apt-mark hold kubelet kubeadm kubectl"

# Clone and Execute Post-Installation Script from GitHub
echo "Cloning post-installation repository and running the setup script as $ORIGINAL_USER..."
su - "$ORIGINAL_USER" -c "git clone https://github.com/mestadler/homecfg.git ~/homecfg && cd ~/homecfg && bash dothome.sh"

# Source the user's .bashrc file to apply any environment changes
echo "Sourcing .bashrc to apply changes..."
source ~/.bashrc

# Final Message
echo "***************************************************"
echo "* System setup complete. Please reboot your system *"
echo "***************************************************"
sleep 10
