# Getting Started

This repository contains scripts and configuration files for automating the setup of a development environment. The main script, devbox-init.sh, installs necessary packages, configures system settings, and sets up Kubernetes components. It also includes a script for applying user-specific configurations and a template for environment variables. The repo aims to streamline the process of preparing a system for development work.

The primary script, `devbox-init.sh`, automates the initial setup, while the other configuration files help customise the environment.
It will change your system.

## Repository Contents

- **`devbox-init.sh`**: 
  - Script applies the system packages and configuration for basic development.
  - **Functionality**:
    - Installs required packages and updates the system.
    - Configures locale, timezone, networking, and other system settings.
    - Sets up Kubernetes components (kubeadm, kubelet, kubectl).
    - Applies environment-specific settings using `env_variables.txt`.
  
- **`dothome.sh`**: 
  - Script applies user-specific configurations after the initial system setup.
  - **Functionality**:
    - Clones your dotfiles repository and applies custom configurations.
    - Configures user environment settings, aliases, and functions.
    - Can be customized to apply any personal tweaks or additional software installations.

- **`env_variables_template.txt`**:
  - A template for environment variables required by the scripts and configurations.
  - **Functionality**:
    - Provides placeholders for essential environment variables like API keys, paths, and configurations.
    - Users should copy this template, customize it with their details, and pass it to the setup scripts.

## Very Quick Start

- **Create env_variables.txt**: grab the env_variables_template.txt in this repo and modify it.
- **Run the script**: review it devbox-init.sh
  
  ```bash
   curl -fsSL https://raw.githubusercontent.com/mestadler/homecfg/main/devbox-init.sh | bash -s ~/env_variables.txt
  ```

## Full Quick Start

To quickly set up your development environment using the `devbox-init.sh` script, follow these steps:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/mestadler/homecfg.git
   cd homecfg
   ```

2. **Prepare and Customize Your Environment Variables**:
   - Copy the template environment variables file and rename it:
   
     ```bash
     cp env_variables_template.txt env_variables.txt
     ```
   - Edit the `env_variables.txt` (e.g., GitHub token, API keys, paths):
     
     ```bash
     vim env_variables.txt
     ```
     
   - Ensure that the `DEFAULT_MODEL` and `OPENAI_API_KEY` variables are set if you are using shell_gpt.

3. **Run the Initialization Script**:
   Execute the `devbox-init.sh` script, passing the `env_variables.txt` file as an argument:
   
   ```bash
   bash devbox-init.sh /path/to/env_variables.txt
   ```

5. **Apply Environment Changes**:
   If prompted, source the `.bashrc` file to apply the environment changes immediately:
   
   ```bash
   source ~/.bashrc
   ```

7. **Reboot Reminder**:
   ```bash
   sudo reboot
   ```

## License
This repository is licensed under the MIT License. See the LICENSE file for more information.
