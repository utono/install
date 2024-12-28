#!/bin/bash

choose_partitions() {
    while true; do
        echo "Please choose the root and boot partitions for $DEVICE:"
        echo "1) /dev/sda1 and /dev/sda2"
        echo "2) /dev/nvme0n1p1 and /dev/nvme0n1p2"
        echo "3) /dev/vda1 and /dev/vda2"
        read -p "Enter your choice (1, 2, or 3): " choice

        case $choice in
            1)
                DEVICE_P1="/dev/sda1"
                DEVICE_P2="/dev/sda2"
                ;;
            2)
                DEVICE_P1="/dev/nvme0n1p1"
                DEVICE_P2="/dev/nvme0n1p2"
                ;;
            3)
                DEVICE_P1="/dev/vda1"
                DEVICE_P2="/dev/vda2"
                ;;
            *)
                echo "Invalid choice. Please enter 1, 2, or 3."
                continue
                ;;
        esac

        echo "You have selected root partition: $DEVICE_P2 and boot partition: $DEVICE_P1"
        read -p "To confirm, type 'yes': " confirm

        if [[ $confirm == "yes" ]]; then
            echo "Partitions $DEVICE_P2 (root) and $DEVICE_P1 (boot) confirmed."
            break
        else
            echo "Confirmation failed. Please try again."
        fi
    done
}

mount_filesystems() {
    sudo mount "${DEVICE_P2}" /mnt
    for subvol in @ @cache @home @images @log @snapshots; do
        sudo mount -o compress=zstd:1,noatime,subvol=$subvol "${DEVICE_P2}" "/mnt/$subvol"
    done
    sudo mount "${DEVICE_P1}" "/mnt/boot/efi"
}

# Call the function
choose_partitions
mount_filesystems
