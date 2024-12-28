#!/usr/bin/env bash

# Description: This script allows the user to select a device, wipes it, creates a new partition table, 
# and formats a partition as FAT32. It no longer restricts the selection to only "removable" devices.

# Ensure the script runs with sudo privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root. Please use 'sudo' to execute it."
  exit 1
fi

# Select the device (all devices, not just removable ones)
DEVICE=$(lsblk -o NAME,SIZE,MODEL | fzf --prompt="Select device to format (not limited to removable): " | awk '{print "/dev/" $1}')
if [[ -z "$DEVICE" ]]; then
  echo "❌ No device selected. Exiting."
  exit 1
fi

# Partition name (this assumes the first partition on the selected device)
PARTITION="${DEVICE}1"

# Volume label for the FAT32 filesystem
VOLUME_LABEL="USB_DRIVE"

# Confirm user really wants to wipe the device
echo "⚠️ WARNING: This will erase ALL data on $DEVICE."
echo "The following partitions will be affected:"
lsblk "$DEVICE"
read -p "Type 'yes' to continue: " confirm
if [[ "$confirm" != "yes" ]]; then
  echo "Operation cancelled by user."
  exit 1
fi

echo "🔄 Wiping filesystem signatures from $DEVICE..."
sudo wipefs --all "$DEVICE"
if [[ $? -ne 0 ]]; then
  echo "❌ Error: Failed to wipe filesystem signatures on $DEVICE."
  exit 1
fi

echo "🔄 Creating new partition table on $DEVICE..."
sudo parted "$DEVICE" --script mklabel msdos
if [[ $? -ne 0 ]]; then
  echo "❌ Error: Failed to create partition table on $DEVICE."
  exit 1
fi

echo "🔄 Creating new primary partition on $DEVICE..."
sudo parted "$DEVICE" --script mkpart primary fat32 1MiB 100%
if [[ $? -ne 0 ]]; then
  echo "❌ Error: Failed to create primary partition on $DEVICE."
  exit 1
fi

# Wait for the system to recognize the new partition
echo "⏳ Waiting for the new partition to be recognized..."
sleep 2

# Verify the partition exists
if [[ ! -b "$PARTITION" ]]; then
  echo "❌ Error: Partition $PARTITION does not exist."
  exit 1
fi

echo "🔄 Formatting $PARTITION as FAT32..."
sudo mkfs.fat -F 32 -n "$VOLUME_LABEL" "$PARTITION"
if [[ $? -ne 0 ]]; then
  echo "❌ Error: Failed to format $PARTITION as FAT32."
  exit 1
fi

echo "✅ Success: $PARTITION has been formatted as FAT32 with label '$VOLUME_LABEL'."

exit 0

