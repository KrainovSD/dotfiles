# Install

## Initial installation

- disk partitioning and mounting required the four parts.

1. EFI System (1, 1G, mkfs.fat -F 32)
2. Linux Swap(19, 8G, mkswap)
3. Root (30% >= 50G, mkfs.ext4)
4. Home (mkfs.ext4)

```bash
fdisk - l
# p - view list of parts, d - delete part, g - create gpt table, n - new part, t - change part type, w - write changes
fdisk /dev/nvme0n1

# if cryptsetup is not allowed
modprobe dm-crypt
modprobe dm-mod

cryptsetup -v luksFormat --type luks2 --hash sha512 --key-size 512 /dev/root
# optional parameter after /dev/home is key-file path
cryptsetup -v luksFormat --type luks2 --hash sha512 --key-size 512 /dev/home
cryptsetup open /dev/root root
cryptsetup open /dev/home home

mkfs.ext4 -L "ARCH_ROOT" /dev/mapper/root
mkfs.ext4 -L "ARCH_HOME" /dev/mapper/home
mkswap /dev/swap
mkfs.fat -F 32 /dev/EFI

mount /dev/mapper/root /mnt
mkdir -p /mnt/home
mount /dev/mapper/home /mnt/home
mount /dev/EFI /mnt/boot
swapon /dev/swap
pacstrap /mnt base linux linux-firmware sudo vim iwd git git-lfs openssh chezmoi dhcpcd
# create table of file system
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc
# uncomment ru_RU.UTF-8 and en_US.UTF-8
vim /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
echo krainov > /etc/hostname
passwd

bootctl install
cat > /boot/efi/loader/loader.conf << 'EOF'
default arch.conf
timeout 4
console-mode max
editor no
EOF
# or LABEL
# `sudo blkid` or `lsblk -f`- partition info for UUID
# options root="UUID=7dacec9e-c4fd-4d5c-b076-e2e193c45ae9" rw - without encryption
# cryptdevice=UUID=7dacec9e-c4fd-4d5c-b076-e2e193c45ae9:root root=/dev/mapper/root - not systemd
cat > /boot/efi/loader/entries/arch.conf << 'EOF'
title Arch Linux
linux /vmlinuz-linux
# initrd /intel-ucode.img
initrd /initramfs-linux.img
options rd.luks.name=9dacec9e-c4fd-4d5c-b076-e2e193c45ae9=root root=/dev/mapper/root rw
EOF
cat > /boot/efi/loader/entries/arch-fallback.conf << 'EOF'
title Arch Linux (fallback)
linux /vmlinuz-linux
initrd /initramfs-linux-fallback.img
options rd.luks.name=9dacec9e-c4fd-4d5c-b076-e2e193c45ae9=root root=/dev/mapper/root rw
EOF
# or /etc/home-password if has a key-file
cat > /etc/crypttab << 'EOF'
home         UUID=b8ad5c18-f445-495d-9095-c9ec4f9d2f37   none  timeout=180
EOF


# add encrypt to HOOK udev or systemd
# HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt filesystems fsck)
# HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck)
vim /etc/mkinitcpio.conf

loadkeys ru
# or pacman -S terminus-font then setfont ter-120n or ter-132n
setfont cyr-sun16
cat > /etc/vconsole.conf << 'EOF'
KEYMAP=us
FONT=cyr-sun16
EOF

mkinitcpio -p linux

reboot
pacman -Syu
reboot
```

## Microcode

```bash
pacman -S --noconfirm --needed intel-ucode
# initrd  /intel-ucode.img before other initrd
vim /boot/loader/entries/arch.conf
reboot
# Example: current revision: XXX; update early from: XXXX
dmesg | grep microcode
# check version of microcode in cpu that current revision in each of cpu
cat /proc/cpuinfo | grep microcode
```

## User

```bash
# %wheel ALL=(ALL:ALL) ALL
vim /etc/sudoers
# -m create home, -U create group as name
useradd  -m -U -G wheel -s /usr/bin/zsh krainov
passwd krainov

```

# Music

```bash
sudo pacman -S --noconfirm --needed pipewire pipewire-pulse pipewire-audio wireplumber
systemctl --user enable --now wireplumber pipewire pipewire-pulse
pactl info
```

# Graphic

## Session

```bash
cat > /usr/share/wayland-sessions/hyprland-uwsm.desktop << 'EOF'
[Desktop Entry]
Name=Hyprland (uwsm-managed)
Comment=An intelligent dynamic tiling Wayland compositor
Exec=uwsm start -e -D Hyprland hyprland.desktop
TryExec=uwsm
DesktopNames=Hyprland
Type=Application
EOF

cat > /usr/share/wayland-sessions/hyprland.desktop << 'EOF'
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=/usr/bin/start-hyprland
Type=Application
DesktopNames=Hyprland
Keywords=tiling;wayland;compositor;
EOF
```

## Background

```bash
sudo pacman -S --noconfirm --needed swww
hyprctl dispatch exec swww-daemon
swww img [path]
```

## Theme

- themes in `/usr/share/themes`
- cursors in `usr/share/icons` and apply through `hyprctl setcursor "[name] [size]"`

# SDDM

- setting sddm login screen

```bash
# install required packages
sudo pacman -S --noconfirm --needed sddm qt5‑graphicaleffects qt5‑quickcontrols2 qt5‑svg
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
sudo pacman -S --noconfirm --needed hypridle
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
sudo pacman -S --noconfirm --needed iwd
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
sudo pacman -S --noconfirm --needed iwd
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

ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolved.conf
# iwctl device list for search correct name
iwctl stations wlan0 show

sudo -E vim /etc/systemd/resolved.conf
# DNS=8.8.8.8#dns.google 8.8.4.4#dns.google 2001:4860:4860::8888#dns.google 2001:4860:4860::8844#dns.google
```

# Bluetooth

- connect to bluetooth by your own hand

```bash
sudo pacman -S --noconfirm --needed bluez bluez-utils
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

# Packages

- install `-S`
- remove `-R`, with dependencies `-Rs`
- search in local `-Qs`, in global `-Ss`
- update system `-Syu`
- install yay

```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

```

# Developer tools

## Docker

- start the docker service

```bash
sudo pacman -S --noconfirm --needed docker
systemctl enable docker
systemctl start docker
```

## Netbird

- start the netbird VPN service

```bash
yay -S netbird
sudo netbird service install
sudo netbird service start
# or NB_MANAGEMENT_URL env
sudo netbird up --management-url [your_url]
sudo netbird down
```

## Node Version Manager (NVM)

- install and prepare nvm to work

```bash
sudo pacman -S --noconfirm --needed nvm

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
- if has trouble with keyboard input `loadkeys us` and then check KEYMAP in `/etc/vconsole.conf`
- check permission of file `stat -c "%a" [file]`
- gtk theme [store](https://www.gnome-look.org/)
- entry point to exit from uwsm session is `uwsm stop`
- exit from login manager to terminal `Ctrl Alt F2`
- if pacstrap install ended with trouble

```bash
# try to change mirror in /etc/pacman.d/mirrorlist to https://mirror.yandex.ru/archlinux/$repo/os/$arch
rm -rf /var/cache/pacman/pkg/*
rm -rf /var/lib/pacman/sync/*
rm -rf /mnt/var/cache/pacman/pkg/* 2>/dev/null
pacman-key --init
pacman-key --populate archlinux
pacman-key --refresh-keys
pacman -Syyyy
pacman -S archlinux-keyring
```
