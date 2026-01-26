#!/bin/bash

set -e

colored_echo() {
    echo -e "\033[1;32m$*\033[0m"
}

if ! command -v yay &>/dev/null; then
    colored_echo "installing yay..."
    git clone https://aur.archlinux.org/yay.git ~/tmp/yay
    cd ~/tmp/yay
    makepkg -si --noconfirm

fi

PACKAGES="$HOME/.local/share/chezmoi/scripts/aur"
mapfile -t packages_to_install < <(grep -v '^\s*#' "$PACKAGES" | grep -v '^\s*$')

if [ ${#packages_to_install[@]} -gt 0 ]; then
    colored_echo "installing packages..."
    yay -S --noconfirm --needed "${packages_to_install[@]}"
fi
