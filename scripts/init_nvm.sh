#!/bin/bash

sudo pacman -S nvm

grep -q "export NVM_DIR" ~/.zshrc || {
    cat >>~/.zshrc <<'EOF'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
}

source /usr/share/nvm/init-nvm.sh
source zshrc
nvm install 24.11.0
nvm use 24.11.0
npm install -g pnpm
