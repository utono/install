# Gamepad Setup for CachyOS

Configure gaming peripherals, particularly the 8BitDo Micro gamepad, for use with MPV media player and other applications.

## Overview

This guide covers:
- Bluetooth gamepad pairing and connection
- 8BitDo Micro gamepad configuration for MPV
- Device permissions and udev rules
- Systemd service automation
- Troubleshooting gamepad issues

## Prerequisites

### Install Required Packages
```bash
# Core gamepad and Bluetooth support
sudo pacman -S bluez bluez-utils

# Input device tools
sudo pacman -S evtest python-evdev python-psutil socat

# Optional gaming utilities
sudo pacman -S antimicrox joystick
```

### Enable Bluetooth Service
```bash
# Enable and start Bluetooth
sudo systemctl enable --now bluetooth.service

# Check Bluetooth status
systemctl status bluetooth.service
```

## Gamepad Connection

### Pair 8BitDo Micro Gamepad

#### Method 1: Using bluetoothctl
```bash
# Start Bluetooth controller
sudo bluetoothctl

# In bluetoothctl prompt:
power on
agent on
default-agent
scan on

# Look for device: "8BitDo Micro gamepad"
# Note the MAC address (e.g., E4:17:D8:91:A0:98)

# Pair the device
pair E4:17:D8:91:A0:98
trust E4:17:D8:91:A0:98
connect E4:17:D8:91:A0:98

# Exit bluetoothctl
quit
```

#### Method 2: Using bluetuith (Alternative)
```bash
# Install bluetuith for GUI management
paru -S bluetuith

# Run bluetuith
bluetuith

# Use GUI to pair and connect gamepad
```

### Verify Connection
```bash
# Check connected devices
bluetoothctl devices Connected

# Monitor device connection
sudo keyd monitor

# Expected output when gamepad connects:
# device added: 2dc8:9021:27abd54c 8BitDo Micro gamepad Keyboard (/dev/input/eventX)
```

## Device Detection and Permissions

### Identify Gamepad Device
```bash
# List input devices
cat /proc/bus/input/devices | grep -A 10 "8BitDo"

# Test gamepad input
sudo evtest /dev/input/eventX  # Replace X with actual event number

# Check device properties
udevadm info --attribute-walk --name=/dev/input/eventX | grep -E "ATTRS{id/vendor}|ATTRS{id/product}"

# Expected values for 8BitDo Micro:
# ATTRS{id/vendor}=="2dc8"
# ATTRS{id/product}=="9021"
```

### Configure Device Permissions

#### Create Udev Rule
```bash
# Copy the gamepad udev rule
sudo cp ~/utono/system-config/etc/udev/rules.d/99-gamepad.rules /etc/udev/rules.d/

# Verify rule content
cat /etc/udev/rules.d/99-gamepad.rules
```

The rule should contain:
```udev
SUBSYSTEM=="input", ATTRS{id/vendor}=="2dc8", ATTRS{id/product}=="9021", GROUP="input", MODE="0660"
SUBSYSTEM=="input", ATTRS{id/vendor}=="2dc8", ATTRS{id/product}=="9021", ENV{ID_INPUT_KEYBOARD}="1", ENV{ID_INPUT_JOYSTICK}="1"
```

#### Apply Udev Rules
```bash
# Turn off gamepad
# Reload udev rules
sudo udevadm control --reload-rules
sudo udevadm trigger

# Turn on gamepad
# Check device permissions
ls -l /dev/input/event*
# Should show: crw-rw---- with input group
```

### Add User to Input Group
```bash
# Check current groups
groups $USER

# Add user to input group if not already member
sudo usermod -aG input $USER

# Apply group changes (logout/login or use newgrp)
newgrp input

# Verify group membership
groups $USER | grep input
```

## MPV Integration

### Configure MPV for Gamepad Control

#### Enable MPV IPC Server
```bash
# Edit MPV configuration
vim ~/.config/mpv/mpv.conf

# Add IPC server line:
# input-ipc-server=/tmp/mpvsocket
```

#### Set Socket Permissions
```bash
# Start MPV to create socket
mpv /path/to/any/video/file.mp4

# In another terminal, set socket permissions
chmod 666 /tmp/mpvsocket

# Verify socket exists
ls -l /tmp/mpvsocket
# Should show: srw-rw-rw- 
```

### Install Gamepad Control Script
```bash
# Navigate to gamepad scripts
cd ~/tty-dotfiles/bin-mlj/.local/bin/bin-mlj/gamepad

# Make scripts executable
chmod +x *.py *.sh

# Test the gamepad script manually
python3 nvim-micro-gamepad.py
```

## Systemd Service Automation

### Install Service Files
```bash
# Link systemd service files
cd ~/tty-dotfiles
stow --verbose --no-folding systemd

# Verify service files are linked
ls -la ~/.config/systemd/user/*gamepad*
```

### Configure Services

#### Main Gamepad Service
```bash
# Reload systemd configuration
systemctl --user daemon-reload

# Enable and start the gamepad service
systemctl --user enable --now nvim-micro-gamepad.service

# Check service status
systemctl --user status nvim-micro-gamepad.service
```

#### Optional: MPV Auto-Activation
```bash
# Enable path-based activation (starts service when MPV socket appears)
systemctl --user enable --now nvim-micro-gamepad.path

# Enable cleanup timer (stops service when MPV closes)
systemctl --user enable --now nvim-micro-gamepad-stop.timer

# Check timer status
systemctl --user list-timers nvim-micro-gamepad-stop.timer
```

## Gamepad Controls for MPV

### Control Mapping

The 8BitDo Micro gamepad controls MPV with these mappings:

| Gamepad Button | Key Code | MPV Function |
|----------------|----------|--------------|
| L Button | `KEY_K` | (Reserved) |
| L2 Button | `KEY_L` | Show progress |
| R Button | `KEY_M` | Toggle dynamic chapter loop |
| R2 Button | `KEY_R` | Play/pause |
| A Button | `KEY_G` | Remove chapter |
| B Button | `KEY_J` | Next chapter |
| X Button | `KEY_H` | Previous chapter |
| Y Button | `KEY_I` | Add chapter from Neovim line |
| Select (-) | `KEY_N` | Nudge chapter later |
| Start (+) | `KEY_O` | Nudge chapter earlier |
| Home | `KEY_S` | Play/pause |
| D-pad Up | `KEY_C` | Volume up |
| D-pad Down | `KEY_D` | Volume down |
| D-pad Left | `KEY_E` | Seek backward 5s |
| D-pad Right | `KEY_F` | Seek forward 5s |

### Test Gamepad Controls
```bash
# Start MPV with a video file
mpv your_video_file.mkv

# In another terminal, test manual commands
echo '{ "command": ["cycle", "pause"] }' | socat - /tmp/mpvsocket

# Check gamepad service logs
journalctl --user -u nvim-micro-gamepad.service -f

# Test gamepad button presses and verify MPV responds
```

## Neovim Integration

### Configure Neovim for Chapter Creation
```bash
# Start Neovim with socket (for chapter title extraction)
nvim --listen /tmp/nvim.sock

# Or use the nvim-listen wrapper
chmod +x ~/.local/bin/bin-mlj/nvim/nvim-listen
alias on="nvim-listen"

# Test chapter creation from Neovim line
# Press gamepad Y button while cursor is on a line in Neovim
# Line content should be added as MPV chapter title
```

## Troubleshooting

### Gamepad Not Detected
```bash
# Check Bluetooth connection
bluetoothctl devices Connected

# Check input devices
ls /dev/input/event*

# Monitor device addition
sudo keyd monitor

# Check for permission issues
ls -l /dev/input/event* | grep $(whoami)
```

### Service Failures
```bash
# Check service logs
journalctl --user -u nvim-micro-gamepad.service --no-pager

# Restart service
systemctl --user restart nvim-micro-gamepad.service

# Check for device grab conflicts
ps aux | grep gamepad

# Kill conflicting processes
pkill -f nvim-micro-gamepad
```

### MPV Not Responding
```bash
# Check MPV socket
ls -l /tmp/mpvsocket

# Test socket manually
echo '{ "command": ["get_property", "playback-time"] }' | socat - /tmp/mpvsocket

# Restart MPV with IPC
mpv --input-ipc-server=/tmp/mpvsocket your_video.mp4
```

### Permission Denied Errors
```bash
# Check input group membership
groups $USER | grep input

# Re-add to input group if needed
sudo usermod -aG input $USER
newgrp input

# Check udev rule application
udevadm info --query=property --name=/dev/input/eventX | grep ID_INPUT
```

## Advanced Configuration

### Custom Key Mappings
Edit the gamepad script to customize controls:
```bash
vim ~/.local/bin/bin-mlj/gamepad/nvim-micro-gamepad.py

# Modify the key_map dictionary to change button functions
```

### Multiple Device Support
```bash
# Add additional device rules to udev
sudo vim /etc/udev/rules.d/99-gamepad.rules

# Add rules for other gamepads with different vendor/product IDs
```

### Auto-Connection Script
```bash
# Create script to auto-connect known gamepads
vim ~/.local/bin/bin-mlj/gamepad/auto-connect-gamepad.sh

# Add to startup or create systemd service for auto-connection
```

## Testing and Verification

### Complete Gamepad Test
```bash
echo "=== Gamepad System Test ==="

echo "1. Checking Bluetooth status..."
systemctl is-active bluetooth

echo "2. Checking connected gamepads..."
bluetoothctl devices Connected | grep gamepad

echo "3. Checking input devices..."
ls /dev/input/event* | wc -l

echo "4. Checking gamepad service..."
systemctl --user is-active nvim-micro-gamepad.service

echo "5. Checking MPV socket..."
ls -l /tmp/mpvsocket 2>/dev/null && echo "MPV socket ready" || echo "Start MPV first"

echo "6. Testing device permissions..."
groups | grep input && echo "Input group OK" || echo "Add user to input group"

echo "Gamepad test complete!"
```

This gamepad setup provides seamless integration between gaming controllers and media playback, enabling convenient control of MPV without traditional keyboard input.
