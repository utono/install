# CachyOS Install Guide

---

## Install Essential Packages As User

xps17-2 login: mlj
Password:

```bash
paru -Syy
cd $HOME/utono/install/paclists
chmod +x install_packages.sh
bash install_packages.sh 2025.csv
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

