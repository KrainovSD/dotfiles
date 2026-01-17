#!/bin/bash

set -e

colored_echo() {
    echo -e "\033[1;32m$*\033[0m"
}

# init dirs
mkdir -p ~/sources
mkdir -p ~/projects
mkdir -p ~/files
mkdir -p ~/static
mkdir -p ~/tmp

# init music
colored_echo "init music ..."
sudo pacman -S --noconfirm --needed pipewire pipewire-pulse pipewire-audio wireplumber
systemctl --user enable --now wireplumber pipewire pipewire-pulse
pactl info

# init language
colored_echo "init language ..."
loadkeys ru
setfont cyr-sun16
cat <<'EOF' | sudo tee /etc/vconsole.conf
KEYMAP=us
FONT=cyr-sun16
EOF

# init graphic
colored_echo "init graphic ..."
mkdir -p ~/screen

## session
colored_echo "init session ..."

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

## background
colored_echo "init background ..."
sudo pacman -S --noconfirm --needed swww
hyprctl dispatch exec swww-daemon

## theme
colored_echo "init theme ..."
tar -xf ~/static/cursors.tar.gz -C ~/static
tar -xf ~/static/icons.tar.gz -C ~/static
tar -xf ~/static/themes.tar.gz -C ~/static
sudo cp -r ~/static/themes/ /usr/share/themes/
sudo cp -r ~/static/icons/ /usr/share/icons/
sudo cp -r ~/static/cursors/ /usr/share/icons/
sudo tee /etc/fonts/local.conf <<'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>SF Pro Text</family>
      <family>Noto Sans</family>
    </prefer>
  </alias>
  <alias>
    <family>serif</family>
    <prefer>
      <family>SF Pro Text</family>
      <family>Noto Serif</family>
    </prefer>
  </alias>
  <alias>
    <family>monospace</family>
    <prefer>
      <family>FiraCode Nerd Font</family>
      <family>Noto Mono</family>
    </prefer>
  </alias>
</fontconfig>
EOF
sudo fc-cache -fv

# init sddm
colored_echo "init sddm ..."
tar -xf ~/static/sddm.tar.gz -C ~/static
sudo pacman -S --noconfirm --needed sddm qt5‑graphicaleffects qt5‑quickcontrols2 qt5‑svg
systemctl enabled sddm
systemctl start sddm
sudo cp -r ~/static/sddm/backrounds /usr/share/sddm/backgrounds
sudo ~/static/sddm/themes/sugar-candy /usr/share/sddm/themes/sugar-candy
sudo ln -sf ~/.config/sddm/sddm.conf /etc/sddm.conf
chmod 655 ~/.config/sddm/sddm.conf

# idle and lock init
colored_echo "init lock ..."
sudo pacman -S --noconfirm --needed hypridle
systemctl --user enable hypridle.service
systemctl --user start hypridle.service
if ! grep -q "HandleLidSwitchExternalPower=lock" /etc/systemd/logind.conf; then
    sudo sed -i '/^\[Login\]$/a HandleLidSwitch=lock\nHandleLidSwitchExternalPower=lock' /etc/systemd/logind.conf
fi
systemctl restart systemd-logind

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
if ! command -v docker &>/dev/null; then
    colored_echo "installing docker ..."
    sudo pacman -S --noconfirm --needed docker
    sudo systemctl enable docker
    sudo systemctl start docker
fi

# init yay
colored_echo "installing yay ..."
git clone https://aur.archlinux.org/yay.git ~/tmp/yay
cd ~/tmp/yay
makepkg -si --noconfirm

# netbird
colored_echo "installing netbird  ..."
yay -S netbird
sudo netbird service install
sudo netbird service start
