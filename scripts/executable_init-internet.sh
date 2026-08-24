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
RequiredForOnline=yes
EOF
cat <<'EOF' | sudo tee /etc/systemd/network/40-wireless.network >/dev/null
[Match]
Type=wlan
Name=wl*

[Network]
DHCP=yes

[Link]
RequiredForOnline=yes
EOF

sudo systemctl enable --now systemd-networkd
sudo networkctl reload

WAIT_ONLINE_SERVICE="systemd-networkd-wait-online.service"
sudo mkdir -p "/etc/systemd/system/$WAIT_ONLINE_SERVICE.d/"
sudo tee "/etc/systemd/system/$WAIT_ONLINE_SERVICE.d/override.conf" >/dev/null <<'EOF'
[Service]
ExecStart=
ExecStart=/usr/lib/systemd/systemd-networkd-wait-online --any --timeout=15
EOF
sudo systemctl daemon-reload

DNS_LINE="FallbackDNS=8.8.8.8 8.8.4.4 2001:4860:4860::8888 2001:4860:4860::8844"
sudo sed -i '/^FallbackDNS=/d' /etc/systemd/resolved.conf
sudo sed -i "/^\[Resolve\]$/a $DNS_LINE" /etc/systemd/resolved.conf
sudo systemctl enable --now systemd-resolved
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
sudo systemctl restart systemd-resolved
colored_echo "Finished. Statuses:"
networkctl list
