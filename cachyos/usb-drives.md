## usd-drives.md

```
Ctrl + Alt + F3
cachyos-rate-mirrors
sudo pacman -Syu
paru -Sy udisks2
udisksctl mount -b /dev/sda
wipefs --all /dev/sda
sudo mkfs.fat -F 32 /dev/sda  
```

## Configuration Variables
```bash
SOURCE_HOST="xps17-4tb.local"
DEST_HOST="xps13.local"
udisksctl mount -b /dev/sda
USB_DRIVE="/run/media/mlj/8C8E-606F"
```

---

## Phase 1: Backup from Source Machine (xps17-4tb.local)

### Overview
Sync these directories from source machine to USB drive:
- `$HOME/Music`
- `$HOME/projects` 
- `$HOME/utono`

### 1.1 Sync Music Directory

**Note:** This syncs Music with special excludes and sets up git repository for metadata.

```bash
# Verify running on correct machine
echo "Running Music sync on: $(hostname)"

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
    ~/Music/ /run/media/mlj/8C8E-606F/Music/

# Clean up any existing git directory
\rm -rf /run/media/mlj/8C8E-606F/Music/.git

# Verify sync results
ls -al /run/media/mlj/8C8E-606F/Music/

# Initialize git repository for metadata tracking
cd /run/media/mlj/8C8E-606F/Music
git init
git remote add origin git@github.com:utono/ffmetadata.git
git fetch --depth 1 origin
git reset --hard origin/main

# Test sync of shakespeare-william (dry run)
rsync -avh ~/Music/shakespeare-william /run/media/mlj/8C8E-606F/Music/shakespeare-william --dry-run
```

### 1.2 Sync Projects Directory

```bash
echo "Syncing projects directory..."
cp -r ~/projects /run/media/mlj/8C8E-606F/
```

### 1.3 Sync Utono Directory

**Important:** FAT32 USB drives don't support symlinks. Rsync will follow symlinks automatically or use `-L` to ensure linked files are copied.

```bash
echo "Preparing USB drive..."
alias cd8='cd /run/media/mlj/8C8E-606F'
cd8

# Clean and recreate utono directory
\rm -rf utono
mkdir -p utono

# Clone repositories to USB
# Note: Update GitHub token if necessary at https://github.com/settings/tokens
# Edit token in: nvim ~/.config/shell/secrets
sh ~/utono/user-config/utono-clone-repos.sh /run/media/mlj/8C8E-606F/utono

# Copy shell secrets configuration
cp ~/.config/shell/secrets /run/media/mlj/8C8E-606F/utono/shell-config/.config/shell
```

---

## Phase 2: Restore to Destination Machine (xps13.local)

### 2.1 Initial Setup

```bash
echo "Setting up destination machine: $(hostname)"

# Create utono directory with Copy-on-Write disabled (Btrfs optimization)
mkdir -p utono
chattr -V +C utono
```

### 2.2 Sync Utono Configuration

```bash
udisksctl mount -b /dev/sda
# Navigate to USB utono directory
cd /run/media/mlj/8C8E-606F/utono/

# Sync all utono files to home directory
rsync -avh --progress ./ $HOME/utono

# Clean up default directories and recreate with CoW disabled
rm -rf {Documents,Downloads,Music,Pictures,Videos}
mkdir -p {Documents,Downloads,Music,Pictures,Videos}
chattr -V +C {Documents,Downloads,Music,Pictures,Videos}
```

### 2.3 Sync Music Files

```bash
# Navigate to USB Music directory
cd /run/media/mlj/8C8E-606F/Music

# Sync selected music collections
rsync -avh --progress ./{fussell-paul,harris-robert,mantel-hilary,shakespeare-william} $HOME/Music
```

### 2.4 Additional Music Sync (If Needed)

If `harris-robert` collection needs separate syncing:

```bash
echo "Re-syncing harris-robert collection..."
rsync -avh --progress ./harris-robert $HOME/Music
```

---

## Phase 3: Sync Destination with USB Drive

### 3.1 Setup Projects Directory

```bash
# Create projects directory with Copy-on-Write disabled (Btrfs optimization)
mkdir -p ~/projects
chattr -V +C ~/projects/

# Copy gloss-browser project from USB
cp -r /run/media/mlj/8C8E-606F/utono/gloss-browser ~/projects
```

### 3.2 Configure Dotfiles and Repository Sync

```bash
# Run repository sync and cleanup script
bash "$HOME/utono/user-config/rsync-delete-repos-for-new-user.sh" 2>&1 | tee rsync-delete-output.out

# Verify ~/.config directory structure
ls -al $HOME/.config
```

### 3.3 Setup Neovim Configuration

```bash
cd ~/.config

# Remove any existing nvim config
rm -rf nvim

# Move nvim configuration from utono directory
mv ~/utono/nvim-code/ nvim

# Alternative: Clone directly from GitHub
# git clone --config remote.origin.fetch='+refs/heads/*:refs/remotes/origin/*' https://github.com/utono/nvim-temp.git nvim

# Test neovim configuration
nvim
```

### 3.4 Create Configuration Symlinks

```bash
# Link kitty configuration
ln -sf ~/utono/kitty-config/.config/kitty ~/.config/kitty

# Link glosses-nvim configuration
ln -sf ~/utono/glosses-nvim/ ~/.config/glosses-nvim

# Link nvim-xc configuration
ln -sf ~/utono/xc/nvim ~/.config/nvim-xc
```

---

## Summary

This guide transfers your Arch Linux configuration from `xps17-4tb.local` to `xps13.local` using a USB drive as an intermediate storage medium. The process handles symlinks properly for FAT32 drives and includes optimizations for Btrfs filesystems on the destination.

**Phase 1** backs up essential directories from the source machine to USB.
**Phase 2** restores the core utono configuration and music files.
**Phase 3** completes the setup by syncing projects, configuring dotfiles, and establishing symlinks for development environments.
