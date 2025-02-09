# CachyOS Install Guide


## Clone Repositories to USB Drive

wipefs --all /dev/disk/by-id/usb-My_flash_drive  
sudo mkfs.fat -F 32 /dev/sda  

paru -Syy
paru -Sy udisks2
udisksctl mount -b /dev/sda  
~/utono/user-config/utono-repo-sync.sh ~/utono
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
<!-- localectl status   -->
<!-- sudo localectl set-x11-keymap real_prog_dvorak   -->
cat /etc/vconsole.conf  
nvim /etc/vconsole.conf  
    KEYMAP=real_prog_dvorak
sudo loadkeys real_prog_dvorak  
mkinitcpio -P  

### SSH Keys

paru -Syy
paru -S udisks2
udisksctl mount -b /dev/sda  
rsync -avl /run/media/####/utono/ssh /root/utono
cd /root/utono/ssh
chmod +x sync-ssh-keys.sh
./sync-ssh-keys.sh ~/utono

### Dotfiles

mkdir -p ~/.local/bin
rsync -avl /run/media/####/utono/tty-dotfiles /root
cd ~/tty-dotfiles
paru -Sy stow
stow --verbose=2 --no-folding bin-mlj git kitty shell starship  

### Shell

cd ~  
mv .zshrc .zshrc.cachyos.bak  
ln -sf ~/.config/shell/profile .zprofile  
chsh -s /usr/bin/zsh  
paru -S --needed blueman git-delta kitty libnotify neovim ripgrep socat starship stow zoxide ttf-jetbrains-mono-nerd  
logout

### Clone/sync utono repositories and move them to proper locations

cd ~/utono
git clone https://github.com/utono/user-config.git
cd ~/utono/user-config
chmod +x utono-repo-sync.sh
sh $HOME/utono/user-config/utono-repo-sync.sh ~/utono
sh ~/utono/user-config/sync-delete-repos-for-new-user.sh 


### SDDM Configuration

cd /usr/share/sddm/scripts/
cp Xsetup Xsetup.bak
cp -i $HOME/utono/system-config/sddm/usr/share/sddm/scripts/Xsetup .
cat /etc/sddm.conf
sudo mkdir -p /etc/sddm.conf.d
echo -e "[Autologin]\nUser=mlj\nSession=hyprland" | sudo tee /etc/sddm.conf.d/autologin.conf

.. (Optional) Disable and mask sddm
[root@archiso /]# systemctl disable sddm  
[root@archiso /]# systemctl mask sddm  

sudo systemctl restart sddm  
reboot  

### /etc/sysctl.d/

See https://wiki.archlinux.org/title/Keyboard_shortcuts

mkdir -p /etc/sysctl.d
cp ~/utono/system-config/etc/sysctl.d/99-sysrq.conf /etc/sysctl.d/
sysctl --system
cat /proc/sys/kernel/sysrq
<!-- https://wiki.archlinux.org/title/Keyboard_shortcuts -->
"Reboot Even If System Utterly Broken"

### /etc/systemd/logind.conf.d/

mkdir -p /etc/systemd/logind.conf.d
cp ~/utono/system-config/etc/systemd/logind.conf.d/lid-behavior.conf /etc/systemd/logind.conf.d
systemctl restart systemd-logind
loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') --property=IdleAction
loginctl show-session | grep HandleLidSwitch

---

## Login as User

**Switch to TTY:**  
Ctrl + Alt + F3

x17 login: mlj  
Password:  

mkdir -p ~/utono
chattr -V +C ~/utono
rsync -avl /run/media/mlj/####-####/utono/ssh ~/utono
cd ~/utono/ssh
./sync-ssh-keys.sh ~/utono
ssh-add ~/.ssh/id_ed25519

    Could not open a connection to your authentication agent.
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
    echo $SSH_AUTH_SOCK
    systemctl --user enable --now ssh-agent
    systemctl --user status ssh-agent
    systemctl --user daemon-reexec
    systemctl --user daemon-reload

rsync -avl /run/media/mlj/####-####/utono/tty-dotfiles ~
mkdir -p ~/.local/bin
cd ~/tty-dotfiles
stow --verbose=2 --no-folding bin-mlj git kitty shell starship  
cd ~  
mv .zshrc .zshrc.cachyos.bak  
ln -sf ~/.config/shell/profile .zprofile  
chsh -s /usr/bin/zsh  
logout
cd ~/utono
git clone https://github.com/utono/user-config.git
cd ~/utono/user-config
sh $HOME/utono/user-config/utono-repo-sync.sh ~/utono

sh ~/utono/user-config/sync-delete-repos-for-new-user.sh 

### Install Essential Packages  
<!-- paru -S --needed blueman git-delta kitty libnotify neovim ripgrep socat starship stow zoxide ttf-jetbrains-mono-nerd   -->

sh ~/utono/install/paclists/install_packages.sh feb-2025.csv

(Optional: Install other fonts)

paru -S ttf-firacode-nerd  

## Hyprland Configuration

**Switch to TTY:**  
Ctrl + Alt + F1  

### Hyprland Bindings and Config Sync  

cd ~/utono/rpd  
hyprctl binds >> hyprctl-binds.md  

cd ~/utono/user-config
sh ~/utono/user-config/link_hyprland_settings.sh
<!-- ln -sf ~/utono/cachyos-hyprland-settings/etc/skel/.config/hypr ~/.config/hypr -->

cd ~/utono/cachyos-hyprland-settings  
git branch -r  
git fetch upstream  
git merge upstream/master  
git merge upstream/master --allow-unrelated-histories  
git add <file_with_conflicts_removed>  
git commit  

### touchpad

hyprctl devices
nvim $HOME/tty-dotfiles/hypr/.config/hypr/bin/touchpad_hyprland.sh

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

systemctl --user list-units --type=service --all
systemctl --user status <service_name>.service

## Post-Login Setup

### SSH Configuration  

sh $HOME/utono/ssh/sync-ssh-keys.sh ~/utono

mkdir -p ~/.ssh  
chattr -V +C ~/.ssh  
rsync -av ~/utono/ssh/.ssh/ ~/.ssh/  
chmod 700 ~/.ssh  
find ~/.ssh -type f -name "id_*" -exec chmod 600 {} \;  
chmod 0600 ~/.ssh/id_ed25519  

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
echo $SSH_AUTH_SOCK

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
reboot  










reflector --country 'YourCountry' --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Qe > ~/utono/install/paclists/explicitly-installed.csv
systemctl list-units --type=service all > ~/utono/install/cachyos/services-all.md
systemctl list-units --type=service > ~/utono/install/cachyos/services-active.md
mkinitcpio -P  

