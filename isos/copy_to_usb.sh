#!/usr/bin/env bash

# Directories to be copied
DIRECTORIES=(
  "$HOME/utono"
  "$HOME/.config/mpv"
  "$HOME/.config/nvim"
  "$HOME/tty-dotfiles"
)

# Function to list mounted USB drives
get_mounted_usb_drives() {
  lsblk -o NAME,MOUNTPOINT,TRAN | awk '$3 == "usb" && $2 != "" {print $2}'
}

# Function to prompt the user to select a USB drive using fzf
select_usb_drive() {
  local usb_mounts=("$@")

  if [ ${#usb_mounts[@]} -eq 0 ]; then
    dunstify -u critical "No USB drives detected." 
    exit 1
  fi

  echo "${usb_mounts[@]}" | tr ' ' '\n' | fzf --prompt="Select USB drive to copy files: "
}

# Copy directories to the selected USB drive
copy_directories_to_usb() {
  local usb="$1"

  if [ -z "$usb" ]; then
    dunstify -u critical "No USB drive selected. Exiting."
    exit 1
  fi

  for dir in "${DIRECTORIES[@]}"; do
    if [ -d "$dir" ]; then
      dest="$usb/$(basename "$dir")"
      dunstify -u normal "Copying $dir to $dest"
      rsync -a --info=progress2 "$dir/" "$dest/" \
        && dunstify -u normal "Successfully copied $dir to $dest" \
        || dunstify -u critical "Failed to copy $dir to $dest"
    else
      dunstify -u critical "Directory $dir does not exist. Skipping."
    fi
  done
}

# Main logic
main() {
  usb_mounts=($(get_mounted_usb_drives))
  if [ ${#usb_mounts[@]} -eq 0 ]; then
    dunstify -u critical "No USB drives found."
    exit 1
  fi

  selected_usb=$(select_usb_drive "${usb_mounts[@]}")
  if [ -z "$selected_usb" ]; then
    dunstify -u critical "No USB drive selected. Exiting."
    exit 1
  fi

  copy_directories_to_usb "$selected_usb"
}

main
