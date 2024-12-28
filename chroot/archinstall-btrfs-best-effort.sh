#!/bin/bash

# Define the device and partitions
DEVICE="/dev/nvme0n1"
BOOT_PART="${DEVICE}p1"
BTRFS_PART="${DEVICE}p2"

# Mount options for Btrfs
BTRFS_OPTS="compress=zstd"

# Create mount points
mkdir -p /mnt
mkdir -p /mnt/boot
mkdir -p /mnt/home
mkdir -p /mnt/var/log
mkdir -p /mnt/var/cache/pacman/pkg
mkdir -p /mnt/.snapshots

# Mount Btrfs partition with the subvolumes
mount -o ${BTRFS_OPTS},subvol=@ ${BTRFS_PART} /mnt
mount -o ${BTRFS_OPTS},subvol=@home ${BTRFS_PART} /mnt/home
mount -o ${BTRFS_OPTS},subvol=@log ${BTRFS_PART} /mnt/var/log
mount -o ${BTRFS_OPTS},subvol=@pkg ${BTRFS_PART} /mnt/var/cache/pacman/pkg
mount -o ${BTRFS_OPTS},subvol=@.snapshots ${BTRFS_PART} /mnt/.snapshots

# Mount boot partition
mount ${BOOT_PART} /mnt/boot

# Bind necessary filesystems for chroot
mount -t proc /proc /mnt/proc
mount --rbind /sys /mnt/sys
mount --make-rslave /mnt/sys
mount --rbind /dev /mnt/dev
mount --make-rslave /mnt/dev
mount --rbind /run /mnt/run
mount --make-rslave /mnt/run

echo "Btrfs and boot partitions are mounted. You can now chroot with:"
echo "chroot /mnt /bin/bash"
