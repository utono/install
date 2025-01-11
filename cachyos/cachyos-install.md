# CachyOS Install Guide

## Clone Repositories to USB Drive

```bash
wipefs --all /dev/disk/by-id/usb-My_flash_drive
sudo mkfs.fat -F 32 /dev/sda

udisksctl mount -b /dev/sda

sh $HOME/utono/user-config/utono-clone.sh /run/media/mlj/956A-D24E/utono
sh $HOME/utono/user-config/git-pull-utono.sh /run/media/mlj/FEED-C372/utono

rsync -avl --progress ~/utono/{archlive_aur_packages,archlive_aur_repository} /run/media/mlj/956A-D24E/utono
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

hyprctl keyword input:kb_variant dvorak
(hyprctl keyword input:kb_variant "")
hyprctl monitors
hyprctl keyword monitor ,1920x1200,,
pacman -Syy
pacman -Syu keyd rsync udisks2

# mkdir -p ~/tmp
# cd ~/tmp
# curl -O https://raw.githubusercontent.com/utono/rpd/main/keyboard-layout-sync.sh
# chmod +x keyboard-layout-sync.sh
# ./keyboard-layout-sync

mkdir -p ~/utono
# chattr -V +C ~/utono
cd ~/utono
git clone https://github.com/utono/cachyos-hyprland-settings.git
git clone https://github.com/utono/install.git
git clone https://github.com/utono/kickstart-modular.nvim.git
git clone https://github.com/utono/rpd.git
git clone https://github.com/utono/system-config.git
git clone https://github.com/utono/user-config.git
cd ~/utono/rpd
sudo sh keyd-configuration.sh ~/utono/rpd
systemctl list-unit-files --type=service --state=enabled
systemctl status keyd

udisksctl mount -b /dev/sda
mkdir -p ~/.config
cd /run/media/mlj/######/utono/tty-dotfiles/git/.config
cp -r git ~/.config
cd /run/media/mlj/######/utono/tty-dotfiles/ssh
cp -r .ssh ~
chmod 600 ~/.ssh/id_ed25519
echo $SSH_AUTH_SOCK
echo $SSH_AGENT_PID

pgrep ssh-agent
systemctl --user enable ssh-agent.service
systemctl --user start ssh-agent.service
systemctl --user status ssh-agent.service
ssh-add -l
ssh-add ~/.ssh/id_rsa

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
sudo sh keyd-configuration.sh ~/utono/rpd
reboot
hyprctl keyword input:kb_layout real_prog_dvorak
```

## Configure Pacman, Sudoers, and Makepkg

```bash
git clone https://github.com/utono/system-configs.git
cd ~/utono/system-configs/scripts
sh system-configuration.sh
sh pacman-config.sh
sudo pacman -Syy
# sh sudoers-config.sh
# sh makepkg-config.sh
# If Wi-Fi is slow, reboot
sudo pacman -S udisks2 tree
```

## Copy Files from USB Drive

```bash
udisksctl mount -b /dev/sda
cp -r /utono/** ~/utono
cp -r /Music/** ~/Music
cp -r /tty-dotfiles ~
```

## Apply Dotfiles with Stow

```bash
cd ~/tty-dotfiles
stow -v --no-folding ssh
chmod 0600 ~/.ssh/id_ed25519
eval $(ssh-agent)
ssh-add ~/.ssh/id_ed25519
```

## Install `neovim-nightly-bin`

```bash
cd /root/utono/archlive_aur_repository
ln -sf archlive_aur_repository.db.tar.gz archlive_aur_repository.db
pacman -Syy neovim-nightly-bin
```

## New User Setup

```bash
x15 login: mlj
Password:
passwd
su -
sh /root/utono/user-config/rsync-for-new-user.sh mlj
sh /root/utono/user-config/user-configuration.sh mlj
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
sh ~/utono/user-config/repo-add-aur/archlive_repo_add.sh
cd ~/utono/archlive_aur_packages
ln -sf archlive_aur_repository.db.tar.gz archlive_aur_repository.db

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

