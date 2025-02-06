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

nmtui
sudo loadkeys dvorak  
paru -Syy
paru -S udisks2
udisksctl mount -b /dev/sda  
mkdir -p ~/utono  
rsync -avlp /run/media/####/utono/ ~/utono  

cd ~/utono/rpd  
chmod +x keyd-configuration.sh  
sh ~/utono/rpd/keyd-configuration.sh ~/utono/rpd  
<!-- localectl status   -->
<!-- sudo localectl set-x11-keymap real_prog_dvorak   -->
cat /etc/vconsole.conf  
nvim /etc/vconsole.conf  
    KEYMAP=real_prog_dvorak
sudo loadkeys real_prog_dvorak  

reflector --country 'YourCountry' --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Qe > ~/utono/install/paclists/explicitly-installed.csv
systemctl list-units --type=service all > ~/utono/install/cachyos/services-all.md
systemctl list-units --type=service > ~/utono/install/cachyos/services-active.md
mkinitcpio -P  
reboot


x17 login: root  
Password:  

### SDDM Configuration

cp -i $HOME/utono/system-config/sddm/usr/share/sddm/scripts/Xsetup /usr/share/sddm/scripts
sudo mkdir -p /etc/sddm.conf.d
echo -e "[Autologin]\nUser=mlj\nSession=hyprland" | sudo tee /etc/sddm.conf.d/autologin.conf

.. (Optional) Disable and mask sddm
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

sh ~/utono/user-config/sync-delete-repos-for-new-user.sh 

### Install Essential Packages  
<!-- paru -S --needed blueman git-delta kitty libnotify ripgrep socat starship stow zoxide ttf-jetbrains-mono-nerd   -->

sh ~/utono/install/paclists/install_packages.sh feb-2025.csv

(Optional: Install other fonts)

paru -S ttf-firacode-nerd  

### Dotfiles Setup  

mkdir -p ~/.local/bin  

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

### Hyprland Bindings and Config Sync  

cd ~/utono/rpd  
hyprctl binds >> hyprctl-binds.md  

cd ~/utono/user-config
sh ~/utono/user-config/link_hyprland_settings.sh

cd ~/utono/cachyos-hyprland-settings  
git branch -r  
git fetch upstream  
git merge upstream/master  
git merge upstream/master --allow-unrelated-histories  
git add <file_with_conflicts_removed>  
git commit  
ln -sf ~/utono/cachyos-hyprland-settings/etc/skel/.config/hypr ~/.config/hypr
<!-- sh $HOME/utono/user-config/link_hyprland_settings.sh   -->

### lid-behavior.conf

sudo mkdir -p /etc/systemd/logind.conf.d
sudo cp ~/utono/system-config/etc/systemd/logind.conf.d/lid-behavior.conf /etc/systemd/logind.conf.d
sudo systemctl restart systemd-logind
sudo loginctl show-session | grep HandleLidSwitch

### touchpad

hyprctl devices
nvim $HOME/tty-dotfiles/hypr/.config/hypr/bin/touchpad_hyprland.sh






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

