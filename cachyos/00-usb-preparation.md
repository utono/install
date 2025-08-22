# USB Drive Preparation for CachyOS Installation

This guide prepares a USB drive with essential configuration files and backups needed for CachyOS installation and setup.

## Prerequisites

- USB drive (32GB+ recommended)
- Source machine with existing configuration
- Administrative privileges

## Format USB Drive

### Switch to TTY (if needed)
```bash
Ctrl + Alt + F3
```

### Install Required Tools
```bash
sudo pacman -Syu
paru -Sy udisks2
```

### Format the Drive
```bash
# Check device name (usually /dev/sda for USB drives)
lsblk

# Wipe existing filesystem signatures
wipefs --all /dev/sda

# Create FAT32 filesystem
sudo mkfs.fat -F 32 /dev/sda

# Mount the drive
udisksctl mount -b /dev/sda
```

## Backup Essential Directories

### Define Variables
```bash
# USB mount point (adjust if different)
USB_DRIVE="/run/media/mlj/8C8E-606F"

# Verify mount point
ls -la "$USB_DRIVE"
```

### Backup Configuration Files
```bash
echo "Backing up utono directory..."
mkdir -p "$USB_DRIVE/utono"
chattr -V +C "$USB_DRIVE/utono" 2>/dev/null || true

# Backup utono directory (follows symlinks for FAT32 compatibility)
rsync -avL --progress ~/utono/ "$USB_DRIVE/utono/"

echo "Backing up SSH keys..."
mkdir -p "$USB_DRIVE/ssh-backup"
rsync -av ~/.ssh/ "$USB_DRIVE/ssh-backup/"

echo "Backing up shell secrets..."
mkdir -p "$USB_DRIVE/secrets"
cp ~/.config/shell/secrets "$USB_DRIVE/secrets/" 2>/dev/null || echo "No shell secrets found"
```

### Backup Projects Directory (Optional)
```bash
echo "Backing up projects directory..."
if [ -d ~/projects ]; then
    cp -r ~/projects "$USB_DRIVE/"
    echo "Projects backed up successfully"
else
    echo "No projects directory found, skipping"
fi
```

### Backup Music Files (Optional)
```bash
echo "Backing up selected music files..."
if [ -d ~/Music ]; then
    mkdir -p "$USB_DRIVE/Music"
    
    # Define directories to exclude from sync
    exclude_dirs=(
        "fussell-paul" 
        "harris-robert" 
        "keynes-john-maynard" 
        "mantel-hilary" 
        "melville-herman" 
        "trollope-anthony" 
        "worthen-molly"
    )
    
    # Sync Music directory with exclusions
    rsync -av --delete "${exclude_dirs[@]/#/--exclude=}" \
        --exclude="*.aax" \
        --exclude=".git" \
        ~/Music/ "$USB_DRIVE/Music/"
    
    echo "Music files backed up (with exclusions)"
fi
```

## Verification

### Check Backup Contents
```bash
echo "Verifying backup contents..."
ls -la "$USB_DRIVE/"

# Check critical directories
for dir in utono ssh-backup; do
    if [ -d "$USB_DRIVE/$dir" ]; then
        echo "✓ $dir backed up successfully"
        du -sh "$USB_DRIVE/$dir"
    else
        echo "✗ $dir backup failed"
    fi
done
```

### Test File Access
```bash
# Verify some key files are accessible
echo "Testing file access..."
ls -la "$USB_DRIVE/utono/install/cachyos/" 2>/dev/null && echo "✓ CachyOS configs accessible" || echo "✗ CachyOS configs missing"
ls -la "$USB_DRIVE/ssh-backup/id_ed25519" 2>/dev/null && echo "✓ SSH keys accessible" || echo "✗ SSH keys missing"
```

## Important Notes

### FAT32 Limitations
- **No symlinks**: rsync with `-L` flag follows symlinks and copies actual files
- **Case insensitive**: File names may be modified
- **File size limit**: 4GB maximum per file

### Security Considerations
- **SSH keys**: Stored in plaintext on USB drive
- **Secrets**: Shell secrets file contains sensitive information
- **Physical security**: Keep USB drive secure during transport

### Next Steps
After creating the backup:
1. Safely eject the USB drive: `udisksctl unmount -b /dev/sda`
2. Proceed to [01-keyboard-layout.md](01-keyboard-layout.md)
3. Boot target machine with CachyOS installation media
4. Have this USB drive ready for the installation process

## Recovery Usage

On the target machine, mount and restore files:
```bash
# Mount the backup drive
udisksctl mount -b /dev/sda

# Restore utono directory
mkdir -p ~/utono
chattr -V +C ~/utono
rsync -av /run/media/mlj/8C8E-606F/utono/ ~/utono/

# Restore SSH keys
rsync -av /run/media/mlj/8C8E-606F/ssh-backup/ ~/.ssh/
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
```

This USB drive now contains everything needed to restore your configuration on a fresh CachyOS installation.
