How to Download, Verify, and Check the Arch Linux ISO

Follow these steps to securely download, verify, and check the Arch Linux ISO file.
1. Download the ISO, Checksum, and Signature Files

First, navigate to a directory where you want to store the files:

cd ~/Downloads

Then, download the necessary files from the Arizona mirror:

# Download the Arch Linux ISO file
wget https://mirror.arizona.edu/archlinux/iso/2025.08.01/archlinux-2025.02.01-x86_64.iso
wget https://mirror.arizona.edu/archlinux/iso/2025.08.01/sha256sums.txt
wget https://mirror.arizona.edu/archlinux/iso/2025.08.01/archlinux-2025.02.01-x86_64.iso.sig

2. Install and Update the Arch Linux Keyring

If you are on an Arch-based system, update and install the latest Arch Linux keyring:

sudo pacman -Sy archlinux-keyring

Then, initialize and populate the keyring:

sudo pacman-key --init
sudo pacman-key --populate archlinux
sudo pacman-key --list-keys

    pub   ed25519 2021-03-21 [SC]
      3E80CA1A8B89F69CBA57D98A76A5EF9054449A5C
    uid           [ unknown] Pierre Schmitz <pierre@archlinux.org>
sudo pacman-key --list-sigs


3. Import the Arch Linux Signing Key Manually

If the key is not available after updating archlinux-keyring, manually import it:

gpg --keyserver hkps://keys.openpgp.org --recv-keys 3E80CA1A8B89F69CBA57D98A76A5EF9054449A5C

Alternatively, try another keyserver:

gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys 3E80CA1A8B89F69CBA57D98A76A5EF9054449A5C

If keyservers are not working, download the key manually:

curl -O https://gitlab.archlinux.org/archlinux/archlinux-keyring/-/raw/main/keys/3E80CA1A8B89F69CBA57D98A76A5EF9054449A5C.asc
gpg --import 3E80CA1A8B89F69CBA57D98A76A5EF9054449A5C.asc

4. Verify the Signature

Now, check that the ISO is properly signed by an official Arch Linux developer:

gpg --verify archlinux-2025.02.01-x86_64.iso.sig archlinux-2025.02.01-x86_64.iso
gpg --verify archlinux-2025.08.01-x86_64.iso.sig archlinux-2025.08.01-x86_64.iso

Expected Output (Valid Signature)

If successful, you should see:

gpg: Good signature from "Pierre Schmitz <pierre@archlinux.org>"

⚠ If you see a warning like "The key's User ID is not certified with a trusted signature," it simply means the key isn't explicitly trusted on your system. The signature is still valid.
5. Verify the ISO Integrity

To ensure the ISO file was downloaded correctly, compare its SHA-256 checksum:

sha256sum -c sha256sums.txt 2>&1 | grep archlinux-2025.02.01-x86_64.iso

If the output includes OK, the ISO file is valid.
