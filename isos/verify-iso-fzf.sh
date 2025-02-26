#!/usr/bin/env bash

set -e

# Select ISO file with fzf
iso_file=$(find ~/Downloads -type f -name "cachyos-desktop-linux-*.iso" | fzf --prompt="Select ISO file: ")

# Select checksum file with fzf
sha256_file=$(find ~/Downloads -type f -name "cachyos-desktop-linux-*.sha256" | fzf --prompt="Select SHA256 file: ")

# Verify that selections were made
if [[ -z "$iso_file" || -z "$sha256_file" ]]; then
    echo "❌ No file selected. Exiting."
    exit 1
fi

# Extract expected hash from the selected .sha256 file
expected_hash=$(awk '{print $1}' "$sha256_file")

# Calculate hash of the selected ISO file
calculated_hash=$(sha256sum "$iso_file" | awk '{print $1}')

# Compare hashes
if [[ "$expected_hash" == "$calculated_hash" ]]; then
    echo "✅ ISO hash matches! The download is valid."
else
    echo "❌ Hash mismatch! The ISO may be corrupted or tampered with."
    exit 1
fi
