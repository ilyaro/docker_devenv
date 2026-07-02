#!/bin/bash
# Installs ramdisk-autocommit: watches /Volumes/RAMDisk for changes and
# auto-commits + pushes tracked git repos found there.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USERNAME="${USERNAME:-${SUDO_USER:-$(id -un)}}"
TARGET_HOME="$(eval echo "~$USERNAME")"
BIN_DIR="$TARGET_HOME/bin"
PLIST_DIR="$TARGET_HOME/Library/LaunchAgents"
PLIST_NAME="com.user.ramdisk-autocommit.plist"

echo "==> Checking for Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Install it first: https://brew.sh"
  exit 1
fi

echo "==> Checking for fswatch..."
if ! command -v fswatch >/dev/null 2>&1; then
  echo "Installing fswatch..."
  brew install fswatch
else
  echo "fswatch already installed."
fi

echo "==> Installing script to $BIN_DIR..."
mkdir -p "$BIN_DIR"
cp "$SCRIPT_DIR/ramdisk-autocommit.sh" "$BIN_DIR/ramdisk-autocommit.sh"
chmod +x "$BIN_DIR/ramdisk-autocommit.sh"

echo "==> Installing launchd agent to $PLIST_DIR..."
mkdir -p "$PLIST_DIR"
sed "s|__HOME__|$TARGET_HOME|g" "$SCRIPT_DIR/$PLIST_NAME" > "$PLIST_DIR/$PLIST_NAME"

echo "==> Loading launchd agent..."
# Unload first in case it's already loaded from a previous install
launchctl unload "$PLIST_DIR/$PLIST_NAME" >/dev/null 2>&1 || true
launchctl load "$PLIST_DIR/$PLIST_NAME"

echo ""
echo "Done. ramdisk-autocommit is now running in the background."
echo "  - Script:  $BIN_DIR/ramdisk-autocommit.sh"
echo "  - Agent:   $PLIST_DIR/$PLIST_NAME"
echo "  - Logs:    /tmp/ramdisk-autocommit.out.log and .err.log"
echo ""
echo "To stop it:    launchctl unload $PLIST_DIR/$PLIST_NAME"
echo "To restart it: launchctl unload $PLIST_DIR/$PLIST_NAME && launchctl load $PLIST_DIR/$PLIST_NAME"
