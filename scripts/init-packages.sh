#!/bin/bash

set -e

colored_echo() {
    echo -e "\033[1;32m$*\033[0m"
}
# init packages
PACKAGES="$HOME/.local/share/chezmoi/scripts/packages"
mapfile -t packages_to_install < <(grep -v '^\s*#' "$PACKAGES" | grep -v '^\s*$')

if [ ${#packages_to_install[@]} -gt 0 ]; then
    colored_echo "installing packages..."
    sudo pacman -S --noconfirm --needed "${packages_to_install[@]}"
fi

# init zsh package
if ! command -v zsh &>/dev/null; then
    colored_echo "installing Zsh..."
    sudo pacman -S --noconfirm --needed zsh zsh-completions
fi
