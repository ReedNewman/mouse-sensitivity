#!/bin/bash

# Install mouse-sensitivity switcher
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config/mouse-sensitivity"
PLIST_NAME="com.reed.mouse-sensitivity"
LAUNCH_AGENTS="$HOME/Library/LaunchAgents"

# Stop existing agent if running
launchctl bootout "gui/$(id -u)/$PLIST_NAME" 2>/dev/null

# Compile the Swift watcher
echo "Compiling screen-unlock-trigger..."
swiftc -framework Cocoa "$SCRIPT_DIR/screen-unlock-trigger.swift" -o "$SCRIPT_DIR/screen-unlock-trigger"

# Copy files to config dir
mkdir -p "$CONFIG_DIR"
cp "$SCRIPT_DIR/mouse-sensitivity.sh" "$CONFIG_DIR/mouse-sensitivity.sh"
cp "$SCRIPT_DIR/screen-unlock-trigger" "$CONFIG_DIR/screen-unlock-trigger"
chmod +x "$CONFIG_DIR/mouse-sensitivity.sh" "$CONFIG_DIR/screen-unlock-trigger"

# Copy example config if no config exists
if [ ! -f "$CONFIG_DIR/networks.conf" ]; then
    cp "$SCRIPT_DIR/networks.conf.example" "$CONFIG_DIR/networks.conf"
    echo "Created $CONFIG_DIR/networks.conf from example — edit it with your networks."
fi

# Install and load launch agent
cp "$SCRIPT_DIR/$PLIST_NAME.plist" "$LAUNCH_AGENTS/"
launchctl bootstrap "gui/$(id -u)" "$LAUNCH_AGENTS/$PLIST_NAME.plist"

echo "Installed and started."
echo "Triggers: login, screen unlock, network change."
echo "Logs: $CONFIG_DIR/output.log"
