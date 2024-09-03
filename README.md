# DevBox Setup

DevBox Setup are a collection of scripts and configs, to setup a dev box after install of debian. It includes scripts for system configuration, package installation, and deployment of user-specific settings.
Sharing as it may be useful for others (and I need it to be a public repo).

## Version

- Current Version: 1.0
- Last Updated: 2024-09-04

## Repository Contents

- `devbox-init.sh`: Main script for system setup and package installation.
- `user-config-deploy.sh`: Script for deploying user-specific configurations and dotfiles.
- `env_variables_template.txt`: Template for environment variables used by both scripts.

## Prerequisites

- A Debian-based Linux distribution (e.g., Ubuntu)
- `sudo` access
- `git` installed

## Getting Started

1. Clone this repository:
   ```
   git clone https://github.com/mestadler/sans-devbox-bootstrap.git
   cd sans-devbox-bootstrap
   ```

2. Create your environment variables file:
   ```
   cp env_variables_template.txt env_variables.txt
   ```

3. Edit `env_variables.txt` with your specific details:
   ```
   vi env_variables.txt
   ```

4. Make the scripts executable:
   ```
   chmod +x devbox-init.sh user-config-deploy.sh
   ```

5. Run the main setup script:
   ```
   ./devbox-init.sh /path/to/your/env_variables.txt
   ```

## Script Details

### devbox-init.sh

This script performs the following tasks:

- Configures system locale and timezone
- Sets up network settings
- Installs specified packages
- Performs a full system upgrade
- Configures automatic security updates
- Sets up Kubernetes
- Calls `user-config-deploy.sh` to set up user-specific configurations

Usage:
```
./devbox-init.sh /path/to/your/env_variables.txt
```

### user-config-deploy.sh

This script handles user-specific configurations:

- Deploys specified dotfiles
- Handles special configuration files
- Provides a dry-run option for testing

Usage:
```
./user-config-deploy.sh /path/to/your/env_variables.txt [--dry-run]
```

## Environment Variables

The `env_variables.txt` file (created from `env_variables_template.txt`) contains all necessary configuration settings. Key sections include:

- System configuration (locale, timezone)
- User information (GitHub username, email)
- API keys and tokens
- Tool-specific configurations
- Path settings
- Package list for installation
- Dotfiles to be managed

Ensure all placeholder values in this file are replaced with your actual data before running the scripts.

## Customization

- Modify the `PACKAGES` variable in `env_variables.txt` to customize installed packages.
- Adjust the `DOTFILES` and `SPECIAL_CONFIGS` variables to manage your specific configuration files.

## Security Note

The `env_variables.txt` file may contain sensitive information. Keep it secure and do not share it publicly.

## Contributing

Contributions to improve DevBox Setup are welcome. Please feel free to submit pull requests or create issues for bugs and feature requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Devs that have shared their dot files, and config, thank you.
