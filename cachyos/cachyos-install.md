# CachyOS Install Guide

## Clone Repositories to USB Drive

```bash
wipefs --all /dev/disk/by-id/usb-My_flash_drive
sudo mkfs.fat -F 32 /dev/sda

udisksctl mount -b /dev/sda

sh $HOME/utono/user-config/utono-clone.sh /run/media/mlj/956A-D24E/utono
sh $HOME/utono/user-config/git-pull-utono.sh /run/media/mlj/FEED-C372/utono

# rsync -avl --progress ~/utono/{archlive_aur_packages,archlive_aur_repository} /run/media/mlj/956A-D24E/utono
rsync -avl --progress ~/Music/{hilary-mantel,william_shakespeare} /run/media/mlj/956A-D24E/utono
```

## Adjust Keyboard Layout and Resolution

```bash
# Not required: nmtui
meta + enter

# Alacritty:
Control + Equals
Control + Minus
Control + Zero

paru -Syy
paru -Syu keyd neovim-nightly-bin udisks2
# paru -S openssh
hyprctl keyword input:kb_variant dvorak
(hyprctl keyword input:kb_variant "")
sudo nvim /etc/sddm.conf

    [Autologin]
    User=mlj
    Session=hyprland

hyprctl monitors
hyprctl keyword monitor ,1920x1200,,

mkdir -p ~/utono
chattr -V +C ~/utono
cd ~/utono
udisksctl mount -b /dev/sda
cd /run/media/mlj/#######/utono
rsync -avl . ~/utono
# git clone https://github.com/utono/cachyos-hyprland-settings.git
# git clone https://github.com/utono/install.git
# git clone https://github.com/utono/kickstart-modular.nvim.git
# git clone https://github.com/utono/rpd.git
# git clone https://github.com/utono/system-config.git
# git clone https://github.com/utono/user-config.git

cd ~/utono/rpd
chmod +x keyd-configuration.sh
./keyd-configuration.sh ~/utono/rpd
systemctl list-unit-files --type=service --state=enabled
systemctl status keyd

sudo localectl set-keymap real_prog_dvorak
# sudo nvim /etc/mkinitcpio.conf
# HOOKS=(base udev autodetect modconf block keymap filesystems keyboard fsck)
mkinitcpio -P
# loadkeys real_prog_dvorak
localectl status
sudo nvim /usr/share/sddm/scripts/Xsetup

    # Set custom keyboard layout with verbosity
    export XKB_DEFAULT_LAYOUT=real_prog_dvorak
    setxkbmap -layout real_prog_dvorak -v

reboot
sh ~/utono/user-config/sync-delete-repos-for-new-user.sh mlj
nvim
# cd ~/utono/user-config/repo-add-aur
# sh archlive_repo_add.sh
# chown -R "$USERNAME:$USERNAME" ~/utono

cd ~/tty-dotfiles
paru -S git-delta kitty starship stow zoxide
stow -v --no-folding bin-mlj git kitty shell ssh starship
cd ~
ln -sf ~/.config/shell/profile .zprofile
chmod 0600 ~/.ssh/id_ed25519
chsh -s /bin/zsh
nvim ~/.config/hypr/config/defaults.conf <-- $terminal = kitty
logout
# paru -S ttf-firacode-nerd
paru -S ttf-jetbrains-mono-nerd
# paru -S ttf-nerd-fonts-symbols-mono
# paru -S nerd-fonts

pgrep ssh-agent
systemctl --user enable ssh-agent.service
systemctl --user start ssh-agent.service
systemctl --user status ssh-agent.service
ssh-add -l
# ssh-add ~/.ssh/id_rsa
# sudo systemctl restart sddm
sudo nvim /etc/ssh/sshd_config <-- PermitRootLogin

sudo systemctl start ssh
sudo systemctl enable sshd
systemctl status sshd
ip addr show

# from the client:
    ssh-copy-id -i ~/.ssh/id_ed25519.pub username@server_ip




cd ~/utono/rpd
hyprctl binds >> hyprctl-binds.md
```

## Sync `~/utono/cachyos-hyprland-settings`

```bash
cd ~/utono
git clone https://github.com/utono/cachyos-hyprland-settings.git
git remote add upstream https://github.com/CachyOS/cachyos-hyprland-settings.git
cd ~/utono/cachyos-hyprland-settings
git remote -v
git fetch upstream
git log HEAD..upstream/master
git merge upstream/master
sh link_hyprland_settings.sh
reboot
```

## New User Setup

```bash
x15 login: mlj
Password:
passwd
su -
sh /root/utono/user-config/user-configuration.sh mlj
udisksctl mount -b /dev/sda
cp -r /Music/** ~/Music
exit

# Optional:
stow -v --no-folding bat bin-mlj git keyd kitty bash ssh starship
ln -sf ~/.config/bash/profile ~/.zprofile

vim ~/.zprofile
# Comment out the lines below:
# export WAYLAND_DISPLAY=wayland-0
# export XDG_SESSION_TYPE=wayland

chsh -s /bin/zsh
chmod 0600 ~/.ssh/id_ed25519
logout
```

## Repository Cloning and Package Installation

```bash
x15 login: mlj
Password:
eval $(ssh-agent)
ssh-add ~/.ssh/id_ed25519
# sh ~/utono/user-config/repo-add-aur/archlive_repo_add.sh
# cd ~/utono/archlive_aur_packages
# ln -sf archlive_aur_repository.db.tar.gz archlive_aur_repository.db

# For Hyprland, refer to:
# $HOME/utono/rpd/hyprland-keyboard-configuration.rst

systemctl enable --now bluetooth
bluetuith
sh $HOME/utono/user-config/user-systemd-services-sync.sh

sh ~/utono/user-config/clone/Documents/repos/clone_repos.sh
archiso_repos_config.sh
hyprland_repos_config.sh
literature_repos_config.sh
nvim_repos_config.sh
zsh_repos_config.sh

sh ~/utono/user-config/paclists/install_packages.sh apps-paclist.csv
sh ~/utono/user-config/paclists/install_packages.sh aur-paclist.csv
sh ~/utono/user-config/paclists/install_packages.sh hyprland-paclist.csv
sh ~/utono/user-config/paclists/install_packages.sh mpv-paclist.csv
sh ~/utono/user-config/paclists/install_packages.sh playstation-paclist.csv
```

