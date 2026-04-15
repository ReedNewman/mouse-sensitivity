#!/bin/bash

# Uninstall mouse-sensitivity switcher
PLIST_NAME="com.reed.mouse-sensitivity"

launchctl bootout "gui/$(id -u)/$PLIST_NAME" 2>/dev/null
rm -f "$HOME/Library/LaunchAgents/$PLIST_NAME.plist"
rm -rf "$HOME/.config/mouse-sensitivity"

# Reset to default
defaults write -g com.apple.mouse.scaling -float 1.0

echo "Uninstalled. Mouse speed reset to 1.0."
