#!/bin/bash

# macOS Development Environment Setup
# Run with: bash eos.sh

set -e

fancy_echo() {
  local fmt="$1"; shift
  printf "\n$fmt\n" "$@"
}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

print_section() {
    echo -e "\n${BLUE}═══ $1 ═══${NC}\n"
}

# Better error handling
trap 'ret=$?; test $ret -ne 0 && printf "\n${RED}Setup failed${NC}\n\n" >&2; exit $ret' EXIT

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is for macOS only"
    exit 1
fi

fancy_echo "🚀 Starting macOS development environment setup..."

# Determine Homebrew prefix
ARCH="$(uname -m)"
if [ "$ARCH" = "arm64" ]; then
    HOMEBREW_PREFIX="/opt/homebrew"
else
    HOMEBREW_PREFIX="/usr/local"
fi

# Create .bin directory if it doesn't exist
if [ ! -d "$HOME/.bin" ]; then
    mkdir "$HOME/.bin"
    print_success "Created ~/.bin directory"
fi

print_section "Package Manager Setup"

# Install Homebrew if not installed
if ! command -v brew &> /dev/null; then
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH
    eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
    print_success "Homebrew installed"
else
    print_success "Homebrew already installed"
fi

# Update Homebrew
print_info "Updating Homebrew..."
brew update --force

print_section "Shell Configuration"

# Install Fish shell
if ! command -v fish &> /dev/null; then
    print_info "Installing Fish shell..."
    brew install fish
    print_success "Fish installed"
else
    print_success "Fish already installed"
fi

# Get Fish path
FISH_PATH="$(command -v fish)"
print_info "Fish location: $FISH_PATH"

# Add Fish to allowed shells
if ! grep -q "$FISH_PATH" /etc/shells; then
    print_info "Adding Fish to /etc/shells..."
    echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
    print_success "Fish added to allowed shells"
else
    print_success "Fish already in allowed shells"
fi

# Set Fish as default shell
if [[ "$SHELL" != "$FISH_PATH" ]]; then
    print_info "Setting Fish as default shell..."
    sudo chsh -s "$FISH_PATH" "$USER"
    print_success "Fish set as default shell"
else
    print_success "Fish is already the default shell"
fi

print_section "Dotfiles"

# Install yadm first
if ! command -v brew &> /dev/null; then
    print_error "Homebrew should be installed but wasn't found"
else
    if ! command -v yadm &> /dev/null; then
        print_info "Installing yadm..."
        brew install yadm
        print_success "yadm installed"
    else
        print_success "yadm already installed"
    fi
fi

# Setup yadm and dotfiles
if ! command -v yadm &> /dev/null; then
    print_error "yadm should have been installed but wasn't found"
else
    if [ ! -d "$HOME/.local/share/yadm/repo.git" ]; then
        print_info "Ready to clone dotfiles..."
        read -p "Enter your dotfiles repo URL (or press Enter to skip): " DOTFILES_REPO
        if [ -n "$DOTFILES_REPO" ]; then
            yadm clone "$DOTFILES_REPO"
            print_success "Dotfiles cloned"
        else
            print_info "Skipping dotfiles clone"
        fi
    else
        print_success "Dotfiles already cloned"
        print_info "Pulling latest dotfiles..."
        yadm pull
    fi
fi

print_section "Essential Development Tools"

# Install tools via Homebrew bundle
print_info "Installing essential tools..."
brew bundle --file=- <<EOF
# Version Control
brew "git"
brew "gh"

# Shell utilities
brew "fzf"
brew "ripgrep"
brew "bat"
brew "eza"
brew "fd"
brew "jq"
brew "tldr"
brew "tree"
brew "htop"
brew "wget"
brew "curl"
EOF

print_success "Essential tools installed"

print_section "Node Version Manager"

# Install nvm
if [ ! -d "$HOME/.nvm" ]; then
    print_info "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    print_success "nvm installed"
else
    print_success "nvm already installed"
fi

# Source nvm for this session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js LTS
if type -t nvm > /dev/null; then
    print_info "Installing Node.js LTS..."
    nvm install --lts
    nvm alias default lts/*
    nvm use default
    
    # Verify installation
    NODE_VERSION=$(node --version 2>/dev/null)
    if [ -n "$NODE_VERSION" ]; then
        print_success "Node.js $NODE_VERSION installed and set as default"
    fi
else
    print_info "nvm not available in current session"
    print_info "After restart, run: nvm install --lts && nvm alias default lts/*"
fi

print_section "Fish Plugin Manager"

# Install Fisher (Fish plugin manager)
if ! fish -c "type -q fisher" &> /dev/null 2>&1; then
    print_info "Installing Fisher (Fish plugin manager)..."
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
    print_success "Fisher installed"
else
    print_success "Fisher already installed"
fi

# Install nvm.fish plugin for Fish compatibility
print_info "Installing nvm.fish plugin for Fish shell..."
fish -c "fisher install jorgebucaran/nvm.fish" 2>/dev/null || print_info "nvm.fish may already be installed"
print_success "nvm.fish plugin configured"

# Install fzf.fish for better fzf integration
print_info "Installing fzf.fish plugin..."
fish -c "fisher install PatrickF1/fzf.fish" 2>/dev/null || print_info "fzf.fish may already be installed"
print_success "fzf.fish plugin configured"

# Install z for Fish (directory jumping)
print_info "Installing z for Fish..."
fish -c "fisher install jethrokuan/z" 2>/dev/null || print_info "z may already be installed"
print_success "z plugin configured"

print_section "Applications"

# Install GUI applications
print_info "Installing applications..."
brew bundle --file=- <<EOF
# Development
cask "zed"
cask "ghostty"

# Browsers
cask "google-chrome"

# Design
cask "figma"

# Productivity
cask "raycast"
cask "discord"
cask "1password"
EOF

print_success "Applications installed"

print_section "Finalizing"

echo ""
print_success "Setup complete! 🎉"
echo ""
fancy_echo "Installed applications:"
echo "  • Zed (code editor)"
echo "  • Ghostty (terminal)"
echo "  • Google Chrome"
echo "  • Figma"
echo "  • Raycast"
echo "  • Discord"
echo "  • 1Password"
echo ""
fancy_echo "Next steps:"
echo "  ${YELLOW}1.${NC} Restart your terminal to use Fish shell"
if [ -z "$NODE_VERSION" ]; then
    echo "  ${YELLOW}2.${NC} Install Node.js: ${BLUE}nvm install --lts && nvm alias default lts/*${NC}"
else
    echo "  ${YELLOW}2.${NC} Node.js $NODE_VERSION is ready to use"
fi
echo "  ${YELLOW}3.${NC} Review your dotfiles: ${BLUE}yadm status${NC}"
echo ""
fancy_echo "Installed tools:"
echo "  • Version manager: nvm (Node.js)"
echo "  • Shell: Fish with Fisher plugin manager"
echo "  • Fish plugins: nvm.fish, fzf.fish, z"
echo "  • Navigation: z (smart directory jumping)"
echo "  • Search: fzf, ripgrep, fd"
echo "  • Git: git, gh (GitHub CLI)"
echo "  • File viewers: bat, eza, tree"
echo "  • Dotfiles: yadm"
echo ""
fancy_echo "Quick tips:"
echo "  • ${BLUE}z <partial-name>${NC} - Jump to frequently used directories"
echo "  • ${BLUE}Ctrl+R${NC} - Fuzzy search command history with fzf"
echo "  • ${BLUE}nvm use 20${NC} - Switch Node versions"
echo ""
