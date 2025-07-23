# CachyOS Install Guide

## Format USB drive and sync USB drive's utono directory

```bash
sudo loadkeys dvorak  
paru -Sy udisks2
wipefs --all /dev/sda
sudo mkfs.fat -F 32 /dev/sda  
udisksctl mount -b /dev/sda  
# rsync -avh --progress $HOME/utono /run/media/mlj/8C8E-606F -n
cd8
rm -rf utono
mkdir -p utono
sh ~/utono/user-config/utono-clone-repos.sh /run/media/mlj/8C8E-606F/utono
cp -r /run/media/mlj/8C8E-606F/utono/ffmetadata /run/media/mlj/8C8E-606F/Music
rm -rf /run/media/mlj/8C8E-606F/utono/ffmetadata
rsync -avh ~/Music/shakespeare-william /run/media/mlj/8C8E-606F/Music/shakespeare-william --dry-run
# sh ~/utono/user-config/utono-update-repos.sh /run/media/mlj/8C8E-606F/utono
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

## Login as user 'mlj'
```
xps17-2 login: mlj
Password:
```

## Configure keyboard
```bash
Ctrl + Alt + F3
sudo loadkeys dvorak
cachyos-rate-mirrors
sudo pacman -Syu
sudo pacman -S udisks2
udisksctl mount -b /dev/sda
mkdir -p $HOME/utono
chattr -V +C $HOME/utono
cd /run/media/mlj/8C8E-606F/utono/
rsync -avh --progress ./ $HOME/utono
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
git clone --config remote.origin.fetch='+refs/heads/*:refs/remotes/origin/*' https://github.com/utono/rpd.git
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
bash "$HOME/utono/user-config/rsync-delete-repos-for-new-user.sh" 2>&1 | tee rsync-delete-output.out
ls -al $HOME/.config
cd ~/.config
rm -rf nvim
mv ~/utono/nvim-temp/ nvim

    Or, as an alternatives:

        git clone --config remote.origin.fetch='+refs/heads/*:refs/remotes/origin/*' https://github.com/utono/nvim-temp.git nvim

nvim
```

## stow dotfiles

```bash
cd $HOME/tty-dotfiles
mkdir -p $HOME/.local/bin
# https://github.com/ahkohd/eza-preview.yazi
trash ~/.config/mako
stow --verbose=2 --no-folding bat bin-mlj git kitty ksb mako starship yazi -n 2>&1 | tee stow-output.out
cd $HOME/utono/shell-config
stow --verbose=2 --no-folding shell-config -n 2>&1 | tee stow-output.out
ya pkg list
ya pkg add ahkohd/eza-preview
ya pkg add h-hg/yamb
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

## Configure $HOME/Music

### Create Music Directory

Ensure the `Music` directory exists and disable copy-on-write (CoW):

```bash
rm -rf {Documents,Downloads,Music,Pictures,Videos}
mkdir -p {Documents,Downloads,Music,Pictures,Videos}
chattr -V +C {Documents,Downloads,Music,Pictures,Videos}
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

## Configure /etc/sysctl.d/

### Log in as Root

Ensure you have root privileges before proceeding.

### Reference

For more details on emergency reboot shortcuts, see:

[Arch Wiki: Keyboard Shortcuts](https://wiki.archlinux.org/title/Keyboard_shortcuts)

**Reboot Even If System Is Utterly Broken**

## 🔐 Sudoers Rule for Touchpad Toggle

To allow `$HOME/utono/cachyos-hyprland-settings/etc/skel/.config/hypr/bin/toggle-touchpad.sh` to disable/enable the touchpad **without prompting for a password**, this file must exist:

```
/etc/sudoers.d/touchpad-toggle
```

### Contents:

```sudoers
mlj ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/bus/i2c/drivers/i2c_hid_acpi/unbind, /usr/bin/tee /sys/bus/i2c/drivers/i2c_hid_acpi/bind
```

* Replace `mlj` with your actual username if needed.
* This allows passwordless writing to the unbind/bind control files for your I²C touchpad device.

```
cp ~/utono/system-config/etc/sudoers.d/touchpad-toggle /etc/sudoers.d
```
---

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

```bash
sh "$HOME/utono/user-config/link-cachyos-hyprland-settings.sh" 2>&1 | tee link-hyprland-output.out
cat ~/.config/mako
trash ~/.config/mako
stow --verbose=2 --no-folding mako -n 2>&1 | tee stow-output.out
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
nvim ~/.config/hypr/hyprland.conf
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

systemctl --user enable --now watch-clipboard.service

# Restart your service
systemctl --user restart watch-clipboard.service

# (Optional) Check status
systemctl --user status watch-clipboard.service

```
## Bluetuith - Connecting Sonos Speakers

```bash
sudo bluetoothctl
```

## Firefox
about:config
browser.gesture.pinch.threshold     50

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

pacman -Qe > $HOME/utono/install/paclists/explicitly-installed.csv
systemctl list-units --type=service all > $HOME/utono/install/cachyos/services-all.md
systemctl list-units --type=service > $HOME/utono/install/cachyos/services-active.md
systemctl --user list-units --type=service --all
systemctl --user status <service_name>.service
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
chmod +x $HOME/utono/cachyos-hyprland-settings/etc/skel/.config/hypr/bin/touchpad_hyprland.sh
chmod +x $HOME/utono/cachyos-hyprland-settings/etc/skel/.config/hypr/scripts/*
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
nvim $HOME/utono/cachyos-hyprland-settings/etc/skel/.config/hypr/bin/touchpad_hyprland.sh
```


