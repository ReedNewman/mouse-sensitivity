#!/bin/bash

# Mouse sensitivity switcher based on network gateway
# networksetup -getairportnetwork no longer works on macOS 15+ (SSID redacted)
# so we identify the network by default gateway IP instead.

INSTALL_DIR="$HOME/.config/mouse-sensitivity"
STATE_FILE="$INSTALL_DIR/.last-gateway"
CONFIG_FILE="$INSTALL_DIR/networks.conf"
SET_SPEED="$INSTALL_DIR/set-mouse-speed"
DEFAULT_SPEED="1.0"

# Load network config: lines of "gateway_ip speed name"
get_speed_for_gateway() {
    if [ -f "$CONFIG_FILE" ]; then
        while IFS=' ' read -r gw speed name; do
            [[ "$gw" =~ ^#.*$ || -z "$gw" ]] && continue
            if [ "$1" = "$gw" ]; then
                echo "$speed"
                return
            fi
        done < "$CONFIG_FILE"
    fi
    echo "$DEFAULT_SPEED"
}

get_network_name() {
    if [ -f "$CONFIG_FILE" ]; then
        while IFS=' ' read -r gw speed name; do
            [[ "$gw" =~ ^#.*$ || -z "$gw" ]] && continue
            if [ "$1" = "$gw" ]; then
                echo "${name:-$gw}"
                return
            fi
        done < "$CONFIG_FILE"
    fi
    echo "other ($1)"
}

GATEWAY=$(route -n get default 2>/dev/null | awk '/gateway:/{print $2}')

if [ -z "$GATEWAY" ]; then
    GATEWAY="__disconnected__"
fi

LAST_GATEWAY=""
if [ -f "$STATE_FILE" ]; then
    LAST_GATEWAY=$(cat "$STATE_FILE")
fi

if [ "$GATEWAY" != "$LAST_GATEWAY" ]; then
    SPEED=$(get_speed_for_gateway "$GATEWAY")
    NETWORK=$(get_network_name "$GATEWAY")
    defaults write -g com.apple.mouse.scaling -float "$SPEED"
    "$SET_SPEED" "$SPEED"
    echo "$GATEWAY" > "$STATE_FILE"
    osascript -e "display notification \"Mouse speed set to $SPEED\" with title \"Network: $NETWORK\""
fi
