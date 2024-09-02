# Getting Started

## Prerequisites

- **Debian-based System**: This script is designed to work on Debian-based distributions (e.g., Ubuntu).
- **Git**: Ensure Git is installed on your system to clone this repository.

## Quick Start

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

4. **Apply Environment Changes**:
   If prompted, source the `.bashrc` file to apply the environment changes immediately:
   ```bash
   source ~/.bashrc
   ```

5. **Reboot Your System**:
   ```bash
   sudo reboot
   ```

## License
