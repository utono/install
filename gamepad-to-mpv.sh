#!/usr/bin/env bash

set -e

USER_HOME=$(eval echo ~$USER)
MPV_CONFIG_DIR="$USER_HOME/.config/mpv"
MPV_SCRIPT_DIR="$MPV_CONFIG_DIR/scripts"
SYSTEMD_USER_DIR="$USER_HOME/.config/systemd/user"
DEVICE_PATH="/dev/input/event19"
MPV_SOCKET="/tmp/mpvsocket"
SERVICE_SOURCE="$USER_HOME/tty-dotfiles/systemd/.config/systemd/user/gamepad_to_mpv.service"
SERVICE_DEST="$SYSTEMD_USER_DIR/gamepad_to_mpv.service"

# Install required packages
sudo pacman -S --needed python-evdev socat evtest

# Ensure MPV configuration directory exists
mkdir -p "$MPV_CONFIG_DIR"

# Enable MPV's IPC server
if ! grep -q "input-ipc-server=$MPV_SOCKET" "$MPV_CONFIG_DIR/mpv.conf" 2>/dev/null; then
    echo "input-ipc-server=$MPV_SOCKET" >> "$MPV_CONFIG_DIR/mpv.conf"
fi

# Ensure systemd user directory exists
mkdir -p "$SYSTEMD_USER_DIR"

# Create symlink to systemd service file
if [ ! -L "$SERVICE_DEST" ]; then
    ln -s "$SERVICE_SOURCE" "$SERVICE_DEST"
    echo "Symlink created for systemd service file."
else
    echo "Symlink already exists."
fi

# Reload systemd and enable the service
systemctl --user daemon-reload
systemctl --user enable --now gamepad_to_mpv.service

# Check status
systemctl --user status gamepad_to_mpv.service

echo "Configuration complete. Gamepad input is now mapped to MPV commands."
