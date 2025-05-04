#! /bin/bash
set -x
# This script sets up the environment for a macOS system.
## It creates a ramdisk and sets up a LaunchAgent to automatically create the ramdisk at startup.

# Define paths
LAUNCH_AGENTS_DIR="/Users/ilyaro/Library/LaunchAgents"
HOME_DIR="/Users/ilyaro"

# Create LaunchAgents directory if it doesn't exist
mkdir -p "$LAUNCH_AGENTS_DIR"

# It also copies a plist file to the LaunchAgents directory and loads it.
cp com.user.ramdisk.plist "$LAUNCH_AGENTS_DIR/com.user.ramdisk.plist"
cp create_ramdisk.sh "$HOME_DIR/create_ramdisk.sh"
chmod +x "$HOME_DIR/create_ramdisk.sh"

# Check if plist file exists
if [ ! -f "$LAUNCH_AGENTS_DIR/com.user.ramdisk.plist" ]; then
    echo "Error: plist file not found at $LAUNCH_AGENTS_DIR/com.user.ramdisk.plist"
    exit 1
fi

# Unload the service first in case it's already loaded
launchctl unload "$LAUNCH_AGENTS_DIR/com.user.ramdisk.plist" 2>/dev/null

# This will create a ramdisk at startup
launchctl bootstrap gui/$(id -u) "$LAUNCH_AGENTS_DIR/com.user.ramdisk.plist"

echo "LaunchAgent loaded successfully. Ramdisk will be created at startup."
