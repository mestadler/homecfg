# DevBox Setup

DevBox Setup is a collection of scripts and configs to set up a dev box after installing Debian. It includes scripts for system configuration, package installation, and deployment of user-specific settings. Shared as it may be useful for others (and I need it to be a public repo).

## Version

- Current Version: 1.1
- Last Updated: 2024-09-04

## Repository Contents

- `devbox-init.sh`: Main script for system setup and package installation.
- `user-config-deploy.sh`: Script for deploying user-specific configurations and dotfiles.
- `.env.example`: Template for environment variables used by both scripts.

## Prerequisites

- A Debian-based Linux distribution (e.g., Ubuntu)
- `sudo` access
- `git` installed
- `curl` installed (for remote execution)

## Getting Started

### Local Execution

1. Clone this repository:
   ```
   git clone https://github.com/mestadler/sans-devbox-bootstrap.git
   cd sans-devbox-bootstrap
   ```

2. Create your environment variables file:
   ```
   cp .env.example .env
   ```

3. Edit `.env` with your specific details:
   ```
   vi .env
   ```

4. Make the scripts executable:
   ```
   chmod +x devbox-init.sh user-config-deploy.sh
   ```

5. Run the main setup script:
   ```
   ./devbox-init.sh .env
   ```

### Remote Execution

To run the setup directly using curl:

```bash
curl -sS https://raw.githubusercontent.com/mestadler/sans-devbox-bootstrap/main/devbox-init.sh | bash -s -- .env
```

Note: Ensure you have your `.env` file prepared before running this command.

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
./devbox-init.sh .env
```

### user-config-deploy.sh

This script handles user-specific configurations:

- Deploys specified dotfiles
- Handles special configuration files
- Provides a dry-run option for testing

Usage:
```
./user-config-deploy.sh .env [--dry-run]
```

## Environment Variables

The `.env` file (created from `.env.example`) contains all necessary configuration settings. Key sections include:

- System configuration (locale, timezone)
- User information (GitHub username, email)
- API keys and tokens
- Tool-specific configurations
- Path settings
- Package list for installation
- Dotfiles to be managed

Ensure all placeholder values in this file are replaced with your actual data before running the scripts.

## Customization

- Modify the `PACKAGES` variable in `.env` to customize installed packages.
- Adjust the `DOTFILES` and `SPECIAL_CONFIGS` variables to manage your specific configuration files.

## Security Note

The `.env` file may contain sensitive information. Keep it secure and do not share it publicly. Ensure `.env` is added to your `.gitignore` file to prevent accidental commits.

## Contributing

Contributions to improve DevBox Setup are welcome. Please feel free to submit pull requests or create issues for bugs and feature requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Devs that have shared their dot files and configs, thank you.
