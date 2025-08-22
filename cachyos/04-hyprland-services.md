# Hyprland and Services Configuration

## Configure Hyprland

### Link CachyOS Hyprland Settings

```bash
sh "$HOME/utono/user-config/link-cachyos-hyprland-settings.sh" 2>&1 | tee link-hyprland-output.out
```

### Optional: Configure Git Repository

Set up git remotes for the Hyprland settings repository:

```bash
cd $HOME/utono/cachyos-hyprland-settings  
git branch -r  
git remote -v

# Optional: Switch to SSH remote
# git remote set-url origin git@github.com:utono/cachyos-hyprland-settings.git

# Add upstream remote for syncing with CachyOS
git remote add upstream git@github.com:CachyOS/cachyos-hyprland-settings.git
git branch -r  
git fetch upstream  

# Merge upstream changes (if needed)
git merge upstream/master --allow-unrelated-histories  
# git add <file_with_conflicts_removed>  
# git commit  
```

### Configure Hyprland Scripts

```bash
# Edit main Hyprland configuration
vim ~/.config/hypr/hyprland.conf

# Make scripts executable
cd ~/.config/hypr/bin
chmod +x *.sh

cd ~/.config/hypr/scripts/
chmod +x *

reboot
```

## Configure Systemd User Services

### Setup Service Permissions

```bash
# Reload systemd user units (required if you've changed service files)
systemctl --user daemon-reexec
systemctl --user daemon-reload

# Make all shell scripts executable
fd -e sh -H -x chmod -v +x {} ~/tty-dotfiles
```

### Configure Clipboard Watcher Service

```bash
# Enable and start the clipboard watcher service
systemctl --user enable --now watch-clipboard.service

# Restart the service
systemctl --user restart watch-clipboard.service

# Check status
systemctl --user status watch-clipboard.service
```

### Additional Service Management Commands

```bash
# View service logs
journalctl --user -u watch-clipboard.service -f

# Stop a service
systemctl --user stop watch-clipboard.service

# Disable a service
systemctl --user disable watch-clipboard.service

# List all user services
systemctl --user list-units --type=service
```

## Firefox Configuration

Open Firefox and navigate to `about:config`, then modify:

```
browser.gesture.pinch.threshold = 50
```

This adjusts the pinch gesture sensitivity for better touchpad experience.

## Troubleshooting

### Hyprland Issues

If Hyprland doesn't start properly:

```bash
# Check Hyprland logs
journalctl --user -u hyprland

# Restart the display manager
sudo systemctl restart sddm
```

### Service Issues

If systemd user services fail:

```bash
# Check service status
systemctl --user status <service-name>

# View detailed logs
journalctl --user -u <service-name> --no-pager

# Reset failed services
systemctl --user reset-failed
```

### Script Permission Issues

If scripts aren't executing:

```bash
# Fix permissions recursively
find ~/.config/hypr -name "*.sh" -exec chmod +x {} \;
find ~/tty-dotfiles -name "*.sh" -exec chmod +x {} \;
```
