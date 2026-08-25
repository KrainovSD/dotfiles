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
pacstrap /mnt base linux linux-firmware sudo vim iwd git git-lfs openssh chezmoi tinyssh
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

## Wi-fi

```bash
sudo pacman -S wireless-regdb
# uncomment region
sudo -E nvim /etc/conf.d/wireless-regdom
```

## User

```bash
# %wheel ALL=(ALL:ALL) ALL
vim /etc/sudoers
# -m create home, -U create group as name
useradd  -m -U -G wheel -s /usr/bin/zsh krainov
passwd krainov

```

# SSH in initramfs

- install tinyssh from pacman
- install aur
- install mkinitcpio-systemd-extras from aur
- add hooks to initramfs `/etc/mkinitcpio.conf`

```md
HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block > sd-network sd-tinyssh < sd-encrypt filesystems fsck)
SD_TINYSSH_COMMAND="systemd-tty-ask-password-agent --query --watch"
SD_TINYSSH_AUTHORIZED_KEYS=/root/.ssh/authorized_keys
SD_NETWORK_CONFIG=/etc/systemd/network-initramfs
```

- generate tinyssh host keys (server identity, one-time): `tinysshd-makekey /etc/tinyssh/sshkeydir`
- put **ed25519** client public key into `/root/.ssh/authorized_keys` (sd-tinyssh only accepts `ssh-ed25519` keys, RSA/ECDSA are silently ignored)

- create configuration for sd-network with MAC adress (`ip link show`) instead of default ip links `/etc/systemd/network-initramfs/10-wired.network`

```
[Match]
MACAddress=aa:bb:cc:dd:ee:ff

[Network]
DHCP=yes
```

- add parameters `rd.luks.options=timeout=0 rootflags=x-systemd.device-timeout=0` to boot loader `/boot/loader/entries/*.conf` in the end of options line
- rebuild kernel with new init config: `sudo mkinitcpio -P`

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
# if not permissions to cd
sudo chmod 755 /var/lib/iwd

cat > /var/lib/iwd/[network_name].psk << 'EOF'
[Security]
Passphrase=[network_password]
[Settings]
AutoConnect=true
Hidden=false
EOF
```

- switch sound to bluetooth device

```bash
# required pavucontrol, pipewire, pipewire-pulse, pipewire-audio
pactl list sinks short
pactl set-default-sink Name
```

# Packages

- install `-S`
- remove `-R`, with dependencies `-Rs`
- search in local `-Qs`, in global `-Ss`
- update system `-Syu`

# FAQ

- clear font cache: `fc-cache -fv`
- visual test of sddm theme `sddm-greeter --test-mode --theme /usr/share/sddm/themes/sugar-candy`
- reboot in emergency shell `echo b > /proc/sysrq-trigger`
- find bin file to exec `pacman -Qlq package | grep /usr/bin/`
- unpack archive `tar -xf archive.tag.xz`
- if has trouble with keyboard input `loadkeys us` and then check KEYMAP in `/etc/vconsole.conf`
- gtk theme [store](https://www.gnome-look.org/)
- entry point to exit from uwsm session is `uwsm stop`
- open TTY - `Ctrl Alt F[Number of TTY]`
- autostart apps locate in `~/.config/autostart`
- if pacstrap install ended with trouble

```bash
# try to change mirror in /etc/pacman.d/mirrorlist to https://mirror.yandex.ru/archlinux/$repo/os/$arch
rm -rf /var/cache/pacman/pkg/*
rm -rf /var/lib/pacman/sync/*
rm -rf /mnt/var/cache/pacman/pkg/* 2>/dev/null
pacman-key --init # create local GnuPG
pacman-key --populate archlinux # add data to local GnuPG
pacman -S archlinux-keyring # update package for actual --refresh-keys
pacman-key --refresh-keys # update data in GnuPG
```

- change target sound device

```bash
# required pavucontrol, pipewire, pipewire-pulse, pipewire-audio
pactl list sinks short
pactl set-default-sink [name]
```
