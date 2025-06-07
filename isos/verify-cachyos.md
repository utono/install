# How to Download, Verify, and Check the CachyOS ISO  

Follow these steps to securely download, verify, and check the CachyOS ISO file.

---

## 1. Download the ISO and Checksum Files  

Navigate to a directory where you want to store the files:

```bash
cd ~/Downloads
```

Download the necessary files from the official CachyOS website. The ISO follows the naming convention:

```
cachyos-desktop-linux-YYMMDD.iso
```

To download the latest ISO with the correct date format:

```bash
# Get the latest YYMMDD format
ISO_DATE=$(date +%y%m%d)

# Download the CachyOS ISO, checksum, and signature files
wget -O "cachyos-desktop-linux-${ISO_DATE}.iso" "https://iso.cachyos.org/latest/cachyos-desktop-linux-${ISO_DATE}.iso"
wget -O "cachyos-desktop-linux-${ISO_DATE}.sha256" "https://iso.cachyos.org/latest/cachyos-desktop-linux-${ISO_DATE}.iso.sha256"
wget -O "cachyos-desktop-linux-${ISO_DATE}.iso.sig" "https://iso.cachyos.org/latest/cachyos-desktop-linux-${ISO_DATE}.iso.sig"
```

---

## 2. Automate Hash Verification with fzf  

To ensure the ISO's integrity, use the following script, which lets you select both the `.iso` and `.sha256` files interactively:

### Bash Script (`/home/mlj/utono/install/isos/verify_iso_fzf.sh`)

```bash
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
```

Make the script executable:

```bash
chmod +x verify_iso_fzf.sh
```

Run the script:

```bash
./verify_iso_fzf.sh
```

This will prompt you to select both the ISO and SHA256 file interactively using `fzf`, then automatically compare the hashes.

---

## 3. Import the CachyOS GPG Key  

To verify authenticity, import the CachyOS signing key:

```bash
gpg --keyserver hkps://keys.openpgp.org --recv-key F3B607488DB35A47 || \
gpg --keyserver hkps://keyserver.ubuntu.com --recv-key F3B607488DB35A47
```

If keyservers are unreachable, manually download the key:

```bash
curl -O https://github.com/CachyOS/CachyOS-PKGBUILDS/raw/master/cachyos-keyring/cachyos.gpg
gpg --import cachyos.gpg
```

### What Is a GPG Key?  

A **GPG key** (GNU Privacy Guard key) is a cryptographic key used for **signing** and **encrypting** data. In this case, it is used to **digitally sign** the CachyOS ISO file, proving that the file has not been tampered with and that it was indeed created by the official CachyOS maintainers.

The `--recv-key` command fetches the public GPG key from a keyserver, allowing the system to verify the ISO file's signature. The key **F3B607488DB35A47** belongs to the CachyOS project and was obtained from their official repository.

---

## 4. Verify the ISO Signature  

Once the key is imported, verify the ISO’s signature:

```bash
gpg --verify "cachyos-desktop-linux-${ISO_DATE}.iso.sig" "cachyos-desktop-linux-${ISO_DATE}.iso"
```

### Understanding the Signature Verification Output  

- If you see **"Good signature"**, the ISO is authentic.
- If you see a **"not certified with a trusted signature"** warning, it means the key isn’t explicitly trusted on your system, but the signature is still valid.
- If you get **"BAD signature"**, the file is either corrupted or has been modified by an unauthorized party.

---

## 5. Automate the Entire Process  

For full automation, use the following script (`full_verify_fzf.sh`) that combines hash verification and GPG signature checking:

```bash
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
```

Make the script executable:

```bash
chmod +x full_verify_fzf.sh
```

Run the script:

```bash
./full_verify_fzf.sh
```

This script automates the entire verification process, ensuring that the ISO is downloaded, checked, and validated with minimal effort.

