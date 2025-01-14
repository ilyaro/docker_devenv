# Create the LaunchAgents directory if it doesn't exist
mkdir -p ~/Library/LaunchAgents

# Create the plist file
vi ~/Library/LaunchAgents/com.user.bash_aliases_process_and_push.plist
# (paste the XML content here)

# Set correct permissions
chmod 644 ~/Library/LaunchAgents/com.user.bash_aliases_process_and_push.plist

# Load the job
launchctl load ~/Library/LaunchAgents/com.user.bash_aliases_process_and_push.plist

# To check if it's loaded:
launchctl list | grep bash_aliases_process_and_push

# To unload if needed:
# launchctl unload ~/Library/LaunchAgents/com.user.bash_aliases_process_and_push.plist

# To test the script manually:
~/scripts/process_and_push_bash_aliases.sh
