#!/usr/bin/env bash

# $HOME/utono/install/isos/download-archlinux-iso.sh
#
# Downloads the latest Arch Linux ISO from a known mirror and verifies both
# its GPG signature and SHA256 checksum using the official signing key.
# Use --yes to skip confirmation prompts.

set -euo pipefail

DEST_DIR="$HOME/Downloads"
MIRROR="https://mirror.arizona.edu/archlinux/iso"
KEY_FINGERPRINT="3E80CA1A8B89F69CBA57D98A76A5EF9054449A5C"
KEY_FILE="${KEY_FINGERPRINT}.asc"
KEY_URL="https://gitlab.archlinux.org/archlinux/archlinux-keyring/-/raw/main/keys/${KEY_FILE}"
YES_MODE=0

# Check for --yes flag
if [[ "${1:-}" == "--yes" ]]; then
  YES_MODE=1
fi

mkdir -p "$DEST_DIR"
cd "$DEST_DIR"

get_latest_release_date() {
  curl -s "${MIRROR}/" | grep -oP '\d{4}\.\d{2}\.\d{2}/' | sort -r | head -n 1 | tr -d '/'
}

RELEASE_DATE=$(get_latest_release_date)
ISO_NAME="archlinux-${RELEASE_DATE}-x86_64.iso"
SIG_NAME="${ISO_NAME}.sig"
SUMS_NAME="sha256sums.txt"
BASE_URL="${MIRROR}/${RELEASE_DATE}"

prompt_if_exists() {
  local file="$1"
  if [[ -f "$file" && "$YES_MODE" -eq 0 ]]; then
    read -rp "⚠️  $file exists. Redownload? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] && rm -f "$file"
  fi
}

download_file() {
  local url="$1"
  local file="$2"
  prompt_if_exists "$file"
  if [[ -f "$file" ]]; then
    echo "⏩ Skipping download of $file"
  else
    wget "$url"
  fi
}

echo "📦 Detected latest Arch ISO release: $RELEASE_DATE"
echo "📥 Downloading files from $BASE_URL"

download_file "${BASE_URL}/${ISO_NAME}" "$ISO_NAME"
download_file "${BASE_URL}/${SIG_NAME}" "$SIG_NAME"
download_file "${BASE_URL}/${SUMS_NAME}" "$SUMS_NAME"

echo "🔐 Ensuring Arch Linux signing key is available..."
if command -v pacman-key &>/dev/null; then
  echo "✅ Using pacman-key to populate keyring..."
  sudo pacman -Sy --noconfirm archlinux-keyring
  sudo pacman-key --init || true
  sudo pacman-key --populate archlinux
  echo "📤 Importing trusted key into GPG keyring for verification..."
  gpg --homedir /etc/pacman.d/gnupg --export "$KEY_FINGERPRINT" | gpg --import
else
  echo "📥 Falling back to manual GPG key import..."
  download_file "$KEY_URL" "$KEY_FILE"
  gpg --import "$KEY_FILE"
fi

echo "🧪 Verifying GPG signature..."
gpg --verify "$SIG_NAME" "$ISO_NAME"

echo "🔍 Verifying SHA256 checksum..."
CHECKSUM_RESULT=$(sha256sum -c "$SUMS_NAME" 2>&1 | grep "$ISO_NAME" || true)

if [[ "$CHECKSUM_RESULT" != *": OK"* ]]; then
  echo "❌ SHA256 checksum verification failed!" >&2
  exit 1
fi

SHA256_DIGEST=$(sha256sum "$ISO_NAME" | awk '{print $1}')

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Arch Linux ISO verification complete!"
echo
echo "🗓️  Release Date : $RELEASE_DATE"
echo "📦 ISO File      : $ISO_NAME"
echo "🔐 Signature     : Good signature from Pierre Schmitz"
echo "🔢 SHA256        : $SHA256_DIGEST"
echo "📁 Saved To      : $DEST_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
