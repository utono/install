# CachyOS Install Guide

## Clone Repositories to USB Drive

`wipefs --all /dev/disk/by-id/usb-My_flash_drive`  
`sudo mkfs.fat -F 32 /dev/sda`  

`udisksctl mount -b /dev/sda`  

`sh $HOME/utono/user-config/utono-clone.sh /run/media/mlj/956A-D24E/utono`  
`sh $HOME/utono/user-config/git-pull-utono.sh /run/media/mlj/FEED-C372/utono`  

`rsync -avl --progress ~/Music/{hilary-mantel,william_shakespeare} /run/media/mlj/956A-D24E/utono`  

## Adjust Keyboard Layout and Resolution

# Not required: nmtui
meta + enter

# Alacritty:
Control + Equals
Control + Minus
Control + Zero

`paru -Syy`
`paru -Syu keyd neovim-nightly-bin udisks2`
`hyprctl keyword input:kb_variant dvorak`
# `hyprctl keyword input:kb_variant ""`
`sudo nvim /etc/sddm.conf`

    [Autologin]
    User=mlj
    Session=hyprland

`sudo systemctl restart sddm`

`hyprctl monitors`
`hyprctl keyword monitor ,1920x1200,,`

`mkdir -p ~/utono`
`chattr -V +C ~/utono`
`cd ~/utono`
`udisksctl mount -b /dev/sda`
`cd /run/media/mlj/#######/utono`
`rsync -avl . ~/utono`
`chown -R "$USERNAME:$USERNAME" ~/utono`

# `git clone https://github.com/utono/rpd.git`

`cd ~/utono/rpd`
`chmod +x keyd-configuration.sh`
`./keyd-configuration.sh ~/utono/rpd`
`systemctl list-unit-files --type=service --state=enabled`
`systemctl status keyd`

`sudo localectl set-keymap real_prog_dvorak`
`mkinitcpio -P`
# `loadkeys real_prog_dvorak`
`localectl status`
`sudo nvim /usr/share/sddm/scripts/Xsetup`

    # Set custom keyboard layout with verbosity
    export XKB_DEFAULT_LAYOUT=real_prog_dvorak
    setxkbmap -layout real_prog_dvorak -v

`reboot`
`sh ~/utono/user-config/sync-delete-repos-for-new-user.sh mlj`

`cd ~/tty-dotfiles`
`paru -S git-delta kitty starship stow zoxide`
`stow -v --no-folding bin-mlj git kitty shell ssh starship`
`cd ~`
`ln -sf ~/.config/shell/profile .zprofile`
`chmod 0600 ~/.ssh/id_ed25519`
`chsh -s /bin/zsh`
`nvim ~/.config/hypr/config/defaults.conf <-- $terminal = kitty`
`logout`
# `paru -S ttf-firacode-nerd`
`paru -S ttf-jetbrains-mono-nerd`

`sh $HOME/utono/system-config/scripts/ssh-sync.sh`

    `pgrep ssh-agent`
    `systemctl --user enable ssh-agent.service`
    `systemctl --user start ssh-agent.service`
    `systemctl --user status ssh-agent.service`
    `ssh-add -l`
    `ssh-add ~/.ssh/id_rsa`

`sudo nvim /etc/ssh/sshd_config <-- PermitRootLogin`

`sudo systemctl start ssh`
`sudo systemctl enable sshd`
`systemctl status sshd`
`ip addr show`

# from the client:
`ssh-copy-id -i ~/.ssh/id_ed25519.pub username@server_ip`

`cd ~/utono/rpd`
`hyprctl binds >> hyprctl-binds.md`
