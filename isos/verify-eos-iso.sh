#!/usr/bin/env bash

# Description: This script checks the integrity of an EndeavourOS ISO file using SHA512
# and GPG signature verification. It uses `fzf` to select the files from ~/Downloads.

# Ensure required commands are available
for cmd in fzf sha512sum gpg; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: $cmd is not installed. Please install $cmd and try again."
    exit 1
  fi
done

# Set the source directory
src_dir=~/Downloads

# Use fzf to select the ISO file
echo "Select the ISO file:"
iso_file=$(find "$src_dir" -maxdepth 1 -type f -name "EndeavourOS*.iso" 2>/dev/null | fzf --prompt="ISO file: ")

if [[ -z "$iso_file" ]]; then
  echo "No ISO file selected. Exiting..."
  exit 1
fi

# Use fzf to select the corresponding SHA512 file
echo "Select the SHA512 checksum file for the selected ISO:"
sha512_file=$(find "$src_dir" -maxdepth 1 -type f -name "EndeavourOS*.sha512sum" 2>/dev/null | fzf --prompt="SHA512 file: ")

if [[ -z "$sha512_file" ]]; then
  echo "No SHA512 file selected. Exiting..."
  exit 1
fi

# Use fzf to select the corresponding signature file
echo "Select the signature (.iso.sig) file for the selected ISO:"
sig_file=$(find "$src_dir" -maxdepth 1 -type f -name "EndeavourOS*.iso.sig" 2>/dev/null | fzf --prompt="Signature file: ")

if [[ -z "$sig_file" ]]; then
  echo "No signature file selected. Exiting..."
  exit 1
fi

# Verify that the selected files exist
for file in "$iso_file" "$sha512_file" "$sig_file"; do
  if [[ ! -f "$file" ]]; then
    echo "Error: Required file '$file' not found."
    exit 1
  fi
done

# Extract the expected SHA512 hash from the checksum file
expected_hash=$(awk '{print $1}' "$sha512_file")
if [[ -z "$expected_hash" ]]; then
  echo "Error: No valid SHA512 hash found in $sha512_file."
  exit 1
fi

# Calculate the actual SHA512 hash of the ISO file
echo "Calculating SHA512 hash for $iso_file..."
actual_hash=$(sha512sum "$iso_file" | awk '{print $1}')

# Compare the actual hash with the expected hash
if [[ "$actual_hash" == "$expected_hash" ]]; then
  echo "✅ Success: The ISO file integrity is valid (SHA512 Check)."
else
  echo "❌ Error: The ISO file integrity check failed (SHA512 mismatch)."
  echo "Expected: $expected_hash"
  echo "Actual:   $actual_hash"
  exit 1
fi

# Import EndeavourOS GPG key (with alternative key servers)
echo "Importing EndeavourOS GPG key for verification..."
if ! gpg --keyserver hkps://keys.openpgp.org --recv-key 8F43FC374CD4CEEA19CEE323E3D8752ACDF595A1; then
  echo "Primary keyserver failed. Trying alternative keyserver..."
  if ! gpg --keyserver hkps://keyserver.ubuntu.com --recv-key 8F43FC374CD4CEEA19CEE323E3D8752ACDF595A1; then
    echo "❌ Error: Failed to retrieve GPG key. Please check your network or try again later."
    exit 1
  fi
fi

# Verify the GPG signature
echo "Verifying GPG signature for $iso_file using $sig_file..."
gpg --verify "$sig_file" "$iso_file"
gpg_exit_code=$?

if [[ $gpg_exit_code -eq 0 ]]; then
  echo "✅ Success: The GPG signature is valid."
else
  echo "❌ Error: The GPG signature verification failed."
  exit 1
fi

exit 0
