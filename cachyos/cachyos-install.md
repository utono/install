# CachyOS Install Guide


## Clone Repositories to USB Drive

wipefs --all /dev/sda
sudo mkfs.fat -F 32 /dev/sda  

paru -Syy
paru -Sy udisks2
udisksctl mount -b /dev/sda  
~/utono/user-config/utono-clone-repos.sh ~/utono
rsync -avl --progress ~/Music/{hilary-mantel,william_shakespeare} /run/media/mlj/956A-D24E/utono  

eval $(ssh-agent)
ssh-add ~/.ssh/id_ed25519

## Root Setup

**Switch to TTY:**  
Ctrl + Alt + F3
x17 login: root  
Password:  
nmtui

### Keyboard layout

sudo loadkeys dvorak  
mkdir -p ~/utono  
chattr -V +C ~/utono
cd ~/utono
git clone https://github.com/utono/rpd.git
cd rpd/  
chmod +x keyd-configuration.sh  
sh ~/utono/rpd/keyd-configuration.sh ~/utono/rpd  
loadkeys real_prog_dvorak
cat /etc/vconsole.conf  
nvim /etc/vconsole.conf  
    KEYMAP=real_prog_dvorak
mkinitcpio -P

### Install Essential Packages  

x17 login: mlj
Password:  

paru -Syy
cd ~/utono
git clone https://github.com/utono/install.git
sh ~/utono/install/paclists/install_packages.sh feb-2025.csv

    error: can't install AUR package as root

(Optional: Install other fonts)

paru -S ttf-firacode-nerd  

### SDDM Configuration

cd /usr/share/sddm/scripts/
cp Xsetup Xsetup.bak
cd ~/utono
git clone https://github.com/utono/system-config.git
cd system-config/sddm/usr/share/sddm/scripts
cat Xsetup
cp -i Xsetup /usr/share/sddm/scripts/
cat /etc/sddm.conf
cat /etc/sddm.conf.d/autologin.conf

    sudo mkdir -p /etc/sddm.conf.d
    echo -e "[Autologin]\nUser=mlj\nSession=hyprland" | sudo tee /etc/sddm.conf.d/autologin.conf
    
    .. (Optional) Disable and mask sddm
    [root@archiso /]# systemctl disable sddm  
    [root@archiso /]# systemctl mask sddm  

sudo systemctl restart sddm  
reboot  

### /etc/sysctl.d/

See https://wiki.archlinux.org/title/Keyboard_shortcuts

    "Reboot Even If System Utterly Broken"

cd /etc/sysctl.d
cp ~/utono/system-config/etc/sysctl.d/99-sysrq.conf /etc/sysctl.d/
sysctl --system
cat /proc/sys/kernel/sysrq

### /etc/systemd/logind.conf.d/

mkdir -p /etc/systemd/logind.conf.d
cd /etc/systemd/logind.conf.d
cp ~/utono/system-config/etc/systemd/logind.conf.d/lid-behavior.conf /etc/systemd/logind.conf.d
systemctl restart systemd-logind
loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') --property=IdleAction
loginctl show-session | grep HandleLidSwitch

### /run/media/mlj/8C8E-606F/utono/tty-dotfiles

mkdir -p ~/.local/bin
rsync -avl /run/media/8C8E-606F/utono/tty-dotfiles ~
cd ~/tty-dotfiles
stow --verbose=2 --no-folding bin-mlj git kitty shell starship yazi

### Shell

cd ~  
ls -al .zshrc
    mv .zshrc .zshrc.cachyos.bak
ln -sf ~/.config/shell/profile .zprofile  
chsh -s /usr/bin/zsh  
logout

### /run/media/mlj/8C8E-606F/utono/ssh

udisksctl mount -b /dev/sda  
mkdir -p ~/utono
rsync -avl /run/media/####/utono/ssh ~/utono
cd ~/utono/ssh
chmod +x sync-ssh-keys.sh
./sync-ssh-keys.sh ~/utono
ssh-add ~/.ssh/id_ed25519
ssh-add -l

    Could not open a connection to your authentication agent.

    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
    echo $SSH_AUTH_SOCK
    systemctl --user enable --now ssh-agent
    systemctl --user status ssh-agent
    systemctl --user daemon-reexec
    systemctl --user daemon-reload


### Clone/sync utono repositories and move them to proper locations

cd ~/utono
git clone https://github.com/utono/user-config.git
cd ~/utono/user-config
chmod +x utono-clone-repos.sh
sh $HOME/utono/user-config/utono-clone-repos.sh ~/utono
sh ~/utono/user-config/rsync-delete-repos-for-new-user.sh 








---

## Login as User


### Dotfiles

### Shell

### SSH Keys

### Clone/sync utono repositories and move them to proper locations

## Hyprland Configuration

**Switch to TTY:**  
Ctrl + Alt + F1  

### Hyprland Bindings and Config Sync  

cd ~/utono/user-config
sh ~/utono/user-config/link-cachyos-hyprland-settings.sh
    
    ln -sf ~/utono/cachyos-hyprland-settings/etc/skel/.config/hypr ~/.config/hypr

.. (Optional)
    cd ~/utono/cachyos-hyprland-settings  
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

hyprctl devices
nvim $HOME/tty-dotfiles/hypr/.config/hypr/bin/touchpad_hyprland.sh

    bind = $mainMod, Tab, exec, $hyprBin/touchpad_hyprland.sh ""
    bind = $mainMod, S, exec, $hyprBin/touchpad_hyprland.sh ""

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

cd ~/utono/rpd  
hyprctl binds >> hyprctl-binds.md  

### SSH Configuration  

chmod 700 ~/.ssh  
find ~/.ssh -type f -name "id_*" -exec chmod 600 {} \;  
chmod 0600 ~/.ssh/id_ed25519  

cd ~/utono/ssh/.config/systemd/user
ls -al
systemctl --user enable --now ssh-agent
systemctl --user status ssh-agent
systemctl --user daemon-reexec
systemctl --user daemon-reload
pgrep ssh-agent  
ssh-add -l  
ssh-add ~/.ssh/id_rsa  

sudo nvim /etc/ssh/sshd_config *(Ensure PermitRootLogin is configured correctly)*  


reflector --country 'YourCountry' --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Qe > ~/utono/install/paclists/explicitly-installed.csv
systemctl list-units --type=service all > ~/utono/install/cachyos/services-all.md
systemctl list-units --type=service > ~/utono/install/cachyos/services-active.md
systemctl --user list-units --type=service --all
systemctl --user status <service_name>.service

