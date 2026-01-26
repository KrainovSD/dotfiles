#!/bin/bash

set -e

colored_echo() {
    echo -e "\033[1;32m$*\033[0m"
}

colored_echo "init internet"
sudo systemctl enable iwd
sudo systemctl start iwd
cat <<'EOF' | sudo tee /etc/iwd/main.conf
[General]
EnableNetworkConfiguration=true
[Network]
NameResolvingService=systemd
EOF
sudo systemctl enable systemd-resolved
sudo systemctl start systemd-resolved
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
if ! grep -q "DNS=8.8.8.8#dns.google 8.8.4.4#dns.google 2001:4860:4860::8888#dns.google 2001:4860:4860::8844#dns.google" /etc/systemd/resolved.conf; then
    sudo sed -i '/^\[Resolve\]$/a DNS=8.8.8.8#dns.google 8.8.4.4#dns.google 2001:4860:4860::8888#dns.google 2001:4860:4860::8844#dns.google' /etc/systemd/resolved.conf
fi
sudo systemctl restart systemd-resolved
