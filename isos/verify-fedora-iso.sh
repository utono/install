#!/usr/bin/env bash

# Description: Verifies a Fedora ISO by checking its SHA256 checksum 
# and validating the checksum file's GPG signature against Fedora's official key.

set -e  # Exit on any error

# Ensure required commands are installed
for cmd in fzf sha256sum gpgv curl; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: $cmd is not installed. Please install it and try again."
    exit 1
  fi
done

# Set the source directory
src_dir=~/Downloads

# Select the Fedora ISO file
echo "Select the Fedora ISO file:"
iso_file=$(find "$src_dir" -maxdepth 1 -type f -name "*.iso" 2>/dev/null | fzf --prompt="ISO file: ")

if [[ -z "$iso_file" ]]; then
  echo "No ISO file selected. Exiting..."
  exit 1
fi

# Extract Fedora version from the ISO filename
iso_name=$(basename "$iso_file")
fedora_version=$(echo "$iso_name" | grep -oP '(?<=-)[0-9]+(?=-[0-9]+\.[0-9]+)')

if [[ -z "$fedora_version" ]]; then
  echo "Error: Unable to extract Fedora version from filename."
  exit 1
fi

# Construct checksum filename
checksum_file="Fedora-Spins-${fedora_version}-1.4-x86_64-CHECKSUM"

echo "Detected Fedora version: $fedora_version"
echo "Checksum file should be: $checksum_file"

# Download Fedora's GPG key
echo "Downloading Fedora's GPG key..."
curl -fsSL -o "$src_dir/fedora.gpg" "https://fedoraproject.org/fedora.gpg" || {
  echo "Error: Failed to download Fedora's GPG key."
  exit 1
}

# Select the CHECKSUM file
echo "Select the Fedora CHECKSUM file:"
checksum_path=$(find "$src_dir" -maxdepth 1 -type f -name "Fedora-*CHECKSUM" 2>/dev/null | fzf --prompt="CHECKSUM file: ")

if [[ -z "$checksum_path" ]]; then
  echo "No checksum file selected. Exiting..."
  exit 1
fi

echo "Verifying checksum file signature..."
if ! gpgv --keyring "$src_dir/fedora.gpg" "$checksum_path"; then
  echo "❌ Error: Checksum file signature verification failed!"
  exit 1
fi
echo "✅ Success: Checksum file is authentic."

echo "Verifying ISO checksum..."
iso_basename=$(basename "$iso_file")

if grep "$iso_basename" "$checksum_path" | sha256sum -c - 2>/dev/null | grep -q "$iso_basename: OK"; then
  echo "✅ Success: ISO checksum is valid."
else
  echo "❌ Error: ISO checksum verification failed!"
  exit 1
fi

echo "🎉 The Fedora ISO is fully verified!"
exit 0
