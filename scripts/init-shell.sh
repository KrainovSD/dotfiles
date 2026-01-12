#!/bin/bash

set -e

colored_echo() {
    echo -e "\033[1;32m$*\033[0m"
}
# init packages
PACKAGES="$HOME/.local/share/chezmoi/scripts/packages"
mapfile -t packages_to_install < <(grep -v '^\s*#' "$PACKAGES" | grep -v '^\s*$')

if [ ${#packages_to_install[@]} -eq 0 ]; then
    colored_echo "nothing to install from package list"
    exit 0
fi
sudo pacman -S --noconfirm --needed "${packages_to_install[@]}"

# init zsh
if ! command -v zsh &>/dev/null; then
    colored_echo "installing Zsh..."
    sudo pacman -S --noconfirm --needed zsh zsh-completions
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    colored_echo "installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_THEMES="$HOME/.oh-my-zsh/custom/themes"
if [ ! -d "$ZSH_THEMES/powerlevel10k" ]; then
    colored_echo "installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_THEMES/powerlevel10k"
fi

ZSH_PLUGINS="$HOME/.oh-my-zsh/custom/plugins"
if [ ! -d "$ZSH_PLUGINS/zsh-autosuggestions" ]; then
    colored_echo "installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGINS/

"
fi

if [ ! -d "$ZSH_PLUGINS/zsh-syntax-highlighting" ]; then
    colored_echo "installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_PLUGINS/zsh-syntax-highlighting"
fi
