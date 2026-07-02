# ramdisk-autocommit

Watches `/Volumes/RAMDisk` for file changes and, for any file that lives
inside a git repo, automatically stages, commits, and pushes it.

## Files

- `ramdisk-autocommit.sh` — the watcher script (uses `fswatch`)
- `com.ilya.ramdisk-autocommit.plist` — launchd agent so it runs in the
  background and starts on login
- `install.sh` — installs everything on macOS

## Install

```bash
chmod +x install.sh
./install.sh
```

This will:
1. Check for Homebrew (required) and install `fswatch` if missing
2. Copy `ramdisk-autocommit.sh` to `~/bin/`
3. Copy the launchd plist to `~/Library/LaunchAgents/`
4. Load the agent so it starts now and on every login

## How it works

For every filesystem write under `/Volumes/RAMDisk`:
1. Skip if the file isn't inside a git repo
2. Skip if there's nothing to commit
3. Build a commit message from the last line of the unstaged diff
   (falls back to `update <filename>` for brand-new files)
4. `git add -A -- <file>`, commit, push

Only the changed file is staged/committed — other pending changes in the
same repo are left alone.

## Logs

```bash
tail -f /tmp/ramdisk-autocommit.out.log
tail -f /tmp/ramdisk-autocommit.err.log
```

## Managing the background service

```bash
# stop
launchctl unload ~/Library/LaunchAgents/com.ilya.ramdisk-autocommit.plist

# start
launchctl load ~/Library/LaunchAgents/com.ilya.ramdisk-autocommit.plist

# restart (after editing the script)
launchctl unload ~/Library/LaunchAgents/com.ilya.ramdisk-autocommit.plist
launchctl load ~/Library/LaunchAgents/com.ilya.ramdisk-autocommit.plist
```

## Uninstall

```bash
launchctl unload ~/Library/LaunchAgents/com.ilya.ramdisk-autocommit.plist
rm ~/Library/LaunchAgents/com.ilya.ramdisk-autocommit.plist
rm ~/bin/ramdisk-autocommit.sh
```

## Notes / things to check before relying on this

- **RAMDisk is wiped on reboot.** If `git push` fails (network down, auth
  issue), the commit only exists locally — and disappears on reboot before
  you notice. Watch `/tmp/ramdisk-autocommit.err.log` for push failures.
- **Only tracked repos are touched.** A directory with no `.git` is
  silently skipped — this won't `git init` anything for you.
- **Secrets:** `git add -A -- <file>` only stages the one changed file, not
  the whole repo, but double-check `.gitignore` covers `.env` / `.env.op`
  files in any repo you rely on this for.
