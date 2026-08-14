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

# PACKAGES_FILE="$HOME/.local/share/chezmoi/scripts/aur"
PACKAGES_FILE="$HOME/scripts/aur"
packages_to_install=()

while IFS= read -r line; do
    clean_line=$(echo "$line" | sed 's/#.*$//')

    clean_line=$(echo "$clean_line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    [ -z "$clean_line" ] && continue

    IFS=',' read -ra pkgs <<<"$clean_line"
    for pkg in "${pkgs[@]}"; do
        pkg=$(echo "$pkg" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [ -n "$pkg" ] && packages_to_install+=("$pkg")
    done
done <"$PACKAGES_FILE"

packages_to_install=($(echo "${packages_to_install[@]}" | tr ' ' '\n' | awk '!seen[$0]++' | tr '\n' ' '))

if [ ${#packages_to_install[@]} -gt 0 ]; then
    colored_echo "📦 Installing ${#packages_to_install[@]} packages..."
    echo "Packages: ${packages_to_install[*]}"
    yay -S --noconfirm --needed "${packages_to_install[@]}"
else
    echo "⚠️ No packages for installing"
fi
