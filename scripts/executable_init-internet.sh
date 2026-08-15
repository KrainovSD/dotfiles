#!/bin/bash

set -e

colored_echo() {
    echo -e "\033[1;32m$*\033[0m"
}

colored_echo "init internet"

if ls /sys/class/net/*/wireless >/dev/null 2>&1; then
    sudo systemctl enable --now iwd
    cat <<'EOF' | sudo tee /etc/iwd/main.conf >/dev/null
[General]
EnableNetworkConfiguration=false
[Network]
NameResolvingService=systemd
EOF
else
    colored_echo "skip iwd: no Wi-Fi module"
fi

sudo mkdir -p /etc/systemd/network
cat <<'EOF' | sudo tee /etc/systemd/network/20-wired.network >/dev/null
[Match]
Type=ether
Name=en*

[Network]
DHCP=yes

[Link]
RequiredForOnline=no
EOF
cat <<'EOF' | sudo tee /etc/systemd/network/40-wireless.network >/dev/null
[Match]
Type=wlan
Name=wl*

[Network]
DHCP=yes

[Link]
RequiredForOnline=no
EOF

sudo systemctl enable --now systemd-networkd
sudo networkctl reload
DNS_LINE="DNS=8.8.8.8#dns.google 8.8.4.4#dns.google 2001:4860:4860::8888#dns.google 2001:4860:4860::8844#dns.google"
if ! grep -qF "$DNS_LINE" /etc/systemd/resolved.conf; then
    sudo sed -i "/^\[Resolve\]$/a $DNS_LINE" /etc/systemd/resolved.conf
fi
sudo systemctl enable --now systemd-resolved
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
sudo systemctl restart systemd-resolved
colored_echo "Finished. Statuses:"
networkctl list
