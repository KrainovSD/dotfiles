#!/bin/bash

set -e
echo "start init"

# RED='\033[0;31m'
# GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# init packages
PACKAGES="$HOME/.local/share/chezmoi/scripts/packages"
mapfile -t packages_to_install < <(grep -v '^\s*#' "$PACKAGES" | grep -v '^\s*$')

if [ ${#packages_to_install[@]} -eq 0 ]; then
    echo "Нет пакетов для установки"
    exit 0
fi
sudo pacman -S --noconfirm --needed "${packages_to_install[@]}"

# init zsh
if ! command -v zsh &>/dev/null; then
    echo -e "${YELLOW}Installing Zsh...${NC}"
    echo "n" | sudo pacman -S --noconfirm --needed zsh zsh-completions
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

# init nvm
sudo pacman -S nvm

grep -q "export NVM_DIR" ~/.zshrc || {
    cat >>~/.zshrc <<'EOF'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
}

# shellcheck source=/dev/null
source /usr/share/nvm/init-nvm.sh
# shellcheck source=/dev/null
source zshrc
nvm install 24.11.0
nvm use 24.11.0
npm install -g pnpm

echo -e "finished init"
