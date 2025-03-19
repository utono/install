#!/usr/bin/env bash

# Setup Utono Script
# ------------------
# This script automates the setup of an Arch Linux system with specific 
# configurations and packages. It performs the following:
# - Updates package mirrors and installs necessary packages
# - Mounts a USB drive and synchronizes files to the home directory
# - Configures the keyboard layout and key remapping
# - Runs the initial package installation from a predefined list
# - Applies dotfile configurations using GNU Stow
# - Ensures the correct shell and user settings are applied
#
# Usage:
# Run this script in a Bash shell:
#   ./setup_utono.sh
# Ensure that dependencies like udisksctl and rsync are installed.

set -e  # Exit immediately if any command exits with a non-zero status
set -u  # Treat unset variables as an error
set -o pipefail  # Ensure errors in piped commands are not masked

# Update package mirrors for better performance
# cachyos-rate-mirrors

# Install udisks2 and required utilities
pacman -Syy --needed udisks2 rsync stow

# Check if /dev/sda is already mounted
MOUNT_POINT=$(lsblk -o MOUNTPOINT -nr /dev/sda)
if [[ -z "$MOUNT_POINT" ]]; then
    echo "Attempting to mount /dev/sda..."
    if udisksctl mount -b /dev/sda; then
        MOUNT_POINT=$(lsblk -o MOUNTPOINT -nr /dev/sda)
    else
        echo "Error: Failed to mount /dev/sda. Exiting."
        exit 1
    fi

fi

# Ensure the USB mount point is valid
if [[ -z "$MOUNT_POINT" ]] || ! mountpoint -q "$MOUNT_POINT"; then
    echo "Failed to mount /dev/sda properly."
    exit 1
fi

USB_PATH="$MOUNT_POINT"

# Ensure the expected directory exists before syncing
if [[ ! -d "$USB_PATH/utono" ]]; then
    echo "Error: Expected directory '$USB_PATH/utono' not found. Aborting."
    exit 1
fi

# Create the main directory and disable CoW (Copy-on-Write) for performance
mkdir -p "$HOME/utono"
chattr -V +C "$HOME/utono"

# Sync files from USB drive to local system
rsync -avh --info=progress2 "$USB_PATH/utono" "$HOME/utono"

# Synchronize SSH keys
if [[ -f "$HOME/utono/ssh/sync-ssh-keys.sh" ]]; then
    chmod +x "$HOME/utono/ssh/sync-ssh-keys.sh"
    
else
    echo "Warning: sync-ssh-keys.sh not found. Skipping SSH key sync."
fi
bash "$HOME/utono/ssh/sync-ssh-keys.sh" "$HOME/utono" 2>&1 | tee -a sync-ssh-keys-output.out

# Add SSH key and verify
if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
    if ssh-add "$HOME/.ssh/id_ed25519"; then
    ssh-add -l
else
        echo "Warning: Failed to add SSH key."
    fi
else
    echo "Warning: SSH key not found at $HOME/.ssh/id_ed25519. Skipping ssh-add."
fi

# Run user configuration script safely with bash
if [[ -f "$HOME/utono/user-config/rsync-delete-repos-for-new-user.sh" ]]; then
    bash "$HOME/utono/user-config/rsync-delete-repos-for-new-user.sh" 2>&1 | tee rsync-delete-output.out
else
    echo "Warning: rsync-delete-repos-for-new-user.sh not found. Skipping user configuration."
fi

# Set up keyboard configuration
chmod +x "$HOME/utono/rpd/keyd-configuration.sh"
bash "$HOME/utono/rpd/keyd-configuration.sh" "$HOME/utono/rpd"
sudo loadkeys real_prog_dvorak  # Load custom keyboard layout

# Regenerate the initramfs
sudo mkinitcpio -P

# Navigate to package list directory and install packages
if [[ -d "$HOME/utono/install/paclists" ]]; then
    cd "$HOME/utono/install/paclists"
else
    echo "Warning: $HOME/utono/install/paclists directory not found. Skipping package installation."
fi
if [[ -f "install_packages.sh" ]]; then
    bash install_packages.sh mar-2025.csv
else
    echo "Warning: install_packages.sh not found. Skipping package installation."
fi

if [[ -d "$HOME/tty-dotfiles" ]]; then
    cd "$HOME/tty-dotfiles"
    mkdir -p "$HOME/.local/bin"
else
    echo "Warning: $HOME/tty-dotfiles does not exist. Skipping stow setup."
fi
mkdir -p "$HOME/.local/bin"  # Ensure the local bin directory exists

# Apply dotfile configurations using GNU Stow
stow --verbose=2 --no-folding bin-mlj git kitty shell starship yazi -n 2>&1 | tee stow-output.out

# Backup existing .zshrc before modifying if it exists
if [[ -f "$HOME/.zshrc" ]]; then
    ls -al "$HOME/.zshrc"  # List current zsh configuration
    mv "$HOME/.zshrc" "$HOME/.zshrc.cachyos.bak"  # Backup the original .zshrc
fi

# Ensure the target file exists before creating a symbolic link
if [[ -f "$HOME/.config/shell/profile" ]]; then
    ln -sf "$HOME/.config/shell/profile" "$HOME/.zprofile"  # Create symlink for shell profile
else
    echo "Warning: $HOME/.config/shell/profile does not exist. Skipping symlink creation."
fi

# Verify correct path for zsh before changing the default shell
ZSH_PATH=$(command -v zsh)
if [[ -x "$ZSH_PATH" ]]; then
    chsh -s "$ZSH_PATH"  # Change shell to zsh
else
    echo "Warning: zsh not found. Skipping shell change."
fi

# Print success message
echo "All steps completed successfully!"
