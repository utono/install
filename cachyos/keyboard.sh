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
# Ensure that dependencies like paru, udisksctl, and rsync are installed.

set -e  # Exit immediately if any command exits with a non-zero status
set -u  # Treat unset variables as an error
set -o pipefail  # Ensure errors in piped commands are not masked

# Update package mirrors for better performance
cachyos-rate-mirrors

# Install udisks2 to handle disk mounting
paru -Syy udisks2

# Create the main directory and disable CoW (Copy-on-Write) for performance
mkdir -p "$HOME/utono"
chattr -V +C "$HOME/utono"

# Check if /dev/sda is already mounted
MOUNT_POINT=$(lsblk -o MOUNTPOINT -nr /dev/sda)
if [[ -z "$MOUNT_POINT" ]]; then
    # If not mounted, attempt to mount it
    udisksctl mount -b /dev/sda
    MOUNT_POINT=$(lsblk -o MOUNTPOINT -nr /dev/sda)
fi

# Exit if the USB mount point could not be determined
if [[ -z "$MOUNT_POINT" ]]; then
    echo "Failed to mount /dev/sda"
    exit 1
fi

USB_PATH="$MOUNT_POINT"

# Ensure the target directory exists before syncing
mkdir -p "$HOME/utono"
chattr -V +C "$HOME/utono"

# Sync files from USB drive to local system
rsync -avh --progress "$USB_PATH/utono" "$HOME/utono"

# Set up keyboard configuration
chmod +x "$HOME/utono/rpd/keyd-configuration.sh"
bash "$HOME/utono/rpd/keyd-configuration.sh" "$HOME/utono/rpd"
sudo loadkeys real_prog_dvorak  # Load custom keyboard layout

# Regenerate the initramfs
sudo mkinitcpio -P

# Navigate to package list directory and install packages
cd "$HOME/utono/install/paclists"
bash install_packages.sh mar-2025.csv

# Move dotfiles to the home directory
mv "$HOME/utono/tty-dotfiles" "$HOME"
cd "$HOME/tty-dotfiles"
mkdir -p "$HOME/.local/bin"  # Ensure the local bin directory exists

# Apply dotfile configurations using GNU Stow
stow --verbose=2 --no-folding bin-mlj git kitty shell starship yazi -n 2>&1 | tee stow-output.out

# Backup existing .zshrc before modifying
ls -al .zshrc  # List current zsh configuration
mv .zshrc .zshrc.cachyos.bak  # Backup the original .zshrc

# Ensure the target file exists before creating a symbolic link
if [[ -f "$HOME/.config/shell/profile" ]]; then
    ln -sf "$HOME/.config/shell/profile" .zprofile  # Create symlink for shell profile
else
    echo "Warning: $HOME/.config/shell/profile does not exist. Skipping symlink creation."
fi

# Verify correct path for zsh before changing the default shell
ZSH_PATH=$(which zsh)
if [[ -x "$ZSH_PATH" ]]; then
    chsh -s "$ZSH_PATH"  # Change shell to zsh
else
    echo "Warning: zsh not found. Skipping shell change."
fi

# Print success message
echo "All steps completed successfully!"
