# CachyOS Troubleshooting Guide

Comprehensive troubleshooting guide for common issues encountered during and after CachyOS installation.

## General Debugging Commands

### System Information
```bash
# Check system status
systemctl status

# View recent system logs
journalctl -xe

# Check failed services
systemctl --failed

# View boot messages
dmesg | less

# Check hardware info
inxi -Fazy

# Monitor system resources
htop
```

### Service Management
```bash
# Reload systemd configuration
systemctl daemon-reload
systemctl --user daemon-reload

# Reset failed services
systemctl --user reset-failed

# Check service dependencies
systemctl list-dependencies <service-name>
```

## Audio Issues

### Problem: No Audio or Only "auto_null" Sink

**Symptoms**:
- No sound output
- `pactl list short sinks` shows only `auto_null`
- PipeWire services running but no real audio devices

**Diagnosis**:
```bash
# Check PipeWire services
systemctl --user status pipewire pipewire-pulse wireplumber

# Check for SOF firmware loading
dmesg | grep -i sof

# Check audio hardware detection
lspci -nnk | grep -A3 audio
aplay -l
```

**Solutions**:
```bash
# Method 1: Hard reset PipeWire
cd ~/utono/system-config
chmod +x misc-md/fix-audio.sh
./misc-md/fix-audio.sh

# Method 2: Restore known-good SOF firmware
chmod +x misc-md/install-sof-from-backup.sh
sudo ./misc-md/install-sof-from-backup.sh
sudo reboot

# Method 3: Manual service restart
systemctl --user stop pipewire pipewire-pulse wireplumber
systemctl --user start pipewire pipewire-pulse wireplumber
```

### Problem: Audio Quality Issues

**Symptoms**:
- Crackling or choppy audio
- Audio dropouts
- Low volume

**Solutions**:
```bash
# Check sample rate settings
pactl list sinks | grep -E "(Sample|Format)"

# Adjust buffer sizes in PipeWire config
mkdir -p ~/.config/pipewire
cp /usr/share/pipewire/pipewire.conf ~/.config/pipewire/
vim ~/.config/pipewire/pipewire.conf

# Restart PipeWire after config changes
systemctl --user restart pipewire
```

### Problem: Microphone Not Working

**Solutions**:
```bash
# Check microphone hardware
arecord -l

# Test microphone recording
arecord -f cd -d 5 test.wav
aplay test.wav

# Check input levels in alsamixer
alsamixer
# Press F4 to switch to capture devices
```

## Keyboard Layout Issues

### Problem: RPD Layout Not Working in TTY

**Symptoms**:
- Keyboard layout reverts to QWERTY in console
- Wrong characters when typing

**Diagnosis**:
```bash
# Check current console keymap
cat /etc/vconsole.conf

# Check if RPD keymap file exists
ls -la /usr/share/kbd/keymaps/i386/dvorak/real_prog_dvorak.map.gz

# Check keyd service
systemctl status keyd
```

**Solutions**:
```bash
# Reload console keymap
sudo loadkeys real_prog_dvorak

# Regenerate initramfs
sudo mkinitcpio -P

# Restart keyd service
sudo systemctl restart keyd

# Reconfigure RPD if needed
cd ~/utono/rpd
sudo bash keyd-configuration.sh ~/utono/rpd
```

### Problem: Different Layout in GUI vs TTY

**Solutions**:
```bash
# Set Hyprland keyboard layout
hyprctl keyword input:kb_layout real_prog_dvorak

# Add to Hyprland config permanently
vim ~/.config/hypr/hyprland.conf
# Add: input { kb_layout = real_prog_dvorak }

# Reload Hyprland configuration
hyprctl reload
```

## Display and SDDM Issues

### Problem: SDDM Wrong Resolution

**Symptoms**:
- Login screen has wrong resolution
- Text appears too small or large

**Solutions**:
```bash
# Check Xsetup script
cat /usr/share/sddm/scripts/Xsetup

# Update Xsetup with correct resolution
sudo cp ~/utono/system-config/usr/share/sddm/scripts/Xsetup /usr/share/sddm/scripts/

# Restart SDDM
sudo systemctl restart sddm
```

### Problem: GRUB Wrong Resolution

**Solutions**:
```bash
# Check supported resolutions in GRUB
# Boot and press 'c' in GRUB menu, then run: videoinfo

# Edit GRUB configuration
sudo vim /etc/default/grub
# Set: GRUB_GFXMODE=1920x1200 (or your preferred resolution)

# Apply GRUB changes
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### Problem: Hyprland Won't Start

**Diagnosis**:
```bash
# Check Hyprland logs
journalctl --user -u hyprland

# Try starting Hyprland manually
Hyprland

# Check for conflicting processes
ps aux | grep -E "(X|wayland|hypr)"
```

**Solutions**:
```bash
# Reset Hyprland configuration
mv ~/.config/hypr ~/.config/hypr.backup
ln -sf ~/utono/cachyos-hyprland-settings/etc/skel/.config/hypr ~/.config/

# Restart display manager
sudo systemctl restart sddm

# Check script permissions
find ~/.config/hypr -name "*.sh" -exec chmod +x {} \;
```

## Gamepad and Input Issues

### Problem: Gamepad Not Detected

**Diagnosis**:
```bash
# Check Bluetooth status
systemctl status bluetooth
bluetoothctl devices Connected

# Check input devices
ls /dev/input/event*

# Monitor device events
sudo keyd monitor
```

**Solutions**:
```bash
# Restart Bluetooth
sudo systemctl restart bluetooth

# Re-pair gamepad
bluetoothctl
# power on, scan on, pair <MAC>, trust <MAC>, connect <MAC>

# Check input group membership
groups $USER | grep input
sudo usermod -aG input $USER
newgrp input
```

### Problem: Gamepad Service Fails

**Diagnosis**:
```bash
# Check service logs
journalctl --user -u nvim-micro-gamepad.service

# Check if device is grabbed by another process
ps aux | grep -E "(gamepad|evdev)"
```

**Solutions**:
```bash
# Restart gamepad service
systemctl --user restart nvim-micro-gamepad.service

# Kill conflicting processes
pkill -f nvim-micro-gamepad

# Check device permissions
ls -l /dev/input/event* | grep input
```

## Network and SSH Issues

### Problem: SSH Key Authentication Fails

**Solutions**:
```bash
# Check SSH key permissions
ls -la ~/.ssh/
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub

# Add key to SSH agent
eval $(ssh-agent)
ssh-add ~/.ssh/id_ed25519

# Test SSH connection
ssh -T git@github.com
```

### Problem: Git Operations Fail

**Solutions**:
```bash
# Check Git configuration
git config --global --list

# Check remote URLs
git remote -v

# Switch to SSH remotes
git remote set-url origin git@github.com:username/repo.git

# Check SSH agent
ssh-add -l
```

## Package Management Issues

### Problem: Package Installation Fails

**Solutions**:
```bash
# Update package databases
sudo pacman -Sy

# Clear package cache
sudo pacman -Scc

# Update keyring
sudo pacman -S archlinux-keyring
sudo pacman-key --populate archlinux

# Fix corrupted database
sudo rm /var/lib/pacman/db.lck
sudo pacman -Syu
```

### Problem: AUR Helper Issues

**Solutions**:
```bash
# Rebuild paru if needed
cd ~/Downloads
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

# Clear AUR cache
paru -Sc

# Check build dependencies
sudo pacman -S base-devel
```

## File System Issues

### Problem: Permission Denied Errors

**Solutions**:
```bash
# Check file ownership
ls -la <file>

# Fix ownership
sudo chown -R $USER:$USER <directory>

# Check file permissions
chmod 644 <file>  # For regular files
chmod 755 <directory>  # For directories
chmod 700 ~/.ssh  # For SSH directory
```

### Problem: Disk Space Issues

**Diagnosis**:
```bash
# Check disk usage
df -h

# Check large files
du -sh * | sort -h

# Check for journal logs taking space
journalctl --disk-usage
```

**Solutions**:
```bash
# Clean package cache
sudo pacman -Sc

# Clean journal logs
sudo journalctl --vacuum-time=1month

# Clean temporary files
sudo rm -rf /tmp/*
rm -rf ~/.cache/*
```

## Emergency Recovery

### Boot Issues

**Emergency Commands (if system won't boot)**:
```bash
# Magic SysRq combinations (Alt + SysRq + key):
# Alt + SysRq + r : Take keyboard control back
# Alt + SysRq + e : Send SIGTERM to all processes
# Alt + SysRq + i : Send SIGKILL to all processes  
# Alt + SysRq + s : Sync all mounted filesystems
# Alt + SysRq + u : Remount filesystems read-only
# Alt + SysRq + b : Immediately reboot

# Remember: "REISUB" - Reboot Even If System Utterly Broken
```

### Chroot Recovery

**From live USB**:
```bash
# Mount root partition
mount /dev/sdXY /mnt

# Mount EFI partition (if using UEFI)
mount /dev/sdX1 /mnt/boot

# Chroot into system
arch-chroot /mnt

# Fix issues, then exit and reboot
exit
reboot
```

## Common Service Fixes

### Reset All User Services
```bash
# Stop all user services
systemctl --user stop --all

# Reload configuration
systemctl --user daemon-reload

# Start essential services
systemctl --user start pipewire pipewire-pulse wireplumber
```

### Check Resource Usage
```bash
# Check memory usage
free -h

# Check CPU usage
top

# Check disk I/O
iotop

# Check network
ss -tulpn
```

## Log Analysis

### Important Log Locations
```bash
# System logs
journalctl -xe

# User service logs
journalctl --user -xe

# Specific service logs
journalctl -u <service-name>

# Boot logs
journalctl -b

# Follow logs in real-time
journalctl -f
```

### Common Log Patterns
```bash
# Audio issues
journalctl | grep -E "(pipewire|wireplumber|sof|alsa)"

# Graphics issues  
journalctl | grep -E "(drm|gpu|nvidia|intel)"

# Bluetooth issues
journalctl | grep -E "(bluetooth|hci)"
```

## Getting More Help

### Information to Collect
When seeking help, gather:
```bash
# System information
inxi -Fazy > system-info.txt

# Service status
systemctl --failed > failed-services.txt

# Recent logs
journalctl -xe > recent-logs.txt

# Hardware info
lspci > hardware.txt
lsusb >> hardware.txt
```

### Useful Resources
- [Arch Wiki](https://wiki.archlinux.org/)
- [CachyOS Documentation](https://wiki.cachyos.org/)
- `man` pages for specific commands
- IRC: #archlinux on Libera.Chat
- Forums: Arch Linux and CachyOS community forums

Remember: Most issues can be resolved by checking logs, restarting services, and ensuring proper permissions. When in doubt, reboot and check if the issue persists.
