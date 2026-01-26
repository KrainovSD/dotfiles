#!/bin/bash

set -e

colored_echo() {
    echo -e "\033[1;32m$*\033[0m"
}

colored_echo "init ssh ..."
sudo systemctl enable sshd
sudo systemctl start sshd

colored_echo "init session ..."
sudo pacman -S --noconfirm --needed sddm qt5-graphicaleffects qt5-quickcontrols2 qt5-svg
systemctl enable sddm
systemctl start sddm
tar -xf ~/static/sddm.tar.gz -C ~/static
sudo cp -r ~/static/sddm/backgrounds /usr/share/sddm/backgrounds
sudo cp -r ~/static/sddm/themes/sugar-candy /usr/share/sddm/themes/sugar-candy
sudo ln -sf ~/.config/sddm/sddm.conf /etc/sddm.conf
chmod 655 ~/.config/sddm/sddm.conf

cat <<'EOF' | sudo tee /usr/share/wayland-sessions/hyprland-uwsm.desktop
[Desktop Entry]
Name=Hyprland (uwsm-managed)
Comment=An intelligent dynamic tiling Wayland compositor
Exec=uwsm start -e -D Hyprland hyprland.desktop
TryExec=uwsm
DesktopNames=Hyprland
Type=Application
EOF

cat <<'EOF' | sudo tee /usr/share/wayland-sessions/hyprland.desktop
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=/usr/bin/start-hyprland
Type=Application
DesktopNames=Hyprland
Keywords=tiling;wayland;compositor;
EOF

colored_echo "init music ..."
sudo pacman -S --noconfirm --needed pipewire pipewire-pulse pipewire-audio wireplumber
systemctl --user enable --now wireplumber pipewire pipewire-pulse
pactl info

# bluetooth
colored_echo "init bluetooth ..."
sudo pacman -S --noconfirm --needed bluez bluez-utils
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service
if ! grep -q "AutoEnabled=true" /etc/systemd/logind.conf; then
    sudo sed -i '/^\[Policy\]$/a AutoEnabled=true' /etc/systemd/logind.conf
fi

# init nvm
if ! command -v nvm &>/dev/null; then
    colored_echo "installing nvm ..."
    sudo pacman -S --noconfirm --needed nvm
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
colored_echo "installing docker ..."
sudo pacman -S --noconfirm --needed docker
sudo systemctl enable docker
# sudo systemctl start docker

# netbird
colored_echo "installing netbird  ..."
yay -S --needed --noconfirm netbird
if ! command -v yay &>/dev/null; then
    sudo netbird service install

fi
sudo netbird service start
