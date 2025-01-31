#!/usr/bin/env bash

# Description: This script verifies an Ubuntu ISO by checking its SHA256 checksum 
# and validating the checksum file's GPG signature against Ubuntu's official key.

set -e  # Exit on any error

# Ensure required commands are installed
for cmd in fzf sha256sum gpg curl; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: $cmd is not installed. Please install it and try again."
    exit 1
  fi
done

# Set the source directory
src_dir=~/Downloads

# Select the Ubuntu ISO file
echo "Select the Ubuntu ISO file:"
iso_file=$(find "$src_dir" -maxdepth 1 -type f -name "*.iso" 2>/dev/null | fzf --prompt="ISO file: ")

if [[ -z "$iso_file" ]]; then
  echo "No ISO file selected. Exiting..."
  exit 1
fi

# Extract Ubuntu version from the ISO filename
iso_name=$(basename "$iso_file")
ubuntu_version=$(echo "$iso_name" | grep -oP 'ubuntu-\K[0-9]+\.[0-9]+' || true)

if [[ -z "$ubuntu_version" ]]; then
  echo "Error: Unable to extract Ubuntu version from filename."
  exit 1
fi

# Construct checksum and signature URLs
checksum_url="https://releases.ubuntu.com/$ubuntu_version/SHA256SUMS"
gpg_url="$checksum_url.gpg"

echo "Detected Ubuntu version: $ubuntu_version"
echo "Downloading latest checksum files from Ubuntu..."

# Download checksum files
curl -fsSL -o "$src_dir/SHA256SUMS" "$checksum_url" || {
  echo "Error: Failed to download SHA256SUMS from Ubuntu."
  exit 1
}

curl -fsSL -o "$src_dir/SHA256SUMS.gpg" "$gpg_url" || {
  echo "Error: Failed to download SHA256SUMS.gpg from Ubuntu."
  exit 1
}

# Import Ubuntu's official GPG key
ubuntu_gpg_key="843938DF228D22F7B3742BC0D94AA3F0EFE21092"
echo "Importing Ubuntu GPG key..."
if ! gpg --keyserver hkps://keyserver.ubuntu.com --recv-key "$ubuntu_gpg_key"; then
  echo "Error: Failed to import Ubuntu GPG key."
  exit 1
fi

# Verify the checksum file's signature
echo "Verifying checksum file signature..."
if ! gpg --verify "$src_dir/SHA256SUMS.gpg" "$src_dir/SHA256SUMS"; then
  echo "❌ Error: Checksum file signature verification failed!"
  exit 1
fi
echo "✅ Success: Checksum file is authentic."

# Verify the ISO checksum
echo "Verifying ISO checksum..."
if grep -q "$(sha256sum "$iso_file" | awk '{print $1}')" "$src_dir/SHA256SUMS"; then
  echo "✅ Success: ISO checksum is valid."
else
  echo "❌ Error: ISO checksum verification failed!"
  exit 1
fi

echo "🎉 The Ubuntu ISO is fully verified!"
exit 0
