#! /bin/bash

# This script sets up the environment for a macOS system.
## It creates a ramdisk and sets up a LaunchAgent to automatically create the ramdisk at startup.

# It also copies a plist file to the LaunchAgents directory and loads it.
cp com.user.ramdisk.plist ~/Library/LaunchAgents/com.user.ramdisk.plist
# This will create a ramdisk at startup
launchctl load ~/Library/LaunchAgents/com.user.ramdisk.plist
