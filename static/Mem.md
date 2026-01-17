# Install

# Graphic

- gtk theme [store](https://www.gnome-look.org/)

# SDDM

- setting sddm login screen

```bash
# install required packages
sudo pacman -S --needed sddm qt5‑graphicaleffects qt5‑quickcontrols2 qt5‑svg
# start system sddm daemon
systemctl enabled sddm
systemctl start sddm
# copy sddm backgrounds
sudo cp -r ~/static/sddm/backrounds /usr/share/sddm/backgrounds
# copy sddm theme
sudo ~/static/sddm/themes/sugar-candy /usr/share/sddm/themes/sugar-candy
# link sddm config and set permissions
sudo ln -sf ~/.config/sddm/sddm.conf /etc/sddm.conf
chmod 655 ~/.config/sddm/sddm.conf
```

- visual test of sddm theme `sddm-greeter --test-mode --theme /usr/share/sddm/themes/sugar-candy`
- web site with [sddm login themes](https://store.kde.org)

# Lock sreen and Idle

- setting idle behaviour

```bash
sudo pacman -S hypridle
systemctl --user enable hypridle.service
systemctl --user start hypridle.service

# turn off spend after close notebook
vim /etc/systemd/logind.conf
# [Login]
# HandleLidSwitch=lock
# HandleLidSwitchExternalPower=lock
systemctl restart systemd-logind
```

# Internet

- connect to wifi by your own hand

```bash
sudo pacman -S iwd
iwctl
device list
device wlan0 set-property Powered on
station wlan0 scan
station wlan0 get-networks
station wlan0 connect [network_name]
# if error try
rfkill unblock wlan
# check status
networkctl status wlan0

```

- auto connect to wifi

```bash
sudo pacman -S iwd
systemctl enable iwd
systemctl start iwd
# if not permissions to cd
sudo chmod 755 /var/lib/iwd

cat > /etc/iwd/main.conf << 'EOF'
[General]
EnableNetworkConfiguration=true
[Network]
NameResolvingService=systemd
EOF

cat > /var/lib/iwd/[network_name].psk << 'EOF'
[Security]
Passphrase=[network_password]
[Settings]
AutoConnect=true
Hidden=false
EOF
```

- setting dns resolver

```bash
systemctl enable systemd-resolved
systemctl start systemd-resolved

ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
# iwctl device list for search correct name
iwctl stations wlan0 show

sudo -E vim /etc/systemd/resolved.conf
# DNS=8.8.8.8#dns.google 8.8.4.4#dns.google 2001:4860:4860::8888#dns.google 2001:4860:4860::8844#dns.google
```

# Bluetooth

- connect to bluetooth by your own hand

```bash
sudo pacman -S bluez bluez-utils
systemctl enable bluetooth.service
systemctl start bluetooth.service

sudo -E vim /etc/bluetooth/main.conf
# [Policy]
# AutoEnabled=true

bluetoothctl power on
bluetoothctl agent on
bluetoothctl default-agent
bluetoothctl scan on
bluetoothctl trust [id_of_device]
bluetoothctl pair [id_of_device]
bluetoothctl connect [id_of_device]
bluetoothctl info [id_of_device]
bluetoothctl devices
```

- switch sound to bluetooth device

```bash
# required pavucontrol, pipewire, pipewire-pulse, pipewire-audio
pactl list sinks short
pactl set-default-sink Name
```

# Fonts

- fonts config file `/etc/fonts/local.conf`

```html
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
```

- fonts service commands

```bash
# update font cache
fc-cache -fv
# check installed fonts
fc-list : family | sort -u

```

# Developer tools

## Docker

- start the docker service

```bash
sudo pacman -S docker
systemctl enable docker
systemctl start docker
```

## Netbird

- start the netbird VPN service

```bash
yay -S netbird
sudo netbird service install
sudo netbird service start
sudo netbird up --management-url [your_url]
sudo netbird down
```

## Node Version Manager (NVM)

- install and prepare nvm to work

```bash
sudo pacman -S nvm

grep -q "export NVM_DIR" ~/.zshrc || {
cat >> ~/.zshrc << 'EOF'

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
```

# List of Packages

pacman: dunst (notification UI), code (vs code), ttf-0xproto-nerd, pacman-contrib, networkmanager, fzf, brightnessctl, nvim, openssh, ctags (vim tags), imagemagick (vim image preview), nvm, uv, snappy bzip2 zlib lz4 zstd gflags, gcc, clang, numactl, keepassxs, mattermost-desktop, hyprlock, hypridle, bluez, bluez-utils, pavucontrol (switch audio inputs), grim (screenshot), slarp (viewport for screenshot), wf-recorder

yay: netbird

# FAQ

- check battery `cat /sys/class/power_supply/BAT*/capacity`
- reboot in emergency shell `echo b > /proc/sysrq-trigger`
- check RAM `free -h`
- check free disk `df -h`
- find bin file to exec `pacman -Qlq package | grep /usr/bin/`
- unpack archive `tar -xf archive.tag.xz`
