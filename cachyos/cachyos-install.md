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
cd ~/utono/rpd  
chmod +x keyd-configuration.sh  
sudo sh ~/utono/rpd/keyd-configuration.sh ~/utono/rpd  
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

mkdir -p ~/utono  
chattr -V +C ~/utono  
cd ~/utono  
udisksctl mount -b /dev/sda  

cd /run/media/mlj/#######/utono  
rsync -avl . ~/utono  
chown -R "$USERNAME:$USERNAME" ~/utono  

sh ~/utono/user-config/sync-delete-repos-for-new-user.sh mlj  

### Install Essential Packages  
paru -S --needed blueman git-delta kitty libnotify socat starship stow zoxide ttf-jetbrains-mono-nerd  

(Optional: Install other fonts)

paru -S ttf-firacode-nerd  

mkdir -p ~/.local/bin  
chattr +V -C ~/.local/bin  

### Dotfiles Setup  

cd ~/tty-dotfiles/  
stow --verbose=2 --no-folding bin-mlj git kitty shell starship  
cd ~  
mv .zshrc .zshrc.cachyos.bak  
ln -sf ~/.config/shell/profile .zprofile  
chsh -s /bin/zsh  
logout  

---

## Post-Login Setup

paru -Syu --needed neovim-nightly-bin
sh $HOME/utono/ssh/sync-ssh-keys.sh  

### SSH Configuration  

mkdir -p ~/.ssh  
chattr -V +C ~/.ssh  
rsync -av ~/utono/ssh/.ssh/ ~/.ssh/  
chmod 700 ~/.ssh  
find ~/.ssh -type f -name "id_*" -exec chmod 600 {} \;  
chmod 0600 ~/.ssh/id_ed25519  
pgrep ssh-agent  
systemctl --user enable ssh-agent.service  
systemctl --user start ssh-agent.service  
systemctl --user status ssh-agent.service  
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
sh $HOME/utono/user-config/link_hyprland_settings.sh  
cd ~/utono/cachyos-hyprland-settings  
git fetch upstream  
git branch -r  
git merge upstream/master  
git merge upstream/master --allow-unrelated-histories  
git add <file_with_conflicts_removed>  
git commit  

---

## Audio Configuration

pacman -Qi sof-firmware  
alsamixer  

**Steps:**  
1. Press F6  
2. Select sof-firmware if available  

---

