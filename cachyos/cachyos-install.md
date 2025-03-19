# CachyOS Install Guide

## Format USB drive and sync USB drive's utono directory

```bash
sudo loadkeys dvorak  
paru -Sy udisks2
wipefs --all /dev/sda
sudo mkfs.fat -F 32 /dev/sda  
udisksctl mount -b /dev/sda  
rsync -avh --progress $HOME/utono /run/media/mlj/8C8E-606F
```

Since your destination is a FAT32-formatted USB drive (mkfs.fat -F 32), symlinks are not supported.
Thus, using -l has no effect, and you should either:

    - Let rsync follow the symlinks automatically.
    - Use -L if you want to ensure the linked files are copied.

## Create new user

```bash
sudo useradd -m -G wheel -s /usr/bin/zsh newuser
sudo passwd newuser
```

## Delete user
```bash
sudo userdel -r newuser
```

## Configure keyboard
```bash
Ctrl + Alt + F3
sudo loadkeys dvorak  
```

## Configure keyboard
```bash
mkdir -p $HOME/utono  
chattr -V +C $HOME/utono
cd $HOME/utono
git clone https://github.com/utono/rpd.git
cd rpd/  
chmod +x $HOME/utono/rpd/keyd-configuration.sh  
sh $HOME/utono/rpd/keyd-configuration.sh $HOME/utono/rpd  
sudo loadkeys real_prog_dvorak
sudo mkinitcpio -P
```

Optional: 
```bash
git remote -v
git remote set-url origin git@github.com:utono/rpd.git
git remote -v
    origin  git@github.com:utono/rpd.git (fetch)
    origin  git@github.com:utono/rpd.git (push)
reboot
```

## Sync USB drive's utono directory
<!--arch-update-->
```bash
cachyos-rate-mirrors
paru -Sy udisks2
udisksctl mount -b /dev/sda
cd /run/media/mlj/8C8E-606F
mkdir -p ~/utono
chattr -V +C ~/utono
rsync -avh --progress utono $HOME/utono
```

## Install Essential Packages As User

```bash
paru -Syy
cd $HOME/utono/install/paclists
bash install_packages.sh mar-2025.csv
```

## stow dotfiles

```bash
mv $HOME/utono/tty-dotfiles $HOME
cd $HOME/tty-dotfiles
mkdir -p $HOME/.local/bin
stow --verbose=2 --no-folding bin-mlj git kitty shell starship yazi -n 2>&1 | tee stow-output.out
```

## Configure zsh

```bash
cd
ls -al .zshrc
mv .zshrc .zshrc.cachyos.bak
ln -sf $HOME/.config/shell/profile .zprofile  
chsh -s /usr/bin/zsh  
logout
```
Log in















## Configure ssh

```bash
cd $HOME/utono/ssh
chmod +x sync-ssh-keys.sh
./sync-ssh-keys.sh "$HOME/utono" 2>&1 | tee -a sync-ssh-keys-output.out
ssh-add $HOME/.ssh/id_ed25519
ssh-add -l
```

Helpful commands for ssh configuration:

```bash
    source ~/tty-dotfiles/shell/.config/shell/exports
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
    echo $SSH_AUTH_SOCK
    systemctl --user enable --now ssh-agent
    systemctl --user status ssh-agent
    systemctl --user daemon-reexec
    systemctl --user daemon-reload
```

## Clone repositories and link hyprland settings:

```bash
cd $HOME/utono/user-config
chmod +x utono-clone-repos.sh
sh $HOME/utono/user-config/utono-clone-repos.sh $HOME/utono
sh "$HOME/utono/user-config/rsync-delete-repos-for-new-user.sh" 2>&1 | tee rsync-delete-output.out
sh "$HOME/utono/user-config/link-cachyos-hyprland-settings.sh" 2>&1 | tee link-hyprland-output.out
ls -al $HOME/.config
reboot
```

Optional:

```bash
    cd $HOME/utono/cachyos-hyprland-settings  
    git branch -r  
    git fetch upstream  
    git merge upstream/master --allow-unrelated-histories  
    git add <file_with_conflicts_removed>  
    git commit  
```

## Configure GRUB to Use 1280x1024 Resolution

### 1. Check Supported Resolutions

Before setting the resolution, verify what your system supports:

1. Reboot and enter the **GRUB command line** by pressing `c` at the GRUB menu.

2. Run the following command:

   ```bash
   videoinfo
   ```

3. Look for **1280x1024** in the output. If it’s listed, proceed to the next step.

### 2. Set GRUB Resolution

Edit the GRUB configuration file:

```bash
sudo nvim /etc/default/grub
```

Find or add the following lines:

```plaintext
GRUB_GFXMODE=3840x2400
GRUB_GFXMODE=600x400
GRUB_GFXMODE=800x600
GRUB_GFXMODE=1024x768
* GRUB_GFXMODE=1280x1024
GRUB_GFXMODE=1600x1200
GRUB_GFXMODE=1920x1440
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

## Configure Snapper

### List Existing Btrfs Subvolumes

To display the current Btrfs subvolumes, run:

```bash
sudo btrfs subvolume list /
```

### Check Btrfs Mount Points

To verify the mounted Btrfs subvolumes, use:

```bash
findmnt -nt btrfs
```

### Ensure Subvolume Setup

Ensure the `@` subvolume is mounted at `/`. If preferred, create a separate snapshots subvolume:

```bash
sudo btrfs subvolume create /@snapshots
```

Verify with:

```bash
sudo btrfs subvolume list /
```

### Create a Snapper Configuration

Create a Snapper configuration for the root (`/`) filesystem:

```bash
sudo snapper -c root create-config /
```

### List Available Snapper Configurations

These correspond to the system locations where Snapper manages snapshots:

```bash
ls /etc/snapper/configs/
```

### List Snapshots for a Specific Configuration

To display existing snapshots, including their IDs, timestamps, descriptions, and types:

```bash
sudo snapper -c root list
```

### Set Permissions

Ensure proper permissions for Snapper to function correctly:

```bash
sudo chmod 750 /@snapshots
sudo chown root:root /@snapshots
ls -al /
```

### Configure Snapper

#### Configure Snapper for Root

Edit the Snapper configuration file:

```bash
sudo nvim /etc/snapper/configs/root
```

Modify or add the following settings:

```plaintext
ALLOW_USERS="mlj"
NUMBER_CLEANUP="yes"
NUMBER_MIN_AGE="1800"
NUMBER_LIMIT="10"
NUMBER_LIMIT_IMPORTANT="5"
TIMELINE_CREATE="yes"
TIMELINE_CLEANUP="yes"
```

### Enable Systemd Timers for Snapshots

To ensure regular snapshot creation and cleanup, enable the necessary systemd timers:

```bash
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer
```

### Enable GRUB Integration

This ensures that new snapshots appear in the GRUB boot menu automatically:

```bash
sudo pacman -Sy --needed grub-btrfs
sudo systemctl enable --now grub-btrfsd
```

### Update GRUB Configuration

Generate a new GRUB boot configuration file:

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

If GRUB does not detect installed OSes:

```bash
sudo os-prober
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

If `os-prober` is disabled, enable it in `/etc/default/grub`:

```bash
GRUB_DISABLE_OS_PROBER=false
```

Ensure `grub-btrfsd` is running:

```bash
sudo systemctl enable --now grub-btrfsd
```

### Perform a System Rollback

Reboot your system and select the desired snapshot in GRUB. After booting into the snapshot, permanently revert your system:

```bash
sudo snapper -c root rollback 1
reboot
```

### Delete Snapper Configuration for Home

To delete the Snapper configuration for home and remove all associated snapshots:

```bash
sudo snapper -c home delete-config
```

To delete all snapshots:

```bash
sudo rm -rf /.snapshots/home
```

If Snapper created subvolumes for snapshots, list and delete them manually:

```bash
sudo btrfs subvolume list / | grep '@snapshots/home'
sudo btrfs subvolume delete /@snapshots/home/*
sudo btrfs subvolume delete /@snapshots/home
```

### Create a Manual Snapshot

Before performing a system update, create a manual snapshot:

```bash
sudo snapper -c root create --description "Before System Update"
```

### Common Snapper Commands

#### Create a Snapshot

```bash
sudo snapper -c root create --description "Snapshot Description"
```

#### List Snapshots

```bash
sudo snapper -c root list
```

#### Delete a Snapshot

```bash
sudo snapper -c root delete <snapshot_number>
```

#### Undo Changes from a Specific Snapshot

```bash
sudo snapper -c root undochange <snapshot_number>
```

#### Rollback to a Specific Snapshot

```bash
sudo snapper -c root rollback <snapshot_number>
```

#### Show Snapshot Details

```bash
sudo snapper -c root status <snapshot_number>
```

#### Compare Two Snapshots

```bash
sudo snapper -c root diff <snapshot_1> <snapshot_2>
```

Before performing a system update, create a manual snapshot:

```bash
sudo snapper -c root create --description "Before System Update"
```

## Configure $HOME/Music

### Create Music Directory

Ensure the `Music` directory exists and disable copy-on-write (CoW):

```bash
mkdir -p $HOME/Music
chattr -V +C $HOME/Music
```

### Sync Music Files

Navigate to the external drive and sync selected artist directories to `Music`:

```bash
cd /run/media/mlj/956A-D24E/Music
rsync -avh --progress ./{fussell-paul,harris-robert,mantel-hilary,shakespeare-william} $HOME/Music
```

If necessary, re-sync `harris-robert` separately:

```bash
rsync -avh --progress ./harris-robert $HOME/Music
```

## Configure Touchpad

### Verify Touchpad Device

Reboot your system and check available input devices:

```bash
hyprctl devices
```

### Configure Keybinding

Edit the user keybindings configuration:

```bash
chmod +x $HOME/tty-dotfiles/hypr/.config/hypr/bin/touchpad_hyprland.sh
nvim $HOME/.config/hypr/config/user-keybinds.conf
```

Uncomment the following line and replace `xxxx:xx-xxxx:xxxx-touchpad` with the correct touchpad identifier:

```plaintext
bind = $mainMod, A, exec, $hyprBin/touchpad_hyprland.sh "ven_04f3:00-04f3:32aa-touchpad"
bind = $mainMod, space, exec, $hyprBin/touchpad_hyprland.sh "xxxx:xx-xxxx:xxxx-touchpad"
```

### Update Touchpad Script

If necessary, edit the touchpad script:

```bash
nvim $HOME/tty-dotfiles/hypr/.config/hypr/bin/touchpad_hyprland.sh
```

## Bluetuith - Connecting Sonos Speakers

### Pairing Instructions

Before using Bluetuith, press the **Bluetooth pairing button** on the Sonos speakers to enable pairing mode.

### Verify and Manage Bluetooth Service

Check the status of the Bluetooth service:

```bash
systemctl status bluetooth
```

If necessary, restart the service:

```bash
systemctl restart bluetooth
```

Enable Bluetooth service to start on boot:

```bash
sudo systemctl enable bluetooth
```

### Debugging Bluetooth Issues

Check recent logs for Bluetooth-related messages:

```bash
journalctl -u bluetooth --no-pager --since "1 hour ago"
```

Inspect kernel messages for Bluetooth-related events:

```bash
dmesg | grep -i bluetooth
```

Display Bluetooth controller details:

```bash
bluetoothctl show
```

## Configure /etc/sysctl.d/

### Log in as Root

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
cp $HOME/utono/system-config/etc/sysctl.d/99-sysrq.conf /etc/sysctl.d/
```

Apply the new sysctl settings:

```bash
sysctl --system
```

Verify the current Sysrq value:

```bash
cat /proc/sys/kernel/sysrq
```

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
cp $HOME/utono/system-config/etc/systemd/logind.conf.d/lid-behavior.conf /etc/systemd/logind.conf.d
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

## Configure SDDM

### Configure SDDM Xsetup

```bash
cd /usr/share/sddm/scripts/
cat Xsetup  # View current Xsetup script
cp Xsetup Xsetup.bak  # Backup existing Xsetup

# Copy the custom Xsetup script
cp -i $HOME/utono/system-config/sddm/usr/share/sddm/scripts/Xsetup /usr/share/sddm/scripts/

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

### Configure sddm.conf

View existing SDDM configuration:

```bash
cat /etc/sddm.conf
```

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

cd $HOME/utono/rpd  
hyprctl binds >> hyprctl-binds.md  

hyprctl monitors  
hyprctl keyword monitor ,1920x1200,,  
hyprctl keyword input:kb_variant dvorak  
(Optional: Reset keyboard layout)  

hyprctl keyword input:kb_variant ""  
hyprctl keyword input:kb_layout real_prog_dvorak  

## Terminal Adjustments  

**Open terminal:** Meta + Enter  

**Alacritty Font Adjustments**  

Control + Equals  
Control + Minus  
Control + Zero  

## Audio Configuration

pacman -Qi sof-firmware  
alsamixer  

**Steps:**  
1. Press F6  
2. Select sof-firmware if available  

### SSH Configuration  

chmod 700 $HOME/.ssh  
find $HOME/.ssh -type f -name "id_*" -exec chmod 600 {} \;  
chmod 0600 $HOME/.ssh/id_ed25519  

cd $HOME/utono/ssh/.config/systemd/user
ls -al
systemctl --user enable --now ssh-agent
systemctl --user status ssh-agent
systemctl --user daemon-reexec
systemctl --user daemon-reload
pgrep ssh-agent  
ssh-add -l  
ssh-add $HOME/.ssh/id_rsa  

sudo nvim /etc/ssh/sshd_config *(Ensure PermitRootLogin is configured correctly)*  

## pacman

sudo reflector --country 'United States' --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Qe > $HOME/utono/install/paclists/explicitly-installed.csv
systemctl list-units --type=service all > $HOME/utono/install/cachyos/services-all.md
systemctl list-units --type=service > $HOME/utono/install/cachyos/services-active.md
systemctl --user list-units --type=service --all
systemctl --user status <service_name>.service
```
