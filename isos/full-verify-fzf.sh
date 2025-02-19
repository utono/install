#!/usr/bin/env bash

set -e

iso_file=$(find ~/Downloads -type f -name "cachyos-desktop-linux-*.iso" | fzf --prompt="Select ISO file: ")
sha256_file=$(find ~/Downloads -type f -name "cachyos-desktop-linux-*.sha256" | fzf --prompt="Select SHA256 file: ")
sig_file=$(find ~/Downloads -type f -name "cachyos-desktop-linux-*.iso.sig" | fzf --prompt="Select ISO signature file: ")

if [[ -z "$iso_file" || -z "$sha256_file" || -z "$sig_file" ]]; then
    echo "❌ No file selected. Exiting."
    exit 1
fi

expected_hash=$(awk '{print $1}' "$sha256_file")
calculated_hash=$(sha256sum "$iso_file" | awk '{print $1}')

if [[ "$expected_hash" != "$calculated_hash" ]]; then
    echo "❌ Hash mismatch! The ISO may be corrupted or tampered with."
    exit 1
fi

gpg --verify "$sig_file" "$iso_file" && echo "✅ ISO signature is valid." || echo "❌ Signature verification failed!"
