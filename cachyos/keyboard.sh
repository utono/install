#!/usr/bin/env bash

set -e  # Exit on error
set -u  # Treat unset variables as an error
set -o pipefail  # Prevent errors in piped commands from being masked

cachyos-rate-mirrors
paru -Syy udisks2

mkdir -p "$HOME/utono"
chattr -V +C "$HOME/utono"

# Check if /dev/sda is already mounted
MOUNT_POINT=$(lsblk -o MOUNTPOINT -nr /dev/sda)
if [[ -z "$MOUNT_POINT" ]]; then
    udisksctl mount -b /dev/sda
    MOUNT_POINT=$(lsblk -o MOUNTPOINT -nr /dev/sda)
fi

if [[ -z "$MOUNT_POINT" ]]; then
    echo "Failed to mount /dev/sda"
    exit 1
fi

USB_PATH="$MOUNT_POINT"

mkdir -p "$HOME/utono"
chattr -V +C "$HOME/utono"
rsync -avh --progress "$USB_PATH/utono" "$HOME/utono"

chmod +x "$HOME/utono/rpd/keyd-configuration.sh"
bash "$HOME/utono/rpd/keyd-configuration.sh" "$HOME/utono/rpd"
sudo loadkeys real_prog_dvorak

sudo mkinitcpio -P

cd "$HOME/utono/install/paclists"
bash install_packages.sh mar-2025.csv

mv "$HOME/utono/tty-dotfiles" "$HOME"
cd "$HOME/tty-dotfiles"
mkdir -p "$HOME/.local/bin"
stow --verbose=2 --no-folding bin-mlj git kitty shell starship yazi -n 2>&1 | tee stow-output.out

ls -al .zshrc
mv .zshrc .zshrc.cachyos.bak

# Ensure target file exists before creating symbolic link
if [[ -f "$HOME/.config/shell/profile" ]]; then
    ln -sf "$HOME/.config/shell/profile" .zprofile
else
    echo "Warning: $HOME/.config/shell/profile does not exist. Skipping symlink creation."
fi

# Verify correct path for zsh before changing shell
ZSH_PATH=$(which zsh)
if [[ -x "$ZSH_PATH" ]]; then
    chsh -s "$ZSH_PATH"
else
    echo "Warning: zsh not found. Skipping shell change."
fi

echo "All steps completed successfully!"
