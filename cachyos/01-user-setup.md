# CachyOS User Setup

## Initial Package Installation

```bash
xps17-2 login: mlj
Password:

paru -Syy
cd $HOME/utono/install/paclists
chmod +x install_packages.sh
bash install_packages.sh 2025.csv
```

## Configure utono repos

```bash
mkdir -p ~/projects
chattr -V +C ~/projects/
cp -r /run/media/mlj/8C8E-606F/utono/gloss-browser ~/projects
bash "$HOME/utono/user-config/rsync-delete-repos-for-new-user.sh" 2>&1 | tee rsync-delete-output.out
ls -al $HOME/.config
cd ~/.config
rm -rf nvim
mv ~/utono/nvim-code/ nvim

    # Or, as an alternative:
    # git clone --config remote.origin.fetch='+refs/heads/*:refs/remotes/origin/*' https://github.com/utono/nvim-temp.git nvim

nvim
# On DEST_HOST:
ln -sf ~/utono/kitty-config/.config/kitty ~/.config/kitty
ln -sf ~/utono/glosses-nvim/ ~/.config/glosses-nvim
ln -sf ~/utono/xc/nvim ~/.config/nvim-xc
```

## Stow Dotfiles

```bash
cd $HOME/tty-dotfiles
mkdir -p $HOME/.local/bin
# https://github.com/ahkohd/eza-preview.yazi
trash ~/.config/mako
stow --verbose=2 --no-folding bat bin-mlj git ksb mako starship systemd -n 2>&1 | tee stow-output.out
vim ~/.config/mako/config
systemctl --user enable --now mako
systemctl --user status mako
notify-send "Test" "Notification working"
# stow --verbose=2 --no-folding yazy 2>&1 | tee stow-output.out
cd $HOME/utono
stow --verbose=2 --no-folding shell-config -n 2>&1 | tee stow-output.out
# ya pkg list
# ya pkg add ahkohd/eza-preview
# ya pkg add h-hg/yamb
```

## Configure ZSH

```bash
cd
ls -al .zshrc
mv .zshrc .zshrc.cachyos.bak
ln -sf $HOME/.config/shell/profile .zprofile  
chsh -s /usr/bin/zsh  
exit
```

Log back in to apply changes.

## Configure SSH

```bash
cd $HOME/utono/ssh
chmod +x *.sh
./sync-ssh-keys.sh "$HOME/utono" 2>&1 | tee -a sync-ssh-keys-output.out

source ~/.config/shell/exports
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
    echo $SSH_AUTH_SOCK
systemctl --user enable --now ssh-agent
systemctl --user status ssh-agent
systemctl --user daemon-reexec
systemctl --user daemon-reload

ssh-add $HOME/.ssh/id_ed25519
ssh-add -l
```
