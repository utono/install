```bash
# CachyOS Install Guide

## USB Drive

paru -Sy udisks2
wipefs --all /dev/sda
sudo mkfs.fat -F 32 /dev/sda  
udisksctl mount -b /dev/sda  
rsync -avh --progress $HOME/utono /run/media/mlj/8C8E-606F

## Live ISO

paru -Syy
mkdir -p $HOME/utono
chattr -V +C $HOME/utono
udisksctl mount -b /dev/sda
cd /run/media/mlj/8C8E-606F/utono

rsync -avh --progress ./{install,ssh,system-config,user-config} $HOME/utono
rsync -avh --progress ./tty-dotfiles $HOME
rsync -avh --progress ./kickstart-modular $HOME/.config/nvim
rsync -avh --progress ./mpv-utono $HOME/.config/mpv

cd $HOME/tty-dotfiles
stow --verbose=2 --no-folding bin-mlj git kitty shell starship -n
stow --verbose=2 --no-folding yazi -n

cd
ls -al .zshrc
mv .zshrc .zshrc.cachyos.bak
ln -sf $HOME/.config/shell/profile .zprofile  
chsh -s /usr/bin/zsh  

logout

$HOME/utono/user-config/utono-clone-repos.sh $HOME/utono
mkdir -p $HOME/Music
chattr -V +C $HOME/Music
cd /run/media/mlj/956A-D24E/Music
rsync -avl --progress ./{fussell-paul,harris-robert,mantel-hilary,shakespeare-william} $HOME/Music
rsync -avl --progress ./harris-robert $HOME/Music
cd ../utono
rsync -avh --progress ./{install,ssh,system-config,user-config} $HOME/utono
cd $HOME/utono/ssh
chmod +x sync-ssh-keys.sh
./sync-ssh-keys.sh $HOME/utono
ssh-add $HOME/.ssh/id_ed25519
ssh-add -l

eval $(ssh-agent)
ssh-add $HOME/.ssh/id_ed25519

## Root Setup

**Switch to TTY:**  
Ctrl + Alt + F3
x17 login: root  
Password:  
nmtui

### x17 login: root  keyd-configuration.sh

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
reboot

### x17 login: mlj  Install Essential Packages  

    error: can't install AUR package as root
    Login in as mlj to use paru

x17 login: mlj
Password:  

paru -Syy
mkdir -p $HOME/utono
chattr -V +C $HOME/utono
cd $HOME/utono
udisksctl mount -b /dev/sda
cd /run/media/mlj/8C8E-606F/utono
rsync -avh --progress install ssh system-config user-config $HOME/utono
rsync -avh --progress tty-dotfiles $HOME
<!--git clone https://github.com/utono/install.git-->
sh $HOME/utono/install/paclists/install_packages.sh feb-2025.csv

(Optional: Install other fonts)

paru -S ttf-firacode-nerd  

exit

### x17 login: root  shell

Login as root until zsh is configured

x17 login: root
Password:  

mkdir -p $HOME/utono
chattr -V +C $HOME/utono
udisksctl mount -b /dev/sda
cd /run/media/mlj/8C8E-606F/utono
rsync -avh --progress ssh system-config user-config $HOME/utono
rsync -avh --progress tty-dotfiles $HOME
cd $HOME/tty-dotfiles
stow --verbose=2 --no-folding bin-mlj git kitty shell starship
stow --verbose=2 --no-folding yazi
cd
ls -al .zshrc
mv .zshrc .zshrc.cachyos.bak
ln -sf $HOME/.config/shell/profile .zprofile  
chsh -s /usr/bin/zsh  
logout

### x17 login: root  SSH

cd $HOME/utono/ssh
chmod +x sync-ssh-keys.sh
./sync-ssh-keys.sh $HOME/utono
ssh-add $HOME/.ssh/id_ed25519
ssh-add -l

### x17 login: root  SDDM Configuration

cd /usr/share/sddm/scripts/
cp Xsetup Xsetup.bak
cd $HOME/utono
<!--git clone https://github.com/utono/system-config.git-->
cd system-config/sddm/usr/share/sddm/scripts
cat Xsetup
cp -i Xsetup /usr/share/sddm/scripts/

    #!/bin/sh
    
    # Set display resolution and refresh rate
    xrandr --output eDP-1 --mode 1920x1200 --rate 59.98
    
    # Set keyboard layout environment variable
    export XKB_DEFAULT_LAYOUT=real_prog_dvorak
    
    # Apply keyboard layout settings
    setxkbmap -layout real_prog_dvorak -v

cat /etc/sddm.conf

    [Autologin]
    User=mlj
    Session=hyprland

    sudo mkdir -p /etc/sddm.conf.d
    echo -e "[Autologin]\nUser=mlj\nSession=hyprland" | sudo tee /etc/sddm.conf.d/autologin.conf
    
    .. (Optional) Disable and mask sddm
    [root@archiso /]# systemctl disable sddm  
    [root@archiso /]# systemctl mask sddm  

sudo systemctl restart sddm  
reboot  

### x17 login: root  /etc/sysctl.d/

x17 login: root
Password:  

See https://wiki.archlinux.org/title/Keyboard_shortcuts

    "Reboot Even If System Utterly Broken"

cd /etc/sysctl.d
cp $HOME/utono/system-config/etc/sysctl.d/99-sysrq.conf /etc/sysctl.d/
sysctl --system
cat /proc/sys/kernel/sysrq

### x17 login: root  /etc/systemd/logind.conf.d/

x17 login: root
Password:  

mkdir -p /etc/systemd/logind.conf.d
cd /etc/systemd/logind.conf.d
cp $HOME/utono/system-config/etc/systemd/logind.conf.d/lid-behavior.conf /etc/systemd/logind.conf.d
systemctl restart systemd-logind
loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') --property=IdleAction
loginctl show-session | grep HandleLidSwitch

    HandleLidSwitch=ignore
    HandleLidSwitchDocked=ignore

## Login as User

x17 login: mlj
Password:  

### Dotfiles
### /run/media/mlj/8C8E-606F/utono/tty-dotfiles

mkdir -p $HOME/.local/bin
udisksctl mount -b /dev/sda
cd /run/media/8C8E-606F/utono
<!--rsync -avh --progress tty-dotfiles $HOME-->
cd $HOME/tty-dotfiles
stow --verbose=2 --no-folding bin-mlj git kitty shell starship
stow --verbose=2 --no-folding yazi
chmod +x $HOME/tty-dotfiles/bin-mlj/.local/bin/bin-mlj/yt-dlp/*.sh

### Shell

cd $HOME  
ls -al .zshrc
mv .zshrc .zshrc.cachyos.bak
ln -sf $HOME/.config/shell/profile .zprofile  
chsh -s /usr/bin/zsh  
logout

### Music

udisksctl mount -b /dev/sda  
rm -rf $HOME/Music
cd /run/media/mlj/8C8E-606F/Music
rsync -avh --progress ./ $HOME/Music

    -h: Human readable

### SSH Keys
### /run/media/mlj/8C8E-606F/utono/ssh

mkdir -p $HOME/utono
chattr -V +C $HOME/utono
cd /run/media/mlj/8C8E-606F/utono
rsync -avh --progress ssh $HOME/utono
cd $HOME/utono/ssh
chmod +x sync-ssh-keys.sh
./sync-ssh-keys.sh $HOME/utono
ssh-add $HOME/.ssh/id_ed25519
ssh-add -l

    Could not open a connection to your authentication agent.

    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
    echo $SSH_AUTH_SOCK
    systemctl --user enable --now ssh-agent
    systemctl --user status ssh-agent
    systemctl --user daemon-reexec
    systemctl --user daemon-reload


### Clone/sync utono repositories and move them to proper locations

cd $HOME/utono
udisksctl mount -b /dev/sda
cd /run/media/mlj/8C8E-606F/utono
rsync -avh --progress user-config $HOME/utono
<!--git clone https://github.com/utono/user-config.git-->
cd $HOME/utono/user-config
chmod +x utono-clone-repos.sh
sh $HOME/utono/user-config/utono-clone-repos.sh $HOME/utono
sh $HOME/utono/user-config/rsync-delete-repos-for-new-user.sh 
sh $HOME/utono/user-config/link-cachyos-hyprland-settings.sh
ls -al $HOME/.config

.. (Optional)
    cd $HOME/utono/cachyos-hyprland-settings  
    git branch -r  
    git fetch upstream  
    git merge upstream/master --allow-unrelated-histories  
    git add <file_with_conflicts_removed>  
    git commit  

### kitty scrollback

nvim
:Lazy 
lsblk
super+backlslash

### touchpad

reboot
hyprctl devices
nvim $HOME/.config/hypr/config/user-keybinds.conf
    Uncomment bind = $mainMod, space, exec, $hyprBin/touchpad_hyprland.sh "xxxx:xx-xxxx:xxxx-touchpad"

nvim $HOME/tty-dotfiles/hypr/.config/hypr/bin/touchpad_hyprland.sh

    bind = $mainMod, space, exec, $hyprBin/touchpad_hyprland.sh "ven_0488:00-0488:1072-touchpad"

### bluetuith

To pair sonos speakers, press the bluetooth pairing button on the speakers
before using bluetuith.

systemctl status bluetooth
systemctl restart bluetooth
sudo systemctl enable bluetooth
journalctl -u bluetooth --no-pager --since "1 hour ago"
dmesg | grep -i bluetooth
bluetoothctl show









### Hyprland

hyprctl monitors  
hyprctl keyword monitor ,1920x1200,,  
hyprctl keyword input:kb_variant dvorak  
(Optional: Reset keyboard layout)  

hyprctl keyword input:kb_variant ""  
hyprctl keyword input:kb_layout real_prog_dvorak  

### Terminal Adjustments  
**Open terminal:** Meta + Enter  

**Alacritty Font Adjustments**  

Control + Equals  
Control + Minus  
Control + Zero  




---

## Audio Configuration

pacman -Qi sof-firmware  
alsamixer  

**Steps:**  
1. Press F6  
2. Select sof-firmware if available  

---

## Post-Login Setup

### Hyprland

cd $HOME/utono/rpd  
hyprctl binds >> hyprctl-binds.md  

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


sudo reflector --country 'United States' --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Qe > $HOME/utono/install/paclists/explicitly-installed.csv
systemctl list-units --type=service all > $HOME/utono/install/cachyos/services-all.md
systemctl list-units --type=service > $HOME/utono/install/cachyos/services-active.md
systemctl --user list-units --type=service --all
systemctl --user status <service_name>.service
```
