#!/usr/bin/env bash

# stow-root.sh
# This script sets up configuration files for the root user using GNU Stow. 
# It performs the following tasks:
# 
# 1. Syncs the tty-dotfiles directory from the current user's home to /root if 
#    it doesn't already exist.
# 2. Runs GNU Stow for a predefined list of packages to manage symbolic links 
#    for configuration files under /root.
# 3. Handles conflicts by prompting the user to remove problematic directories 
#    and retrying failed operations.
# 4. Tracks and reports any failures encountered during execution.
#
# Usage:
#   ./stow-root.sh
#
# Requirements:
#   - Must be run as root.
#   - Requires the 'rsync' and 'stow' utilities to be installed.
#
# Notes:
#   - The script does not take any arguments.
#   - Existing directories in /root that conflict with Stow operations will 
#     trigger a prompt for manual removal.

# Array to track failed commands
FAILED_COMMANDS=()

# Report failed commands
report_failures() {
    if [ ${#FAILED_COMMANDS[@]} -ne 0 ]; then
        echo "The following commands failed:"
        for cmd in "${FAILED_COMMANDS[@]}"; do
            echo "- $cmd"
        done
        exit 1
    else
        echo "All commands completed successfully."
    fi
}

# Sync tty-dotfiles to /root if not already present
sync_tty_dotfiles() {
    local src_dir="$HOME/utono/tty-dotfiles"
    local dest_dir="/root/tty-dotfiles"

    if [ ! -d "$dest_dir" ]; then
        echo "Copying $src_dir to $dest_dir..."
        rsync -av "$src_dir" "/root/" || FAILED_COMMANDS+=("rsync $src_dir to /root/")
    else
        echo "Directory $dest_dir already exists. Skipping copy."
    fi
}

# Prompt to remove conflicting directories if stow fails
prompt_remove_conflicts() {
    local dir=$1
    while true; do
        read -p "Conflict detected with $dir. Do you want to remove it? (y/n): " yn
        case $yn in
            [Yy]* )
                echo "Removing $dir..."
                rm -rf "$dir" || FAILED_COMMANDS+=("rm -rf $dir")
                break
                ;;
            [Nn]* )
                echo "Skipping removal of $dir. Stow may not complete successfully."
                break
                ;;
            * )
                echo "Please answer yes or no."
                ;;
        esac
    done
}

# Run GNU Stow for each package
run_stow() {
    local package=$1
    local stow_command="stow --dir=/root/tty-dotfiles --no-folding --stow $package --target=/root --verbose=1"

    echo "Stowing $package..."
    if ! bash -c "$stow_command"; then
        echo "Stow command failed for package: $package"
        case $package in
            bat) prompt_remove_conflicts "/root/.config/bat" ;;
            btop) prompt_remove_conflicts "/root/.config/btop" ;;
            git) prompt_remove_conflicts "/root/.config/git" ;;
            ssh) prompt_remove_conflicts "/root/.ssh" ;;
        esac
        # Retry the stow command after resolving conflicts
        echo "Retrying stow for $package..."
        bash -c "$stow_command" || FAILED_COMMANDS+=("stow $package")
    fi
}

# Main function to sync dotfiles and stow packages
main() {
    sync_tty_dotfiles

    # List of packages to stow
    local packages=(
        bat
        btop
        git
        keyd
        shell
        ssh
        starship
    )

    for package in "${packages[@]}"; do
        run_stow "$package"
    done

    report_failures
}

main "$@"
