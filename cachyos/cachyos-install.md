# CachyOS Install Guide

## Clone Repositories to USB Drive

wipefs --all /dev/disk/by-id/usb-My_flash_drive  
sudo mkfs.fat -F 32 /dev/sda  

udisksctl mount -b /dev/sda  

sh $HOME/utono/user-config/utono-clone.sh /run/media/mlj/956A-D24E/utono  
sh $HOME/utono/user-config/git-pull-utono.sh /run/media/mlj/FEED-C372/utono  

rsync -avl --progress ~/Music/{hilary-mantel,william_shakespeare} /run/media/mlj/956A-D24E/utono  

---

## Root Setup

**Switch to TTY:**  
Ctrl + Alt + F3

### Login as Root  

x17 login: root  
Password:  

sudo loadkeys dvorak  
udisksctl mount -b /dev/sda  
mkdir -p ~/utono  
rsync -avl /run/media/####/utono/ ~/utono  
pacman -Qe > ~/utono/install/paclists/explicitly-installed.csv
systemctl list-units --type=service all > ~/utono/install/cachyos/services-all.md
systemctl list-units --type=service > ~/utono/install/cachyos/services-active.md

cd ~/utono/rpd  
chmod +x keyd-configuration.sh  
sh ~/utono/rpd/keyd-configuration.sh ~/utono/rpd  
<!-- localectl status   -->
<!-- sudo localectl set-x11-keymap real_prog_dvorak   -->
cat /etc/vconsole.conf  
nvim /etc/vconsole.conf  
    KEYMAP=real_prog_dvorak
mkinitcpio -P  
sudo loadkeys real_prog_dvorak  

reboot

x17 login: root  
Password:  

### Bluetooth Setup

sudo systemctl status bluetooth.service  
sudo systemctl start bluetooth.service  
sudo systemctl enable --now bluetooth.service  
(Reboot might be necessary, wait ~30s before proceeding)

### SDDM Configuration

sudo nvim /usr/share/sddm/scripts/Xsetup  

export XKB_DEFAULT_LAYOUT=real_prog_dvorak  
setxkbmap -layout real_prog_dvorak -v  

sudo nvim /etc/sddm.conf  

[Autologin]  
User=mlj  
Session=hyprland  

(Optional: Disable and mask SDDM if needed)

[root@archiso /]# systemctl disable sddm  
[root@archiso /]# systemctl mask sddm  

sudo systemctl restart sddm  
reboot  

---

## Login as User

**Switch to TTY:**  
Ctrl + Alt + F3

x17 login: mlj  
Password:  

systemctl --user list-units --type=service --all
systemctl --user status <service_name>.service

mkdir -p ~/utono  
chattr -V +C ~/utono  
cd ~/utono  
udisksctl mount -b /dev/sda  

cd /run/media/mlj/#######/utono  
rsync -avl . ~/utono  
chown -R "$USERNAME:$USERNAME" ~/utono  

sh ~/utono/user-config/sync-delete-repos-for-new-user.sh mlj  

### Install Essential Packages  
<!-- paru -S --needed blueman git-delta kitty libnotify ripgrep socat starship stow zoxide ttf-jetbrains-mono-nerd   -->

sh ~/utono/install/paclists/install_packages.sh feb-2025.csv

(Optional: Install other fonts)

paru -S ttf-firacode-nerd  

### Dotfiles Setup  

mkdir -p ~/.local/bin  
chattr +V -C ~/.local/bin  

cd ~/tty-dotfiles/  
stow --verbose=2 --no-folding bin-mlj git kitty shell starship  
cd ~  
mv .zshrc .zshrc.cachyos.bak  
ln -sf ~/.config/shell/profile .zprofile  
chsh -s /bin/zsh  
logout  

---

## Post-Login Setup

### SSH Configuration  

sh $HOME/utono/ssh/sync-ssh-keys.sh  

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

---

## Hyprland Configuration

**Switch to TTY:**  
Ctrl + Alt + F1  

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

### Hyprland Bindings and Config Sync  

cd ~/utono/rpd  
hyprctl binds >> hyprctl-binds.md  
cd ~/utono/cachyos-hyprland-settings  
git fetch upstream  
git branch -r  
git merge upstream/master  
git merge upstream/master --allow-unrelated-histories  
git add <file_with_conflicts_removed>  
git commit  
ln -sf ~/utono/cachyos-hyprland-settings/etc/skel/.config/hypr ~/.config/hypr
<!-- sh $HOME/utono/user-config/link_hyprland_settings.sh   -->

### lid-behavior.conf

sudo cp ~/utono/system-config/etc/systemd/logind.conf.d/lid-behavior.conf /etc/systemd/logind.conf.d
sudo systemctl restart systemd-logind
sudo loginctl show-logind | grep HandleLidSwitch



---

## Audio Configuration

pacman -Qi sof-firmware  
alsamixer  

**Steps:**  
1. Press F6  
2. Select sof-firmware if available  

---

