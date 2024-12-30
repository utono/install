cachyos-install.rst
===================

Root Login: TTY
---------------

.. code-block:: bash

	pacman -Syy
	pacman -S terminus-font
	cd /usr/share/kbd/consolefonts
	setfont ter-132n
	:colorscheme ron
	loadkeys dvorak
	loadkeys dvorak-programmer

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
	systemctl list-unit-files --type=service --state=enabled
	loadkeys real_prog_dvorak


Root Login: rsync utono
-----------------------

.. code-block:: bash
    
	sudo pacman -S udisks2
	udisksctl mount -b /dev/sda
	rsync -av /run/media/root/FEED-C372/ /root/utono
	udisksctl unmount -b /dev/sda

Root Login: Initial Configuration
---------------------------------

.. code-block:: bash

    sh ~/utono/install/system/system-configuration.sh ~/utono
    # sh ~/utono/install/system/sddm-configuration.sh ~/utono
    sudo pacman -S stow
    sh ~/utono/install/system/stow-root.sh
    ln -sf ~/.config/shell/profile ~/.zprofile
    logout
    x15 login: root
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
    systemctl enable --now bluetooth
    sh $HOME/utono/user-config/8bitdo_zero_2_user_level_service.sh

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


