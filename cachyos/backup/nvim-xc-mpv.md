# nvim-xc-mpv.md

# Literature Backup Service Configuration Guide

This guide explains how to set up automated backup and git synchronization for your nvim-mpv glossing system.

## Overview

The backup system consists of two components:
- **backup-literature.sh**: Script that backs up your gloss database and syncs to git
- **backup-literature.service**: Systemd service that runs the script automatically every 30 minutes

## Prerequisites

Before setting up the service, ensure you have:

- SQLite gloss database at `~/.local/share/nvim-xc/gloss.db`
- Git repository initialized at `~/utono/literature/`
- Remote git repository configured (e.g., GitHub)
- `sqlite3` command available on your system

```bash
# Verify prerequisites
ls ~/.local/share/nvim-xc/gloss.db
ls ~/utono/literature/.git
which sqlite3
```

## Installation

### 1. Create the Backup Script

Create the directory structure and place the script:

```bash
# Create script directory
mkdir -p ~/.local/bin/bin-mlj/nvim

# Place the backup-literature.sh script in this directory
# (Copy the script content to ~/.local/bin/bin-mlj/nvim/backup-literature.sh)

# Make it executable
chmod +x ~/.local/bin/bin-mlj/nvim/backup-literature.sh
```

### 2. Create Systemd Service Files

Create the systemd user directory and service files:

```bash
# Create systemd user directory
mkdir -p ~/.config/systemd/user

# Place both service files:
# - backup-literature.service
# - backup-literature.timer
# in ~/.config/systemd/user/
```

### 3. Enable and Start the Service

```bash
# Reload systemd configuration to pick up new/changed files
systemctl --user daemon-reload

# Validate the service file (optional but recommended)
# This checks syntax without starting the service
systemctl --user status backup-literature.service

# Enable the timer (starts automatically on login)
systemctl --user enable backup-literature.timer

# Start the timer immediately
systemctl --user start backup-literature.timer

# Verify timer is active and see next run time
systemctl --user list-timers backup-literature.timer
```

**Note:** It's unnecessary to start `backup-literature.service` before starting the timer, as the timer will automatically trigger the service when scheduled. However, it's good practice to validate the service file first with `systemctl --user status backup-literature.service` to catch any configuration errors early.

## Service Management

### Starting and Stopping

```bash
# Start the timer
systemctl --user start backup-literature.timer

# Stop the timer
systemctl --user stop backup-literature.timer

# Restart the timer
systemctl --user restart backup-literature.timer

# Run the backup immediately (one-time)
systemctl --user start backup-literature.service
```

### Status and Monitoring

```bash
# Check timer status and next run time
systemctl --user status backup-literature.timer

# List all active timers with next run times
systemctl --user list-timers

# List only your backup timer with detailed timing info
systemctl --user list-timers backup-literature.timer

# See all timers (including inactive ones)
systemctl --user list-timers --all

# Quick check if timer is active
systemctl --user is-active backup-literature.timer

# Quick check if timer is enabled
systemctl --user is-enabled backup-literature.timer

# Check service status
systemctl --user status backup-literature.service

# View recent service logs
journalctl --user -u backup-literature.service

# Follow logs in real-time
journalctl --user -u backup-literature.service -f

# View script's own log file
tail -f ~/.local/share/backup-literature.log
```

**Expected timer output when running properly:**
```
● backup-literature.timer - Run backup-literature service every 30 minutes
     Loaded: loaded (/home/mlj/.config/systemd/user/backup-literature.timer; enabled; preset: enabled)
     Active: active (waiting) since Thu 2025-08-07 10:49:07 CDT; 5min ago
    Trigger: Thu 2025-08-07 11:00:27 CDT; 6min left
   Triggers: ● backup-literature.service
```

**Key indicators:**
- **Active: active (waiting)** = Timer is running and waiting for next trigger
- **Trigger:** = Shows exact time of next run
- **LEFT:** = How much time until next run in `list-timers` output
- **LAST:** = When it last ran (shows "-" if never run)

### Disabling the Service

```bash
# Stop and disable the timer
systemctl --user stop backup-literature.timer
systemctl --user disable backup-literature.timer
```

## Configuration

### Modifying the Schedule

The service runs every 30 minutes by default. To change this, edit `~/.config/systemd/user/backup-literature.timer`:

```ini
[Timer]
# Run every hour instead of every 30 minutes
OnCalendar=hourly

# Or run daily at 2 AM
OnCalendar=daily
OnCalendar=*-*-* 02:00:00

# Or run every 15 minutes
OnCalendar=*:0/15
```

After modifying the timer:
```bash
systemctl --user daemon-reload
systemctl --user restart backup-literature.timer
```

### Customizing Paths

To change the default paths, edit the Configuration section in `backup-literature.sh`:

```bash
# Default configuration
GLOSS_DB="$HOME/.local/share/nvim-xc/gloss.db"
LITERATURE_DIR="$HOME/utono/literature"
BACKUP_DB="$LITERATURE_DIR/gloss.db"
LOG_FILE="$HOME/.local/share/backup-literature.log"
```

## Verification and Testing

### Verify Timer Operation

Check that the timer is properly configured and running:

```bash
# Verify timer is active and see next scheduled run
systemctl --user status backup-literature.timer
systemctl --user list-timers backup-literature.timer

# Quick status checks
systemctl --user is-active backup-literature.timer
systemctl --user is-enabled backup-literature.timer

# Check when the service last ran and its result
systemctl --user status backup-literature.service

# View complete execution history
journalctl --user -u backup-literature.service --since "1 day ago"
```

The `is-active` command should return `active` and `is-enabled` should return `enabled` for a properly running timer.

### Verify Last Script Execution

Check what operations were performed by the most recent backup:

```bash
# View recent service logs with timestamps
journalctl --user -u backup-literature.service --since "2 hours ago" --no-pager

# Check the script's own detailed log
tail -20 ~/.local/share/backup-literature.log

# See recent git commits in your literature repository
cd ~/utono/literature
git log --oneline -5

# Check git status for any uncommitted changes
git status

# Verify database backup exists and check its timestamp
ls -la ~/utono/literature/gloss.db
stat ~/utono/literature/gloss.db

# Compare source and backup database timestamps
ls -la ~/.local/share/nvim-xc/gloss.db ~/utono/literature/gloss.db
```

### Verify Database Backup Integrity

Ensure the backup database is valid and current:

```bash
# Check database integrity
sqlite3 ~/utono/literature/gloss.db "PRAGMA integrity_check;"

# Compare gloss counts between source and backup
sqlite3 ~/.local/share/nvim-xc/gloss.db "SELECT COUNT(*) as total_glosses FROM glosses;"
sqlite3 ~/utono/literature/gloss.db "SELECT COUNT(*) as total_glosses FROM glosses;"

# Check most recent entries in backup database
sqlite3 ~/utono/literature/gloss.db "SELECT timestamp, tag, substr(source_text, 1, 50) as excerpt FROM glosses ORDER BY timestamp DESC LIMIT 5;"
```

### Interpret Service Status

**Successful execution indicators:**
- Service status shows `Active: inactive (dead)` with `status=0/SUCCESS`
- Log messages include "Backup and sync completed successfully"
- Recent git commits in your literature repository
- Backup database timestamp matches or is newer than source database

**Common log messages and their meanings:**
```
"No database changes to commit" = Database unchanged since last backup
"Database has changes, committing..." = New glosses found and committed
"Successfully pushed to remote" = Git sync completed successfully  
"WARNING: Failed to push to remote" = Network/authentication issue, will retry next time
```

### Manual Test Execution

Test the backup process manually:

```bash
# Run the service once manually
systemctl --user start backup-literature.service

# Monitor the execution in real-time
journalctl --user -u backup-literature.service -f

# Check results immediately after
systemctl --user status backup-literature.service
tail -5 ~/.local/share/backup-literature.log
```

### Common Issues

**Service fails to start:**
```bash
# Check for syntax errors in service files
systemctl --user status backup-literature.service
journalctl --user -u backup-literature.service
```

**Script permission denied:**
```bash
# Ensure script is executable
chmod +x ~/.local/bin/bin-mlj/nvim/backup-literature.sh
```

**Git push fails:**
```bash
# Check git remote configuration
cd ~/utono/literature
git remote -v
git push origin main  # Test manually
```

**Database not found:**
```bash
# Verify database exists and check path
ls -la ~/.local/share/nvim-xc/gloss.db
```

### Manual Testing

Test the script manually before enabling the service:

```bash
# First, validate the service configuration
systemctl --user daemon-reload
systemctl --user status backup-literature.service

# Run the script directly to test functionality
~/.local/bin/bin-mlj/nvim/backup-literature.sh

# Or test via systemd service (optional)
systemctl --user start backup-literature.service

# Check the log output
tail ~/.local/share/backup-literature.log
```

### Logs and Debugging

Monitor different log sources:

```bash
# Script's own log file
tail -f ~/.local/share/backup-literature.log

# Systemd service logs
journalctl --user -u backup-literature.service -f

# Timer logs
journalctl --user -u backup-literature.timer -f

# All logs for the service
journalctl --user -u backup-literature.* -f
```

## File Locations Summary

```
~/.local/bin/bin-mlj/nvim/backup-literature.sh        # Main backup script
~/.config/systemd/user/backup-literature.service     # Systemd service
~/.config/systemd/user/backup-literature.timer       # Systemd timer
~/.local/share/backup-literature.log                  # Script log file
~/.local/share/nvim-xc/gloss.db                      # Source database
~/utono/literature/gloss.db                          # Backup database
~/utono/literature/.git/                             # Git repository
```

## SSH Key Configuration for Git Push

If your git repository uses SSH authentication (git@github.com URLs), you'll need to configure SSH key access for systemd services.

### Using System SSH Agent Service

Most modern Linux distributions include a system SSH agent service. Check if it's available and enable it:

```bash
# Check if SSH agent service exists and its status
systemctl --user status ssh-agent.service
systemctl --user status ssh-agent.socket

# If not enabled, enable both the service and socket
systemctl --user enable ssh-agent.service ssh-agent.socket

# Start the SSH agent
systemctl --user start ssh-agent.service

# Verify both are running
systemctl --user status ssh-agent.service ssh-agent.socket
```

**Update your backup service to use SSH agent:**

Ensure your `~/.config/systemd/user/backup-literature.service` includes SSH agent dependency and environment:

```ini
[Unit]
Description=Backup gloss database and sync literature repository
After=network-online.target ssh-agent.service
Wants=network-online.target
Requires=ssh-agent.service

[Service]
Type=oneshot
ExecStart=%h/.local/bin/bin-mlj/nvim/backup-literature.sh
Environment=HOME=%h
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
StandardOutput=journal
StandardError=journal

# Restart policy for failed attempts
Restart=on-failure
RestartSec=300

# Timeout settings
TimeoutStartSec=300
TimeoutStopSec=30

[Install]
WantedBy=default.target
```

**Configure SSH authentication:**

```bash
# Set SSH_AUTH_SOCK in your current session
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# Add your SSH key to the agent (use your actual key file)
ssh-add ~/.ssh/id_ed25519  # or ~/.ssh/id_rsa, etc.

# Enter your passphrase when prompted

# Verify key is loaded
ssh-add -l

# Test git connection
cd ~/utono/literature
ssh -T git@github.com
# Should show: "Hi username! You've successfully authenticated..."

# Update the backup service configuration
systemctl --user daemon-reload
systemctl --user restart backup-literature.timer

# Test the service
systemctl --user start backup-literature.service

# Verify it worked
systemctl --user status backup-literature.service
```

**Make SSH_AUTH_SOCK persistent (optional):**

Add to your shell configuration (`~/.bashrc` or `~/.zshrc`) to make the environment variable available in all sessions:
```bash
# Set SSH_AUTH_SOCK for systemd user services
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
```

### Alternative: HTTPS Authentication

If you prefer HTTPS over SSH, you can configure git to use a personal access token:

```bash
cd ~/utono/literature

# Change remote to HTTPS
git remote set-url origin https://github.com/username/repository.git

# Configure git to use credential helper
git config credential.helper store

# Do one manual push to save credentials
git push origin main
# Enter your GitHub username and personal access token when prompted
```

### Email Notifications on Failure

Add email notification by modifying the service file:

```ini
[Service]
# Add after ExecStart
OnFailure=status-email-user@%i.service
```

### Running on System Boot

To start the timer automatically when the system boots (not just user login):

```bash
# Enable lingering for your user
sudo loginctl enable-linger $USER

# The timer will now start at system boot
```
