# Development Environment Setup Script

A one-command script to set up your development environment on a new Linux machine or MacBook Pro.

## Quick Start

Run the following command in your terminal:

```bash
./setup_dev_env.sh
```

## What It Does

The script will:

1. **Detect your OS** - Automatically identifies whether you're running macOS or Linux
2. **Update system packages** - Updates and upgrades your system packages
3. **Interactive installation** - Asks you for each component whether you want to install or skip

### Installed Components

- **curl** - Command-line URL transfer tool
- **git** - Version control system
- **oh-my-zsh** - Zsh framework with plugins (zsh-syntax-highlighting, zsh-autosuggestions)
- **tmux** - Terminal multiplexer
- **python3** - Latest Python 3 and pip
- **node.js** - Latest LTS version
- **htop** - Interactive process viewer
- **vim** - Text editor

## Usage

1. Clone or copy this repository to your new machine:

   ```bash
   git clone https://github.com/yourusername/zdevtool_init_script.git
   cd zdevtool_init_script
   ```

2. Run the script:

   ```bash
   ./setup_dev_env.sh
   ```

3. Follow the prompts - the script will ask you:
   - Whether to update/upgrade system packages
   - Whether to install each component (Y/n for each)

4. Enter your password when prompted (for sudo access)

## Requirements

- macOS or Linux
- Internet connection
- Sudo/admin privileges

## Supported Package Managers

- **macOS**: Homebrew
- **Linux**: apt-get, dnf, yum, pacman, zypper

## Notes

- The script checks if each tool is already installed and skips it if present
- You'll need to restart your shell after oh-my-zsh installation for changes to take effect
- The script is safe to run multiple times - it will only install missing components