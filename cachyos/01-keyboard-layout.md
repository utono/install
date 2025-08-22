# Real Programmers Dvorak Keyboard Layout Setup

Configure the Real Programmers Dvorak (RPD) keyboard layout before and during CachyOS installation. This ensures consistent keyboard experience throughout the installation process.

## Why Configure This Early?

- **Installation Process**: Correct keyboard layout prevents typing errors during installation
- **Disk Encryption**: Proper layout needed for password entry if using encrypted drives
- **Early Boot**: Layout must be in initramfs for boot-time password prompts
- **Consistency**: Same layout experience from installation through daily use

## Phase 1: Live Boot Environment (Optional)

If you need RPD during the CachyOS installation process:

### Temporary Layout for Installation
```bash
# In the live environment (before installation)
# Use standard Dvorak as closest approximation
loadkeys dvorak

# Test the layout
echo "Test typing with new layout - pay attention to key positions"
```

### If RPD Files Are Available
```bash
# If you have access to the RPD files during installation
# (from mounted USB or network)
loadkeys /path/to/real_prog_dvorak.map
```

## Phase 2: Post-Installation Setup

After CachyOS is installed and you've restored your utono directory from USB backup:

### Prerequisites Check
```bash
# Ensure you're in the correct directory
cd "$HOME/utono/rpd"

# Verify the configuration script exists
ls -la keyd-configuration.sh

# Verify required files exist
ls -la kbd/usr/share/kbd/keymaps/i386/dvorak/real_prog_dvorak.map
ls -la xkb/usr/share/X11/xkb/symbols/real_prog_dvorak
ls -la etc/keyd/default.conf
```

### Run Configuration Script
```bash
# Make the script executable
chmod +x "$HOME/utono/rpd/keyd-configuration.sh"

# Run the configuration (requires sudo)
sudo bash keyd-configuration.sh "$HOME/utono/rpd"
```

### Apply Console Keyboard Layout
```bash
# Load the keyboard layout for current TTY session
sudo loadkeys real_prog_dvorak

# Regenerate initramfs to include new keymap for early boot
# This is critical for encrypted systems
sudo mkinitcpio -P

# Reload the keyboard layout to ensure it's active
sudo loadkeys real_prog_dvorak
```

### Restart Services and Reboot
```bash
# Restart keyd to apply new configuration
sudo systemctl restart keyd

# Reboot to ensure all changes take effect
sudo reboot
```

## What Gets Configured

The configuration script sets up multiple components:

| Component | Configuration File | Purpose |
|-----------|-------------------|---------|
| **KBD Console** | `/usr/share/kbd/keymaps/i386/dvorak/real_prog_dvorak.map.gz` | TTY keyboard layout |
| **vconsole** | `/etc/vconsole.conf` | System-wide console keymap setting |
| **XKB** | `/usr/share/X11/xkb/symbols/real_prog_dvorak` | GUI environment keyboard layout |
| **keyd** | `/etc/keyd/default.conf` | Advanced key remapping and home row mods |

## Verification After Reboot

### Check Services
```bash
# Check keyd service status
systemctl status keyd

# Verify keyd is enabled
systemctl is-enabled keyd
```

### Test in TTY
```bash
# Switch to TTY2 and test keyboard layout
# Ctrl + Alt + F2
# Verify key positions match RPD layout expectations
# Switch back: Ctrl + Alt + F1 (or F7)
```

### Configure for Hyprland
```bash
# Apply keyboard layout to Hyprland
hyprctl keyword input:kb_variant ""
hyprctl keyword input:kb_layout real_prog_dvorak

# Verify current Hyprland keyboard settings
hyprctl devices | grep -A 5 "Keyboard"
```

## Troubleshooting

### If Keyboard Layout Doesn't Work in TTY
```bash
# Check if keymap file exists
ls -la /usr/share/kbd/keymaps/i386/dvorak/real_prog_dvorak.map.gz

# Manually load the keymap
sudo loadkeys real_prog_dvorak

# Check vconsole configuration
cat /etc/vconsole.conf
```

### If keyd Service Fails
```bash
# Check service logs
journalctl -u keyd --no-pager

# Restart keyd
sudo systemctl restart keyd

# Check keyd configuration syntax
sudo keyd check
```

### If Hyprland Doesn't Recognize Layout
```bash
# Reload Hyprland configuration
hyprctl reload

# List available layouts
hyprctl devices

# Manually set the layout
hyprctl keyword input:kb_layout real_prog_dvorak
```

### If Early Boot Password Entry Fails
```bash
# Ensure initramfs was regenerated
sudo mkinitcpio -P

# Check that real_prog_dvorak is in the keymap list
sudo find /usr/share/kbd/keymaps -name "*real_prog_dvorak*"
```

## Key Features of RPD Layout

- **Programming optimized**: Numbers and symbols in convenient positions
- **Dvorak base**: Optimized letter placement for typing efficiency  
- **Home row modifiers**: When combined with keyd configuration
- **Consistent across environments**: TTY, X11, and Wayland

## Next Steps

After keyboard layout is configured:
1. Proceed to [02-cachyos-install.md](02-cachyos-install.md) for the actual CachyOS installation
2. The keyboard layout will be available during installation
3. Further system configuration will continue with the correct layout active

## Advanced Configuration

### Custom keyd Mappings
The keyd configuration provides advanced features like:
- **Home row modifiers**: asdf/jkl; keys act as modifiers when held
- **Caps Lock override**: Mapped to Escape
- **Space modifier**: Additional functionality when held

### Layout Switching
```bash
# If you need to switch between layouts temporarily
hyprctl switchxkblayout all next

# Add multiple layouts in Hyprland config
input {
    kb_layout = us,real_prog_dvorak
    kb_options = grp:alt_shift_toggle
}
```

This keyboard configuration ensures you have a consistent, optimized typing experience throughout the entire CachyOS setup process.
