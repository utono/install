cachyos-install.rst
===================

Clone repos to USB drive:
-------------------------

.. code-block:: bash

    udisksctl mount -b /dev/sda1
    sh $HOME/utono/user-config/utono-clone.sh /run/media/mlj/FEED-C372/utono
    sh $HOME/utono/user-config/git-pull-utono.sh /run/media/mlj/FEED-C372/utono
    rsync -av --progress ~/utono/archlive_aur_packages /run/media/mlj/FEED-C372/utono
    rsync -av --progress ~/utono/archlive_aur_repository /run/media/mlj/FEED-C372/utono
    rsync -av --progress ~/Music/william_shakespeare /run/media/mlj/FEED-C372/utono
    rsync -av --progress ~/Music/hilary-mantel /run/media/mlj/FEED-C372/utono

Root Login: TTY
---------------

.. code-block:: bash

	nmtui
	pacman -Syy
	pacman -S terminus-font
	cd /usr/share/kbd/consolefonts
	setfont ter-132n
	:colorscheme ron
	loadkeys dvorak

Root Login: Clone rpd and configure keyboard:
---------------------------------------------

.. code-block:: bash

	mkdir -p /root/utono
	cd /root/utono
	chattr -V +C /root/utono
	git clone https://github.com/utono/rpd.git
	cd rpd
	sudo pacman -Syy
	./keyd-configuration.sh
	systemctl start keyd
	systemctl list-unit-files --type=service --state=enabled
	loadkeys real_prog_dvorak


Root Login: rsync utono
-----------------------

.. code-block:: bash
    
	sudo pacman -S udisks2 tree
	udisksctl mount -b /dev/sda
	rsync -av /run/media/root/FEED-C372/utono/ /root/utono
	rsync -av /run/media/root/FEED-C372/Music/ /root/Music
	udisksctl unmount -b /dev/sda

Root Login: system-configuration.sh
-----------------------------------

.. code-block:: bash

    cd ~/utono/system-configs/scs
    sh $HOME/utono/system-configs/scs/system-configuration.sh   
    sh $HOME/utono/system-configs/scs/sddm-configuration.sh
    cd /root/utono/archlive_aur_repository
    rm -rf paru* yay*
    ln -sf archlive_aur_repository.db.tar.gz archlive_aur_repository.db
    pacman -Syy neovim-nightly-bin


Root Login: stow-root.sh
------------------------

.. code-block:: bash

    mv ~/utono/tty-dotfiles ~
    mv ~/utono/cachy-dots ~
    sudo pacman -S stow starship zoxide
    # sh ~/tty-dotfiles/stow-root.sh
    stow -v --no-folding bat bin-mlj git keyd kitty shell ssh starship
    ln -sf ~/.config/shell/profile ~/.zprofile
    cd ~/utono/user-config
    git stash
    chmod 0600 ~/.ssh/id_ed25519
    eval $(ssh-agent)
    ssh-add ~/.ssh/id_ed25519
    git pull
    ./git-pull-utono.sh
    logout


User Login: New User Setup
--------------------------
.. code-block:: bash

    x15 login: mlj
    Password:
    passwd
    su -
    sh /root/utono/user-config/rsync-for-new-user.sh mlj
    sh /root/utono/user-config/user-configuration.sh mlj
    exit
    sh /home/mlj/utono/user-config/stow-user.sh
    ln -sf ~/.config/shell/profile ~/.zprofile

    vim ~/.zprofile
        # Comment out the lines below:
        # export WAYLAND_DISPLAY=wayland-0
        # export XDG_SESSION_TYPE=wayland

    chsh -s /bin/zsh
    chmod 0600 ~/.ssh/id_ed25519
    logout

User Login: Repository Cloning and Package Installation
-------------------------------------------------------

.. code-block:: bash

    x15 login: mlj
    Password:
    eval $(ssh-agent)
    ssh-add ~/.ssh/id_ed25519
    sh ~/utono/user-config/repo-add-aur/archlive_repo_add.sh  # Must install paru or yay first
    cd ~/utono/archlive_aur_packages
    ln -sf archlive_aur_repository.db.tar.gz archlive_aur_repository.db

    # For hyprland, refer to: $HOME/utono/rpd/hyprland-keyboard-configuration.rst
    # For hyprland, see ~/utono/cachy-dots/hypr/.config/config/user-config.conf

    systemctl enable --now bluetooth
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


