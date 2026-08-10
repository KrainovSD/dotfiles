#!/usr/bin/env bash
#
# Scan, select, and connect to Wi-Fi networks using iwd (iwctl).
#
# Requires:
# 	- iwctl (iwd)
# 	- fzf
# 	- notify-send (libnotify)
#
# Author: Jesse Mirabel <sejjymvm@gmail.com>
# Created: August 11, 2025
# Rewritten for iwd/iwctl: 2026
# License: MIT
#
# In the open network list, press Ctrl-r to re-scan and refresh the table.
# Subcommands (used by fzf binds, not meant to be called directly):
#   network.sh __list            scan + emit "<display>\t<ssid>" rows for fzf
#   network.sh __header <state>  emit the status header (scanned/refreshing/refreshed)
#

TIMEOUT=8   # seconds to wait for scan results

SELF="$HOME/.config/waybar/scripts/network.sh"
COLHDR='      SSID                        SEC      SIGNAL'

# --- locate the wireless device managed by iwd -----------------------------
find_device() {
	device=""
	for i in /sys/class/net/*; do
		[ -d "$i/wireless" ] && device="$(basename "$i")" && break
	done
}

# iwctl emits ANSI colour codes even when piped — strip them for parsing.
strip() { sed 's/\x1b\[[0-9;]*m//g'; }

# get-networks as TSV: [*]SSID<TAB>SECURITY<TAB>SIGNAL  ('*' marks the active net)
get_networks() {
	iwctl station "$device" get-networks 2>/dev/null | strip | awk '
		NR > 4 {
			line = $0
			sub(/^[[:space:]]+/, "", line)
			active = (substr(line, 1, 1) == ">")
			if (active) { sub(/^>[[:space:]]*/, "", line) }
			# security token is a fixed vocabulary; split on it so SSIDs
			# containing spaces survive.
			if (match(line, /[[:space:]]+(open|wep|psk|8021x)[[:space:]]/)) {
				ssid     = substr(line, 1, RSTART - 1)
				security = substr(line, RSTART, RLENGTH); gsub(/[[:space:]]/, "", security)
				signal   = substr(line, RSTART + RLENGTH); gsub(/[^*]/, "", signal)
				printf "%s%s\t%s\t%s\n", (active ? "*" : ""), ssid, security, signal
			}
		}'
}

# trigger a scan, then poll until results arrive (or TIMEOUT)
scan_and_collect() {
	iwctl device "$device" set-property powered on >/dev/null 2>&1
	iwctl station "$device" scan >/dev/null 2>&1
	local nets=""
	for ((i = 1; i <= TIMEOUT; i++)); do
		nets=$(get_networks)
		[[ -n $nets ]] && break
		sleep 1
	done
	printf '%s' "$nets"
}

# TSV (stdin) -> fzf input (stdout): "<NN  SSID  SEC  SIGNAL>\t<raw-SSID>"
# field 1 is shown; field 2 carries the real SSID back on selection so the
# chosen SSID is never stale after a Ctrl-r reload.
format_rows() {
	local i=0 ssid sec sig
	while IFS=$'\t' read -r ssid sec sig; do
		[[ -z $ssid ]] && continue
		printf '%2d  %-28s %-8s %s\t%s\n' "$((i + 1))" "$ssid" "$sec" "$sig" "$ssid"
		i=$((i + 1))
	done
}

# status header shown above the list (refreshing / refreshed)
print_header() {
	local status
	case "${1:-scanned}" in
		scanned)    status="  ✓ Scanned $(date +%H:%M:%S)   ·   Ctrl-r: refresh" ;;
		refreshing) status="  ⟳ Refreshing…   ·   Ctrl-r: refresh" ;;
		refreshed)  status="  ✓ Refreshed $(date +%H:%M:%S)   ·   Ctrl-r: refresh" ;;
		*)          status="  $1" ;;
	esac
	printf '%s\n%s\n' "$status" "$COLHDR"
}

# --- subcommands used by fzf binds ------------------------------------------
case "${1:-}" in
__list)
	find_device
	[[ -n $device ]] || exit 1
	scan_and_collect | format_rows
	exit 0
	;;
__header)
	print_header "${2:-scanned}"
	exit 0
	;;
esac

# --- interactive flow -------------------------------------------------------
find_device
if [[ -z $device ]]; then
	notify-send 'Wi-Fi' 'No wireless device found' -i 'network-wireless-off'
	exit 1
fi

tput civis # hide cursor during scanning
printf 'Scanning for networks...\n\n'
networks=$(scan_and_collect)
tput cnorm # restore cursor

if [[ -z $networks ]]; then
	notify-send 'Wi-Fi' 'No networks found' -i 'package-broken'
	exit 1
fi

# shellcheck disable=SC1090
. ~/.config/waybar/scripts/fzf-colors.sh 2> /dev/null

data=$(format_rows <<< "$networks")
header0=$(print_header scanned)

sel=$(
	printf '%s\n' "$data" | fzf \
		--border=sharp \
		--border-label=' Wi-Fi Networks ' \
		--delimiter=$'\t' \
		--with-nth=1 \
		--header="$header0" \
		--bind "ctrl-r:transform-header($SELF __header refreshing)+reload($SELF __list)+transform-header($SELF __header refreshed)" \
		--ghost='Search' \
		--height=~100% \
		--highlight-line \
		--info=inline-right \
		--pointer= \
		--reverse \
		"${COLORS[@]}"
)

[[ -n $sel ]] || exit 0

# field 2 of the selected row is the real SSID; strip the '*' active marker.
ssid=$(printf '%s' "$sel" | cut -f2- | sed 's/^\*//')

printf 'Connecting to %s ...\n' "$ssid"
iwctl station "$device" connect "$ssid"

# --- check the result ------------------------------------------------------
sleep 3
connected=$(iwctl station "$device" show 2>/dev/null | strip \
	| awk '/Connected network/ { sub(/^[[:space:]]*Connected network[[:space:]]+/, ""); print; exit }')

if [[ -n $connected ]]; then
	notify-send 'Wi-Fi' "Connected: $connected" -i 'network-wireless-on' -r 1125
else
	notify-send 'Wi-Fi' 'Failed to connect' -i 'network-wireless-off' -r 1125
fi
