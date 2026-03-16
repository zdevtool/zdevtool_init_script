#!/bin/bash

set -e

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    else
        echo "Unsupported operating system: $OSTYPE"
        exit 1
    fi
    echo "Detected OS: $OS"
}

check_sudo() {
    if [[ "$OS" == "macos" ]]; then
        if sudo -n true 2>/dev/null; then
            SUDO_AVAILABLE=true
        else
            SUDO_AVAILABLE=false
        fi
    else
        if [[ $EUID -eq 0 ]] || sudo -n true 2>/dev/null; then
            SUDO_AVAILABLE=true
        else
            SUDO_AVAILABLE=false
        fi
    fi
}

require_sudo() {
    if [[ "$SUDO_AVAILABLE" == "false" ]]; then
        echo "Root permission required. Please enter your password:"
        if [[ "$OS" == "macos" ]]; then
            sudo -v
        else
            sudo -v
        fi
        SUDO_AVAILABLE=true
    fi
}

ask_user() {
    local prompt="$1"
    local default="${2:-Y}"
    local response

    while true; do
        if [[ "$default" == "Y" ]]; then
            read -p "$prompt [Y/n]: " response
            response=${response:-Y}
        else
            read -p "$prompt [y/N]: " response
            response=${response:-N}
        fi

        case "$response" in
            [Yy]|[Yy][Ee][Ss])
                return 0
                ;;
            [Nn]|[Nn][Oo])
                return 1
                ;;
            *)
                echo "Please answer Y or N"
                ;;
        esac
    done
}

update_system_macos() {
    require_sudo
    echo "Updating macOS packages..."
    if ask_user "Do you want to update brew packages?" Y; then
        require_sudo
        brew update
        brew upgrade
    fi
}

update_system_linux() {
    echo "Updating Linux packages..."
    if ask_user "Do you want to update and upgrade system packages?" Y; then
        require_sudo
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get upgrade -y
        elif command -v dnf &> /dev/null; then
            sudo dnf update -y
        elif command -v yum &> /dev/null; then
            sudo yum update -y
        elif command -v pacman &> /dev/null; then
            sudo pacman -Syu --noconfirm
        elif command -v zypper &> /dev/null; then
            sudo zypper update -y
        fi
    fi
}

install_curl() {
    echo "Checking curl..."
    if command -v curl &> /dev/null; then
        echo "curl is already installed"
        return 0
    fi

    if ask_user "Do you want to install curl?" Y; then
        require_sudo
        if [[ "$OS" == "macos" ]]; then
            brew install curl
        elif command -v apt-get &> /dev/null; then
            sudo apt-get install -y curl
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y curl
        elif command -v yum &> /dev/null; then
            sudo yum install -y curl
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm curl
        elif command -v zypper &> /dev/null; then
            sudo zypper install -y curl
        fi
    fi
}

install_git() {
    echo "Checking git..."
    if command -v git &> /dev/null; then
        echo "git is already installed: $(git --version)"
        return 0
    fi

    if ask_user "Do you want to install git?" Y; then
        require_sudo
        if [[ "$OS" == "macos" ]]; then
            brew install git
        elif command -v apt-get &> /dev/null; then
            sudo apt-get install -y git
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y git
        elif command -v yum &> /dev/null; then
            sudo yum install -y git
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm git
        elif command -v zypper &> /dev/null; then
            sudo zypper install -y git
        fi
    fi
}

install_zsh() {
    echo "Checking zsh..."
    if command -v zsh &> /dev/null; then
        echo "zsh is already installed: $(zsh --version)"
        return 0
    fi

    if ask_user "Do you want to install zsh?" Y; then
        require_sudo
        if [[ "$OS" == "macos" ]]; then
            brew install zsh
        elif command -v apt-get &> /dev/null; then
            sudo apt-get install -y zsh
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y zsh
        elif command -v yum &> /dev/null; then
            sudo yum install -y zsh
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm zsh
        elif command -v zypper &> /dev/null; then
            sudo zypper install -y zsh
        fi
    fi
}

install_oh_my_zsh() {
    echo "Checking oh-my-zsh..."
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo "oh-my-zsh is already installed"
        return 0
    fi

    if ask_user "Do you want to install oh-my-zsh?" Y; then
        install_zsh

        if [[ -d "$HOME/.oh-my-zsh" ]]; then
            echo "oh-my-zsh was already installed"
            return 0
        fi

        if ask_user "Install oh-my-zsh without plugins? (Press n to install with common plugins)" Y; then
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        else
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" 2>/dev/null || true
            git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" 2>/dev/null || true

            sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc 2>/dev/null || true
        fi
    fi
}

install_tmux() {
    echo "Checking tmux..."
    if command -v tmux &> /dev/null; then
        echo "tmux is already installed: $(tmux -V)"
        return 0
    fi

    if ask_user "Do you want to install tmux?" Y; then
        require_sudo
        if [[ "$OS" == "macos" ]]; then
            brew install tmux
        elif command -v apt-get &> /dev/null; then
            sudo apt-get install -y tmux
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y tmux
        elif command -v yum &> /dev/null; then
            sudo yum install -y tmux
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm tmux
        elif command -v zypper &> /dev/null; then
            sudo zypper install -y tmux
        fi
    fi
}

install_python3() {
    echo "Checking python3..."
    if command -v python3 &> /dev/null; then
        echo "python3 is already installed: $(python3 --version)"
        return 0
    fi

    if ask_user "Do you want to install python3?" Y; then
        require_sudo
        if [[ "$OS" == "macos" ]]; then
            brew install python3
        elif command -v apt-get &> /dev/null; then
            sudo apt-get install -y python3 python3-pip
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y python3 python3-pip
        elif command -v yum &> /dev/null; then
            sudo yum install -y python3 python3-pip
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm python python-pip
        elif command -v zypper &> /dev/null; then
            sudo zypper install -y python3 python3-pip
        fi
    fi
}

install_nodejs() {
    echo "Checking node.js..."
    if command -v node &> /dev/null; then
        echo "node is already installed: $(node --version)"
        return 0
    fi

    if ask_user "Do you want to install latest node.js?" Y; then
        require_sudo
        if [[ "$OS" == "macos" ]]; then
            brew install node
        else
            if command -v curl &> /dev/null; then
                curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
                sudo apt-get install -y nodejs
            else
                if [[ "$OS" == "linux" ]]; then
                    if command -v apt-get &> /dev/null; then
                        require_sudo
                        sudo apt-get install -y curl
                        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
                        sudo apt-get install -y nodejs
                    elif command -v dnf &> /dev/null; then
                        require_sudo
                        sudo dnf install -y curl
                        curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
                        sudo dnf install -y nodejs
                    fi
                fi
            fi
        fi
    fi
}

install_htop() {
    echo "Checking htop..."
    if command -v htop &> /dev/null; then
        echo "htop is already installed"
        return 0
    fi

    if ask_user "Do you want to install htop?" Y; then
        require_sudo
        if [[ "$OS" == "macos" ]]; then
            brew install htop
        elif command -v apt-get &> /dev/null; then
            sudo apt-get install -y htop
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y htop
        elif command -v yum &> /dev/null; then
            sudo yum install -y htop
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm htop
        elif command -v zypper &> /dev/null; then
            sudo zypper install -y htop
        fi
    fi
}

install_vim() {
    echo "Checking vim..."
    if command -v vim &> /dev/null; then
        echo "vim is already installed: $(vim --version | head -n1)"
        return 0
    fi

    if ask_user "Do you want to install vim?" Y; then
        require_sudo
        if [[ "$OS" == "macos" ]]; then
            brew install vim
        elif command -v apt-get &> /dev/null; then
            sudo apt-get install -y vim
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y vim
        elif command -v yum &> /dev/null; then
            sudo yum install -y vim
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm vim
        elif command -v zypper &> /dev/null; then
            sudo zypper install -y vim
        fi
    fi
}

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_header() {
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║       Development Environment Setup Script                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    local step=$1
    local title=$2
    echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}${BOLD}  ⇨ $step: $title${NC}"
    echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}  ✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}  ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}  ⚠ $1${NC}"
}

refresh_path() {
    if [[ "$OS" == "macos" ]]; then
        export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"
    else
        export PATH="/usr/local/bin:/usr/bin:$PATH"
    fi

    if command -v brew &> /dev/null; then
        BREW_PREFIX=$(brew --prefix 2>/dev/null)
        if [[ -n "$BREW_PREFIX" ]]; then
            export PATH="$BREW_PREFIX/bin:$BREW_PREFIX/sbin:$PATH"
        fi
    fi
}

main() {
    print_header

    detect_os
    check_sudo
    refresh_path

    echo -e "${BLUE}This script will help you set up your development environment.${NC}"
    echo -e "${BLUE}You'll be asked for each step whether you want to install or skip.${NC}"
    echo ""

    if [[ "$OS" == "macos" ]]; then
        update_system_macos
    else
        update_system_linux
    fi

    print_step "Step 1" "curl"
    install_curl

    print_step "Step 2" "git"
    install_git

    print_step "Step 3" "zsh"
    install_zsh

    print_step "Step 4" "oh-my-zsh"
    install_oh_my_zsh

    print_step "Step 5" "tmux"
    install_tmux

    print_step "Step 6" "python3"
    install_python3

    print_step "Step 7" "node.js (latest LTS)"
    install_nodejs

    print_step "Step 8" "htop"
    install_htop

    print_step "Step 9" "vim"
    install_vim

    echo -e "${GREEN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    Setup Complete!                           ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    echo -e "${CYAN}${BOLD}Installed components:${NC}"
    command -v curl &> /dev/null && print_success "curl"
    command -v git &> /dev/null && print_success "git ($(git --version | cut -d' ' -f3))"
    command -v zsh &> /dev/null && print_success "zsh ($(zsh --version))"
    [[ -d "$HOME/.oh-my-zsh" ]] && print_success "oh-my-zsh"
    command -v tmux &> /dev/null && print_success "tmux ($(tmux -V))"
    command -v python3 &> /dev/null && print_success "python3 ($(python3 --version))"
    command -v node &> /dev/null && print_success "node.js ($(node --version))"
    command -v htop &> /dev/null && print_success "htop"
    command -v vim &> /dev/null && print_success "vim"

    echo ""
    print_info "Run 'exec zsh' to switch to zsh shell immediately"
}

main "$@"