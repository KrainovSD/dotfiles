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
mkdir -p ~/screen

colored_echo "init background ..."
sudo pacman -S --noconfirm --needed swww
hyprctl dispatch exec swww-daemon

colored_echo "init theme ..."
tar -xf ~/static/cursors.tar.gz -C ~/static
tar -xf ~/static/icons.tar.gz -C ~/static || true
tar -xf ~/static/themes.tar.gz -C ~/static
sudo cp -r ~/static/themes/* /usr/share/themes/
sudo cp -r ~/static/icons/* /usr/share/icons/
sudo cp -r ~/static/cursors/* /usr/share/icons/
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

# colored_echo "init lock ..."
# sudo pacman -S --noconfirm --needed hypridle
# systemctl --user enable hypridle.service
# systemctl --user start hypridle.service
# if ! grep -q "HandleLidSwitchExternalPower=lock" /etc/systemd/logind.conf; then
#     sudo sed -i '/^\[Login\]$/a HandleLidSwitch=lock\nHandleLidSwitchExternalPower=lock' /etc/systemd/logind.conf
# fi
# # systemctl restart systemd-logind
