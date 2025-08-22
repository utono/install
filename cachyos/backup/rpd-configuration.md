# Real Programmers Dvorak Keyboard Configuration

This guide configures the Real Programmers Dvorak (RPD) keyboard layout using keyd, KBD console keymap, and XKB for GUI environments.

## Prerequisites

```bash
# Ensure you're in the correct directory
cd "$HOME/utono/rpd"

# Verify the configuration script exists
ls -la keyd-configuration.sh
```

## Configuration Steps

### 1. Run the Configuration Script

```bash
# Make the script executable
chmod +x "$HOME/utono/rpd/keyd-configuration.sh"

# Run the configuration (requires sudo)
bash "$HOME/utono/rpd/keyd-configuration.sh" "$HOME/utono/rpd"
```

**What this script does:**
- Syncs custom KBD keyboard layout to `/usr/share/kbd/keymaps/i386/dvorak/`
- Updates `/etc/vconsole.conf` with `KEYMAP=real_prog_dvorak`
- Syncs XKB keyboard layout to `/usr/share/X11/xkb/symbols/`
- Configures keyd service with custom key mappings
- Links keyd configuration and enables the service

### 2. Apply Console Keyboard Layout

```bash
# Load the keyboard layout for current TTY session
sudo loadkeys real_prog_dvorak

# Regenerate initramfs to include new keymap for early boot
sudo mkinitcpio -P

# Reload the keyboard layout (ensuring it's active)
sudo loadkeys real_prog_dvorak
```

### 3. Restart Services and Reboot

```bash
# Restart keyd to apply new configuration
sudo systemctl restart keyd

# Reboot to ensure all changes take effect
reboot
```

## Post-Configuration Verification

After reboot, verify the configuration:

```bash
# Check keyd service status
systemctl status keyd

# Test keyboard layout in TTY
# (Keys should match Real Programmers Dvorak layout)

# For Hyprland, apply keyboard settings
hyprctl keyword input:kb_variant ""
hyprctl keyword input:kb_layout real_prog_dvorak
```

## Optional: Configure Git Remote (if needed)

If you cloned via HTTPS and want to switch to SSH:

```bash
cd "$HOME/utono/rpd"

# Check current remote
git remote -v

# Switch to SSH remote for easier pushing
git remote set-url origin git@github.com:utono/rpd.git

# Verify the change
git remote -v
# Should show:
#   origin  git@github.com:utono/rpd.git (fetch)
#   origin  git@github.com:utono/rpd.git (push)
```

## Troubleshooting

### If keyboard layout doesn't work in TTY:
```bash
# Check if keymap file exists
ls -la /usr/share/kbd/keymaps/i386/dvorak/real_prog_dvorak.map.gz

# Manually load the keymap
sudo loadkeys real_prog_dvorak
```

### If keyd service fails:
```bash
# Check service logs
journalctl -u keyd --no-pager

# Restart keyd
sudo systemctl restart keyd
```

### If Hyprland doesn't recognize the layout:
```bash
# Reload Hyprland configuration
hyprctl reload

# Or manually set the layout
hyprctl keyword input:kb_layout real_prog_dvorak
```

## What Gets Configured

| Component | Configuration File | Purpose |
|-----------|-------------------|---------|
| **KBD Console** | `/usr/share/kbd/keymaps/i386/dvorak/real_prog_dvorak.map.gz` | TTY keyboard layout |
| **vconsole** | `/etc/vconsole.conf` | System-wide console keymap setting |
| **XKB** | `/usr/share/X11/xkb/symbols/real_prog_dvorak` | GUI environment keyboard layout |
| **keyd** | `/etc/keyd/default.conf` | Advanced key remapping and home row mods |

## Notes

- **vconsole.conf** affects TTY (console) environments
- **XKB** affects GUI environments like Hyprland
- **keyd** provides advanced features like home row modifiers
- The `mkinitcpio -P` step ensures the keyboard layout works during early boot (important for encrypted systems)
