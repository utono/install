# CachyOS Install Guide

## Format USB drive and sync USB drive's utono directory

```shell
paru -Sy udisks2
wipefs --all /dev/sda
sudo mkfs.fat -F 32 /dev/sda  
udisksctl mount -b /dev/sda  
rsync -avh --progress $HOME/utono /run/media/mlj/8C8E-606F
```

## Configure keyboard

```shell
Ctrl + Alt + F3
sudo loadkeys dvorak  
mkdir -p $HOME/utono  
chattr -V +C $HOME/utono
cd $HOME/utono
git clone https://github.com/utono/rpd.git
cd rpd/  
chmod +x keyd-configuration.sh  
sh $HOME/utono/rpd/keyd-configuration.sh $HOME/utono/rpd  
loadkeys real_prog_dvorak
cat /etc/vconsole.conf  
nvim /etc/vconsole.conf  
    KEYMAP=real_prog_dvorak
mkinitcpio -P
git remote -v
git remote set-url origin git@github.com:utono/rpd.git
git remote -v
reboot
```

## Sync USB drive's utono directory

```shell
mkdir -p $HOME/utono
chattr -V +C $HOME/utono
udisksctl mount -b /dev/sda
cd /run/media/mlj/8C8E-606F
rsync -avh --progress utono $HOME/utono
cd /run/media/mlj/8C8E-606F/utono/install/cachyos
sh sync-utono.sh /run/media/mlj/8C8E-606F/utono
```

## Install Essential Packages As User

```shell
paru -Syy
cd $HOME/utono
sh $HOME/utono/install/paclists/install_packages.sh feb-2025.csv
```

## stow dotfiles

```shell
cd $HOME/tty-dotfiles
stow --verbose=2 --no-folding bin-mlj git kitty shell starship -n
stow --verbose=2 --no-folding yazi -n
```

## Configure zsh

```shell
cd
ls -al .zshrc
mv .zshrc .zshrc.cachyos.bak
ln -sf $HOME/.config/shell/profile .zprofile  
chsh -s /usr/bin/zsh  
logout
```
Log in

## Configure ssh

```shell
cd $HOME/utono/ssh
chmod +x sync-ssh-keys.sh
./sync-ssh-keys.sh $HOME/utono
ssh-add $HOME/.ssh/id_ed25519
ssh-add -l
```

Helpful commands for ssh configuration:

```shell
    source ~/tty-dotfiles/shell/.config/shell/exports
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
    echo $SSH_AUTH_SOCK
    systemctl --user enable --now ssh-agent
    systemctl --user status ssh-agent
    systemctl --user daemon-reexec
    systemctl --user daemon-reload
```

## Clone repositories and link hyprland settings:

```shell
cd $HOME/utono/user-config
chmod +x utono-clone-repos.sh
sh $HOME/utono/user-config/utono-clone-repos.sh $HOME/utono
sh $HOME/utono/user-config/rsync-delete-repos-for-new-user.sh 
sh $HOME/utono/user-config/link-cachyos-hyprland-settings.sh
ls -al $HOME/.config
```

Optional:

```shell
    cd $HOME/utono/cachyos-hyprland-settings  
    git branch -r  
    git fetch upstream  
    git merge upstream/master --allow-unrelated-histories  
    git add <file_with_conflicts_removed>  
    git commit  
```

## Configure Snapper

### List Existing Btrfs Subvolumes

To display the current Btrfs subvolumes, run:

```shell
sudo btrfs subvolume list /
```

Example output:

```plaintext
ID 256 gen 95 top level 5 path @
ID 257 gen 95 top level 5 path @home
ID 258 gen 90 top level 5 path @.snapshots
```

### Check Btrfs Mount Points

To verify the mounted Btrfs subvolumes, use:

```shell
findmnt -nt btrfs
```

Example output:

```plaintext
/            /dev/nvme0n1p2[/@]            btrfs rw,noatime,compress=zstd
/home        /dev/nvme0n1p2[/@home]        btrfs rw,noatime,compress=zstd
/.snapshots  /dev/nvme0n1p2[/@.snapshots]  btrfs rw,noatime,compress=zstd
```

### Ensure Subvolume Setup

Ensure the `@` subvolume is mounted at `/`, and `@.snapshots` exists. If `@.snapshots` is missing, create it:

```shell
sudo btrfs subvolume create /.snapshots
```

### Create a Snapper Configuration

Create a Snapper configuration for the root (`/`) filesystem:

```shell
sudo snapper -c root create-config /
```

### List Available Snapper Configurations

These correspond to the system locations where Snapper manages snapshots:

```shell
ls /etc/snapper/configs/
```

Example output:

```plaintext
root
home
```

### List Snapshots for a Specific Configuration

To display existing snapshots, including their IDs, timestamps, descriptions, and types:

```shell
sudo snapper -c root list
```

Example output:

```plaintext
# | Type   | Pre # | Date                     | Cleanup  | Description     
---+--------+-------+--------------------------+----------+-----------------
0  | single |       | 2025-03-14T12:01:23      |          | current         
1  | pre    |       | 2025-03-14T13:05:10      | number   | pacman -S htop  
2  | post   | 1     | 2025-03-14T13:05:15      | number   | pacman -S htop  
```

### Set Permissions

```shell
sudo chmod 750 /.snapshots
sudo chown :mlj /.snapshots
```

### Configure Snapper

Edit the Snapper configuration file:

```shell
sudo nvim /etc/snapper/configs/root
```

Add or modify the following settings:

```plaintext
ALLOW_USERS="mlj"
TIMELINE_CREATE="yes"
TIMELINE_CLEANUP="yes"
NUMBER_CLEANUP="yes"
NUMBER_MIN_AGE="1800"
NUMBER_LIMIT="10"
NUMBER_LIMIT_IMPORTANT="5"
```

### Enable Systemd Timers for Snapshots

To ensure regular snapshot creation and cleanup, enable the necessary systemd timers:

```shell
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer
```

### Enable GRUB Integration

This ensures that new snapshots appear in the GRUB boot menu automatically:

```shell
sudo systemctl enable --now grub-btrfsd
```

### Update GRUB Configuration

This command generates a new GRUB boot configuration file (`grub.cfg`) and saves it to `/boot/grub/grub.cfg`. If `grub-btrfs` is enabled, it detects Btrfs snapshots and adds them to the GRUB menu for rollback options:

```shell
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

If GRUB does not detect installed OSes:

```shell
sudo os-prober
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

If `os-prober` is disabled, enable it in `/etc/default/grub`:

```plaintext
GRUB_DISABLE_OS_PROBER=false
```

Ensure `grub-btrfsd` is running:

```shell
sudo systemctl enable --now grub-btrfsd
```

### Install htop (Example)

```shell
sudo pacman -S htop
```

### List Available Snapshots Again

```shell
sudo snapper -c root list
```

Example output:

```plaintext
# | Type   | Pre # | Date                     | Cleanup | Description
---+--------+-------+--------------------------+---------+------------
0  | single |       | 2025-03-14T12:01:23      |         | current
1  | pre    |       | 2025-03-14T13:05:10      | number  | pacman -S htop
2  | post   | 1     | 2025-03-14T13:05:15      | number  | pacman -S htop
```

### Perform a System Rollback

Reboot your system and select snapshot `0` in GRUB.
After booting into snapshot `0`, permanently revert your system:

```shell
sudo snapper -c root rollback 1
reboot
```

### Create a Manual Snapshot

Before performing a system update, create a manual snapshot:

```shell
sudo snapper -c root create --description "Before System Update"
```

## Configure $HOME/Music

### Create Music Directory

Ensure the `Music` directory exists and disable copy-on-write (CoW):

```shell
mkdir -p $HOME/Music
chattr -V +C $HOME/Music
```

### Sync Music Files

Navigate to the external drive and sync selected artist directories to `Music`:

```shell
cd /run/media/mlj/956A-D24E/Music
rsync -avh --progress ./{fussell-paul,harris-robert,mantel-hilary,shakespeare-william} $HOME/Music
```

If necessary, re-sync `harris-robert` separately:

```shell
rsync -avh --progress ./harris-robert $HOME/Music
```

## Configure Touchpad

### Verify Touchpad Device

Reboot your system and check available input devices:

```shell
hyprctl devices
```

### Configure Keybinding

Edit the user keybindings configuration:

```shell
nvim $HOME/.config/hypr/config/user-keybinds.conf
```

Uncomment the following line and replace `xxxx:xx-xxxx:xxxx-touchpad` with the correct touchpad identifier:

```plaintext
bind = $mainMod, space, exec, $hyprBin/touchpad_hyprland.sh "xxxx:xx-xxxx:xxxx-touchpad"
```

### Update Touchpad Script

If necessary, edit the touchpad script:

```shell
nvim $HOME/tty-dotfiles/hypr/.config/hypr/bin/touchpad_hyprland.sh
```

## Bluetuith - Connecting Sonos Speakers

### Pairing Instructions

Before using Bluetuith, press the **Bluetooth pairing button** on the Sonos speakers to enable pairing mode.

### Verify and Manage Bluetooth Service

Check the status of the Bluetooth service:

```shell
systemctl status bluetooth
```

If necessary, restart the service:

```shell
systemctl restart bluetooth
```

Enable Bluetooth service to start on boot:

```shell
sudo systemctl enable bluetooth
```

### Debugging Bluetooth Issues

Check recent logs for Bluetooth-related messages:

```shell
journalctl -u bluetooth --no-pager --since "1 hour ago"
```

Inspect kernel messages for Bluetooth-related events:

```shell
dmesg | grep -i bluetooth
```

Display Bluetooth controller details:

```shell
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

```shell
cd /etc/sysctl.d
```

Copy the system configuration file:

```shell
cp $HOME/utono/system-config/etc/sysctl.d/99-sysrq.conf /etc/sysctl.d/
```

Apply the new sysctl settings:

```shell
sysctl --system
```

Verify the current Sysrq value:

```shell
cat /proc/sys/kernel/sysrq
```

## Configure /etc/systemd/logind.conf.d/

### Create Configuration Directory

Ensure the directory exists:

```shell
mkdir -p /etc/systemd/logind.conf.d
```

Navigate to the directory:

```shell
cd /etc/systemd/logind.conf.d
```

### Copy Configuration File

Copy the lid behavior configuration:

```shell
cp $HOME/utono/system-config/etc/systemd/logind.conf.d/lid-behavior.conf /etc/systemd/logind.conf.d
```

### Apply Changes

Restart the systemd-logind service:

```shell
systemctl restart systemd-logind
```

### Verify Configuration

Check the current session's idle action setting:

```shell
loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') --property=IdleAction
```

Check the lid switch behavior:

```shell
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

```shell
cat /etc/sddm.conf
```

Ensure autologin settings are applied:

```shell
sudo mkdir -p /etc/sddm.conf.d
```

Create the autologin configuration:

```shell
echo -e "[Autologin]\nUser=mlj\nSession=hyprland" | sudo tee /etc/sddm.conf.d/autologin.conf
```

### (Optional) Disable and Mask SDDM

To disable and prevent SDDM from starting:

```shell
sudo systemctl disable sddm  
sudo systemctl mask sddm  
```

### Restart SDDM and Reboot

```shell
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
