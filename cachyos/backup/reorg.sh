#!/usr/bin/env bash

# CachyOS Documentation Reorganization Script
# This script renames files and creates new documentation structure

set -euo pipefail

# Change to the cachyos directory
cd ~/utono/install/cachyos

# Create backup of existing files
echo "Creating backup of existing files..."
mkdir -p backup
cp *.md backup/ 2>/dev/null || true

# Rename existing files to new numbering scheme
echo "Renaming existing files..."

# Phase 1: Pre-Installation Setup
mv usb-drives.md 00-usb-preparation.md 2>/dev/null || true
# 01-keyboard-layout.md will be created new
# cachyos-install.md will be renamed to 02-cachyos-install.md

# Phase 2: System Configuration (Root)
mv 02-system-security.md 03-system-security.md 2>/dev/null || true
mv 03-grub-sddm-config.md 04-grub-sddm-config.md 2>/dev/null || true

# Phase 3: User Setup  
mv 01-user-setup.md 05-user-setup.md 2>/dev/null || true
mv 04-hyprland-services.md 06-hyprland-services.md 2>/dev/null || true

# Rename the main install file
mv cachyos-install.md 02-cachyos-install.md 2>/dev/null || true

echo "File renaming completed!"
echo "Next steps:"
echo "1. Review the renamed files"
echo "2. Create the new files using the provided content"
echo "3. Update any internal references"
echo "4. Commit and push changes"
