# CachyOS Install Guide

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

## Summary

This guide transfers your Arch Linux configuration from `xps17-4tb.local` to `xps13.local` using a USB drive as an intermediate storage medium. The process handles symlinks properly for FAT32 drives and includes optimizations for Btrfs filesystems on the destination.

---

## Configure keyboard
```
cd $HOME/utono/rpd
chmod +x $HOME/utono/rpd/keyd-configuration.sh  
bash $HOME/utono/rpd/keyd-configuration.sh $HOME/utono/rpd
sudo loadkeys real_prog_dvorak
sudo mkinitcpio -P
sudo loadkeys real_prog_dvorak
sudo systemctl restart keyd
reboot
```

Optional: 
```bash
# git clone https://github.com/utono/rpd.git
git remote -v
git remote set-url origin git@github.com:utono/rpd.git
git remote -v
    origin  git@github.com:utono/rpd.git (fetch)
    origin  git@github.com:utono/rpd.git (push)
reboot
```

## Install Essential Packages As User

xps17-2 login: mlj
Password:

```bash
paru -Syy
cd $HOME/utono/install/paclists
chmod +x install_packages.sh
bash install_packages.sh 2025.csv
```

## Configure utono repos

```bash
mkdir -p ~/projects
chattr -V +C ~/projects/
cp -r /run/media/mlj/8C8E-606F/utono/gloss-browser ~/projects
bash "$HOME/utono/user-config/rsync-delete-repos-for-new-user.sh" 2>&1 | tee rsync-delete-output.out
ls -al $HOME/.config
cd ~/.config
rm -rf nvim
mv ~/utono/nvim-code/ nvim

    Or, as an alternatives:

        git clone --config remote.origin.fetch='+refs/heads/*:refs/remotes/origin/*' https://github.com/utono/nvim-temp.git nvim

nvim
# On DEST_HOST:
ln -sf ~/utono/kitty-config/.config/kitty ~/.config/kitty
ln -sf ~/utono/glosses-nvim/ ~/.config/glosses-nvim
ln -sf ~/utono/xc/nvim ~/.config/nvim-xc
```

## stow dotfiles

```bash
cd $HOME/tty-dotfiles
mkdir -p $HOME/.local/bin
# https://github.com/ahkohd/eza-preview.yazi
trash ~/.config/mako
stow --verbose=2 --no-folding bat bin-mlj git ksb mako starship systemd -n 2>&1 | tee stow-output.out
vim ~/.config/mako/config
systemctl --user enable --now mako
systemctl --user status mako
notify-send "Test" "Notification working"
# stow --verbose=2 --no-folding yazy 2>&1 | tee stow-output.out
cd $HOME/utono
stow --verbose=2 --no-folding shell-config -n 2>&1 | tee stow-output.out
# ya pkg list
# ya pkg add ahkohd/eza-preview
# ya pkg add h-hg/yamb
```

## Configure zsh

```bash
cd
ls -al .zshrc
mv .zshrc .zshrc.cachyos.bak
ln -sf $HOME/.config/shell/profile .zprofile  
chsh -s /usr/bin/zsh  
exit
```
Log in

## Configure ssh

```bash
cd $HOME/utono/ssh
chmod +x *.sh
./sync-ssh-keys.sh "$HOME/utono" 2>&1 | tee -a sync-ssh-keys-output.out

    source ~/.config/shell/exports
        export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
        echo $SSH_AUTH_SOCK
    systemctl --user enable --now ssh-agent
    systemctl --user status ssh-agent
    systemctl --user daemon-reexec
    systemctl --user daemon-reload

ssh-add $HOME/.ssh/id_ed25519
ssh-add -l
```

## Configure GRUB to Use 1280x1024 Resolution

### 1. Check Supported Resolutions

Before setting the resolution, verify what your system supports:

1. Reboot and enter the **GRUB command line** by pressing `c` at the GRUB menu.

2. When the GRUB menu appears, press 'c' to open the the GRUB command line, then run:

   ```bash
   videoinfo
   ```

3. Look for **1280x1024** in the output. If it’s listed, proceed to the next step.

### 2. Set GRUB Resolution

Edit the GRUB configuration file:

```bash
sudo vim /etc/default/grub
```

Find or add the following lines:

```plaintext
GRUB_GFXMODE=3840x2400
GRUB_GFXMODE=600x400
GRUB_GFXMODE=800x600
GRUB_GFXMODE=1024x768
GRUB_GFXMODE=1280x1024
GRUB_GFXMODE=1600x1200
* GRUB_GFXMODE=1920x1440
GRUB_GFXPAYLOAD_LINUX=keep
```

### 3. Apply Changes

Regenerate the GRUB configuration file:

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### 4. Reboot

Restart your system to apply the changes:

```bash
reboot
```

This should force GRUB to use **1920x1440** resolution. If it doesn’t work, double-check `videoinfo` to confirm that your system supports it.

---
## Configure /etc/sysctl.d/

### Login as user 'root'
```
xps17-2 login: root
Password:
```

Ensure you have root privileges before proceeding.

### Reference

For more details on emergency reboot shortcuts, see:

[Arch Wiki: Keyboard Shortcuts](https://wiki.archlinux.org/title/Keyboard_shortcuts)

**Reboot Even If System Is Utterly Broken**

### Configure Sysrq Settings

Navigate to the sysctl configuration directory:

```bash
cd /etc/sysctl.d
```

Copy the system configuration file:

```bash
cp /home/mlj/utono/system-config/etc/sysctl.d/99-sysrq.conf /etc/sysctl.d/
```

Apply the new sysctl settings:

```bash
sysctl --system
```

Verify the current Sysrq value:

```bash
cat /proc/sys/kernel/sysrq
```
---
## 🔐 Sudoers Rule for Touchpad Toggle

To allow `$HOME/utono/cachyos-hyprland-settings/etc/skel/.config/hypr/bin/toggle-touchpad.sh` 
to disable/enable the touchpad **without prompting for a password**, this file must exist:

```
/etc/sudoers.d/touchpad-toggle

    mlj ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/bus/i2c/drivers/i2c_hid_acpi/unbind, /usr/bin/tee /sys/bus/i2c/drivers/i2c_hid_acpi/bind

```

* Replace `mlj` with your actual username if needed.
* This allows passwordless writing to the unbind/bind control files for your I²C touchpad device.

```
sudo cp ~/utono/system-config/etc/sudoers.d/touchpad-toggle /etc/sudoers.d
```
---

## Configure /etc/systemd/logind.conf.d/

### Create Configuration Directory

Ensure the directory exists:

```bash
mkdir -p /etc/systemd/logind.conf.d
```

Navigate to the directory:

```bash
cd /etc/systemd/logind.conf.d
```

### Copy Configuration File

Copy the lid behavior configuration:

```bash
cp /home/mlj/utono/system-config/etc/systemd/logind.conf.d/lid-behavior.conf /etc/systemd/logind.conf.d
```

### Apply Changes

Restart the systemd-logind service:

```bash
systemctl restart systemd-logind
```

### Verify Configuration

Check the current session's idle action setting:

```bash
loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') --property=IdleAction
```

Check the lid switch behavior:

```bash
loginctl show-session | grep HandleLidSwitch
```

Expected output:

```plaintext
HandleLidSwitch=ignore
HandleLidSwitchDocked=ignore
```
---
## Configure SDDM

### Configure SDDM Xsetup

```bash
cd /usr/share/sddm/scripts/
cat Xsetup  # View current Xsetup script
cp Xsetup Xsetup.bak  # Backup existing Xsetup

# Copy the custom Xsetup script
cp -i /home/mlj/utono/system-config/usr/share/sddm/scripts/Xsetup /usr/share/sddm/scripts/

cat Xsetup  # Verify new Xsetup script
```

Updated `Xsetup` content:

```bash
#!/bin/sh

# Set display resolution and refresh rate
xrandr --output eDP-1 --mode 1920x1200 --rate 59.98

# Set keyboard layout environment variable
export XKB_DEFAULT_LAYOUT=real_prog_dvorak

# Apply keyboard layout settings
setxkbmap -layout real_prog_dvorak -v
```

---
### Configure sddm.conf

View existing SDDM configuration:

```bash
cat /etc/sddm.conf
```
[Autologin]
Session=hyprland

Ensure autologin settings are applied:

```bash
sudo mkdir -p /etc/sddm.conf.d
```

### (Optional) Create the autologin configuration:

```bash
echo -e "[Autologin]\nUser=mlj\nSession=hyprland" | sudo tee /etc/sddm.conf.d/autologin.conf
```

### (Optional) Disable and Mask SDDM

To disable and prevent SDDM from starting:

```bash
sudo systemctl disable sddm  
sudo systemctl mask sddm  
```

### Restart SDDM and Reboot

```bash
sudo systemctl restart sddm  
reboot  
```

## Hyprland

```bash
sh "$HOME/utono/user-config/link-cachyos-hyprland-settings.sh" 2>&1 | tee link-hyprland-output.out
# cat ~/.config/mako
# trash ~/.config/mako
# stow --verbose=2 --no-folding mako -n 2>&1 | tee stow-output.out
```

Optional:

```bash
    cd $HOME/utono/cachyos-hyprland-settings  
    git branch -r  
    git remote -v
    # git remote set-url origin git@github.com:utono/cachyos-hyprland-settings.git
    git remote add upstream git@github.com:CachyOS/cachyos-hyprland-settings.git
    git branch -r  
    git fetch upstream  
    git merge upstream/master --allow-unrelated-histories  
    git add <file_with_conflicts_removed>  
    git commit  
```
```bash
vim ~/.config/hypr/hyprland.conf
cd ~/.config/hypr/bin
chmod +x *.sh
cd ~/.config/hypr/scripts/
chmod +x *
reboot
```

## systemd services

```bash
# Reload systemd user units (required if you've changed the .service file)
systemctl --user daemon-reexec
systemctl --user daemon-reload

fd -e sh -H -x chmod -v +x {} ~/tty-dotfiles
systemctl --user enable --now watch-clipboard.service

# Restart your service
systemctl --user restart watch-clipboard.service

# (Optional) Check status
systemctl --user status watch-clipboard.service

```
## Firefox
about:config
browser.gesture.pinch.threshold     50

