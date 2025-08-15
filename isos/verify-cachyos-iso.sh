#!/usr/bin/env bash
# ~/.local/bin/verify-iso.sh
# Description: This script checks the integrity of an ISO file using either
# SHA512 or SHA256 checksum and GPG signature verification. It uses `fzf` to
# select the files from ~/Downloads.

# Ensure required commands are available
for cmd in fzf sha512sum sha256sum gpg; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: $cmd is not installed. Please install $cmd and try again."
    exit 1
  fi
done

# Set the source directory
src_dir=~/Downloads

# Use fzf to select the ISO file
echo "Select the ISO file:"
iso_file=$(fd -t f -e iso . "$src_dir" | fzf --prompt="ISO file: ")
if [[ -z "$iso_file" ]]; then
  echo "No ISO file selected. Exiting..."
  exit 1
fi

# Prompt user to choose verification method
echo "Choose verification method:"
echo "1) SHA256/SHA512 checksum verification"
echo "2) GPG signature verification only"
echo "3) Both checksum and signature verification"
read -p "Enter choice (1-3): " choice

case $choice in
  1|3)
    # Use fzf to select the checksum file
    echo "Select the SHA256/SHA512 checksum file:"
    checksum_file=$(fd -t f -e sha256 -e sha512sum . "$src_dir" | fzf --prompt="Checksum file: ")
    if [[ -z "$checksum_file" ]]; then
      echo "Error: No checksum file selected."
      if [[ $choice == "1" ]]; then
        exit 1
      else
        echo "Continuing with signature verification only..."
      fi
    else
      # Determine the checksum type based on the file extension
      if [[ "$checksum_file" == *.sha512sum ]]; then
        checksum_type="SHA512"
        checksum_cmd="sha512sum"
      elif [[ "$checksum_file" == *.sha256sum || "$checksum_file" == *.sha256 ]]; then
        checksum_type="SHA256"
        checksum_cmd="sha256sum"
      else
        echo "Error: Unsupported checksum file type."
        if [[ $choice == "1" ]]; then
          exit 1
        else
          echo "Continuing with signature verification only..."
          checksum_file=""
        fi
      fi

      if [[ -n "$checksum_file" ]]; then
        # Extract the expected checksum from the file
        expected_checksum=$(awk '{print $1}' "$checksum_file")
        if [[ -z "$expected_checksum" ]]; then
          echo "Error: No valid $checksum_type checksum found in $checksum_file."
          if [[ $choice == "1" ]]; then
            exit 1
          else
            echo "Continuing with signature verification only..."
          fi
        else
          # Calculate the actual checksum of the ISO file
          echo "Calculating $checksum_type checksum for $iso_file..."
          actual_checksum=$($checksum_cmd "$iso_file" | awk '{print $1}')

          # Compare the actual checksum with the expected checksum
          if [[ "$actual_checksum" == "$expected_checksum" ]]; then
            echo "✅ Success: The ISO file integrity is valid ($checksum_type Check)."
          else
            echo "❌ Error: The ISO file integrity check failed ($checksum_type mismatch)."
            echo "Expected: $expected_checksum"
            echo "Actual:   $actual_checksum"
            exit 1
          fi
        fi
      fi
    fi
    ;;
  2)
    echo "Skipping checksum verification..."
    ;;
  *)
    echo "Invalid choice. Exiting..."
    exit 1
    ;;
esac

# GPG signature verification (for choices 2 and 3, or if choice 1 failed checksum)
if [[ $choice == "2" || $choice == "3" ]]; then
  # Search for a corresponding signature file
  sig_file=$(fd -t f -e sig . "$src_dir" | grep "$(basename "$iso_file").sig")
  
  if [[ -z "$sig_file" ]]; then
    echo "Select the GPG signature file:"
    sig_file=$(fd -t f -e sig . "$src_dir" | fzf --prompt="Signature file: ")
  fi

  # If a signature file was found, verify the GPG signature
  if [[ -n "$sig_file" ]]; then
    echo "Importing GPG key for signature verification..."
    if ! gpg --keyserver hkps://keys.openpgp.org --recv-key F3B607488DB35A47; then
      echo "Primary keyserver failed. Trying alternative keyserver..."
      if ! gpg --keyserver hkps://keyserver.ubuntu.com --recv-key F3B607488DB35A47; then
        echo "❌ Error: Failed to retrieve GPG key. Please check your network or try again later."
        exit 1
      fi
    fi

    echo "Verifying GPG signature for $iso_file using $sig_file..."
    if gpg --verify "$sig_file" "$iso_file"; then
      echo "✅ Success: The GPG signature is valid."
    else
      echo "❌ Error: The GPG signature verification failed."
      exit 1
    fi
  else
    echo "No signature file found. Skipping GPG verification."
  fi
fi

exit 0
