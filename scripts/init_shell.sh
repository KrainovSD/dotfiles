#!/bin/bash

set -e
echo "init shell"

# RED='\033[0;31m'
# GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

sudo pacman -S --noconfirm --needed lsd bat nvim go

if ! command -v zsh &>/dev/null; then
    echo -e "${YELLOW}Installing Zsh...${NC}"
    sudo pacman -S --noconfirm --needed zsh zsh-completions
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${YELLOW}Installing Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_THEMES="$HOME/.oh-my-zsh/custom/themes"
if [ ! -d "$ZSH_THEMES/powerlevel10k" ]; then
    echo -e "${YELLOW}Installing Powerlevel10k...${NC}"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_THEMES/powerlevel10k"
fi

ZSH_PLUGINS="$HOME/.oh-my-zsh/custom/plugins"
if [ ! -d "$ZSH_PLUGINS/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGINS/zsh-autosuggestions"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_PLUGINS/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_PLUGINS/zsh-syntax-highlighting"
fi

echo -e "finished init shell"
