#!/bin/bash

set -e

colored_echo() {
    echo -e "\033[1;32m$*\033[0m"
}

# init nvm
if ! command -v nvm &>/dev/null; then
    colored_echo "installing nvm ..."
    sudo pacman -S --noconfirm nvm
    grep -q "export NVM_DIR" ~/.zshrc || {
        cat >>~/.zshrc <<'EOF'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
    }

    # shellcheck source=/dev/null
    source /usr/share/nvm/init-nvm.sh
    # zsh
    nvm install 24.11.0
    nvm use 24.11.0
    npm install -g pnpm
fi

# init docker
if ! command -v docker &>/dev/null; then
    colored_echo "installing docker ..."
    sudo pacman -S --noconfirm docker
    systemctl enable docker
    systemctl start docker
fi
