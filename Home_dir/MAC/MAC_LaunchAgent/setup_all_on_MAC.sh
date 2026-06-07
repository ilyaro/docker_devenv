#! /bin/bash
set -x
# This script sets up the environment for a macOS system.
## It creates a ramdisk and sets up a LaunchAgent to automatically create the ramdisk at startup.

LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
DEPLOY_DIR="$HOME/Deploy/RAMDISK"

# Create directories
mkdir -p "$LAUNCH_AGENTS_DIR"
mkdir -p "$DEPLOY_DIR"

# Deploy the ramdisk script
cp create_ramdisk.sh "$DEPLOY_DIR/create_ramdisk.sh"
chmod +x "$DEPLOY_DIR/create_ramdisk.sh"

# Copy plist with the actual path substituted
sed "s|__HOME_DIR__|$HOME|g" com.user.ramdisk.plist > "$LAUNCH_AGENTS_DIR/com.user.ramdisk.plist"

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
