#!/usr/bin/env bash

# This script syncs the 8BitDo MPV service file to /etc/systemd/system
# and manages the associated systemd service (reload, enable, and start).

set -uo pipefail

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Exiting."
    exit 1
fi

# Ensure rsync is available
if ! command -v rsync &> /dev/null; then
    echo "The 'rsync' command is required but not installed. Exiting."
    exit 1
fi

# Paths
SRC_FILE="$HOME/utono/install/system/8bitdo_zero_2_to_mpv/etc/systemd/system/8bitdo_zero_2_to_mpv.service"
DEST_FILE="/etc/systemd/system/8bitdo_zero_2_to_mpv.service"

# Function to sync the service file
sync_service_file() {
    if [ -f "$SRC_FILE" ]; then
        echo "Syncing service file..."
        rsync -av --chown=root:root "$SRC_FILE" "$DEST_FILE" || {
            echo "Failed to sync the service file."
            exit 1
        }
        echo "Service file synced successfully: $SRC_FILE -> $DEST_FILE"
    else
        echo "Source service file does not exist: $SRC_FILE"
        exit 1
    fi
}

# Function to reload systemd and enable the service
manage_service() {
    echo "Reloading systemd daemon..."
    systemctl daemon-reload || {
        echo "Failed to reload systemd daemon."
        exit 1
    }

    echo "Enabling and starting the service..."
    systemctl enable --now 8bitdo_zero_2_to_mpv.service || {
        echo "Failed to enable/start the service."
        exit 1
    }

    echo "Service enabled and started successfully."
}

# Main function
main() {
    sync_service_file
    manage_service
    echo "8BitDo MPV service has been synced and configured."
}

main "$@"
