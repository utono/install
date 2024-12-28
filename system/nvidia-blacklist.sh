#!/usr/bin/env bash

set -uo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Exiting."
    exit 1
fi

FAILED_COMMANDS=()
RSYNC_LOG=()

log_rsync() {
    local src="$1"
    local dest="$2"
    RSYNC_LOG+=("Synced: $src -> $dest")
}

configure_nvidia_blacklist_and_removal() {
    local utono_path="$1"

    rsync -av --chown=root:root "${utono_path}/system-configs/modprobe.d/etc/modprobe.d/blacklist-nvidia.conf" /etc/modprobe.d/ && \
        log_rsync "${utono_path}/system-configs/modprobe.d/etc/modprobe.d/blacklist-nvidia.conf" "/etc/modprobe.d/" || \
        FAILED_COMMANDS+=("rsync blacklist-nvidia.conf")

    rsync -av --chown=root:root "${utono_path}/system-configs/udev/etc/udev/rules.d/00-remove-nvidia.rules" /etc/udev/rules.d/ && \
        log_rsync "${utono_path}/system-configs/udev/etc/udev/rules.d/00-remove-nvidia.rules" "/etc/udev/rules.d/" || \
        FAILED_COMMANDS+=("rsync udev rules")
}

main() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: $0 <utono_directory_path>"
        exit 1
    fi

    local utono_path="$1"
    configure_nvidia_blacklist_and_removal "$utono_path"

    echo "NVIDIA blacklist and removal configuration applied successfully."
}

main "$@"
