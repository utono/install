# CachyOS Install Guide

## Clone Repositories to USB Drive

`wipefs --all /dev/disk/by-id/usb-My_flash_drive`  
`sudo mkfs.fat -F 32 /dev/sda`  

`udisksctl mount -b /dev/sda`  

`sh $HOME/utono/user-config/utono-clone.sh /run/media/mlj/956A-D24E/utono`  
`sh $HOME/utono/user-config/git-pull-utono.sh /run/media/mlj/FEED-C372/utono`  

`rsync -avl --progress ~/Music/{hilary-mantel,william_shakespeare} /run/media/mlj/956A-D24E/utono`  

## kde plasma: Adjust Keyboard Layout and Resolution

ctrl+alt+f2

`sudo loadkeys dvorak`
`localectl status`
`cat /etc/vconsole.conf`
`nvim /etc/vconsole.conf`
    KEYMAP=real_prog_dvorak
`udisksctl mount -b /dev/sda`
`mkdir -p ~/utono`
`rsync -avl /run/media/####/utono/ ~/utono`
`cd ~/utono/rpd`
`chmod +x keyd-configuration.sh`
`sudo sh ~/utono/rpd/keyd-configuration.sh ~/utono/rpd`
`mkinitcpio -P`
`sudo localectl set-x11-keymap real_prog_dvorak`
`sudo loadkeys real_prog_dvorak'
`reboot`

## Adjust Keyboard Layout and Resolution

# Not required: nmtui
meta + enter

# Alacritty:
Control + Equals
Control + Minus
Control + Zero

`paru -Syy`
`paru -Syu --needed keyd neovim-nightly-bin udisks2`
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

`sudo mkinitcpio -P`
# `loadkeys real_prog_dvorak`
`localectl status`
`sudo nvim /usr/share/sddm/scripts/Xsetup`

    # Set custom keyboard layout with verbosity
    export XKB_DEFAULT_LAYOUT=real_prog_dvorak
    setxkbmap -layout real_prog_dvorak -v

`mkdir -p ~/.config/nvim`
`chattr -V +C ~/.config/nvim`
`rsync -avl ~/utono/kickstart-modular.nvim/ ~/.config/nvim/`

`reboot`

`sh ~/utono/user-config/sync-delete-repos-for-new-user.sh mlj`

`cd ~/tty-dotfiles`
`paru -S --needed git-delta kitty starship stow zoxide ttf-jetbrains-mono-nerd`
# `paru -S ttf-firacode-nerd`
`mkdir -p ~/.local/bin`
`chattr +V -C ~/.local/bin`
`stow --verbose=2 --no-folding bin-mlj git kitty shell starship`
`cd ~`
`mv .zshrc .zshrc.cachyos.bak`
`ln -sf ~/.config/shell/profile .zprofile`
`chsh -s /bin/zsh`
`logout`









`sh $HOME/utono/ssh/sync-ssh-keys.sh`

    #   `rsync -av ~/utono/ssh/.ssh/ ~/.ssh/`
    #   `chmod 700 ~/.ssh`
    #   `find ~/.ssh -type f -name "id_*" -exec chmod 600 {} \;`
    #   `chmod 0600 ~/.ssh/id_ed25519`
    #   `pgrep ssh-agent`
    #   `systemctl --user enable ssh-agent.service`
    #   `systemctl --user start ssh-agent.service`
    #   `systemctl --user status ssh-agent.service`
    #   `ssh-add -l`
    #   `ssh-add ~/.ssh/id_rsa`

    #   `sudo nvim /etc/ssh/sshd_config <-- PermitRootLogin`


`cd ~/utono/rpd`
`hyprctl binds >> hyprctl-binds.md`
`sh $HOME/utono/user-config/link_hyprland_settings.sh`
