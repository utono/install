archinstall.rst
===============

Switch to another terminal:
---------------------------

.. code-block:: bash

    Ctrl+fn+alt f2

USB Wiping, Formatting and Mounting:
--------------------------------

.. code-block:: bash

    wipefs --all /dev/disk/by-id/usb-My_flash_drive
    sudo mkfs.fat -F 32 /dev/sda

    udisksctl mount -b /dev/sda

    sudo sgdisk --zap-all "${DEVICE}"

Navigate to the boot directory:
--------------------------------

.. code-block:: bash

    cd /var/lib/libvirt/boot
    sudo cp /var/lib/libvirt/boot/archlinux-2024.12.04-x86_64.iso /dev/sda

Start the SSH agent:
--------------------

.. code-block:: bash

    root@archiso ~ # eval $(ssh-agent -s)
    root@archiso ~ # ssh-add ~/.ssh/id_ed25519
    root@archiso ~ # pgrep ssh-agent
    root@archiso ~ # ssh-add -l
    root@archiso ~ # eval $(ssh-agent -k)    # stops ssh-agent

Stash local changes and update the repository:
----------------------------------------------

.. code-block:: bash

    root@archiso ~ # cd utono/install
    root@archiso ~/utono/install # git pull
    root@archiso ~/utono/install # cd ~/utono/install/archinstall-json/x##
    root@archiso ~/utono/install/archinstall-json/x## # archinstall --config user_configuration.json --creds user_credentials.json

arch-chroot:
------------

.. code-block:: bash

    [root@archiso /]# chsh -s /usr/bin/zsh
    [root@archiso /]# mkdir -p /root/utono
    [root@archiso /]# chattr -V +C /root/utono
    [root@archiso /]# cd /root/utono
    [root@archiso utono]# git clone https://github.com/utono/rpd.git
    [root@archiso utono]# cd rpd
    [root@archiso rpd]# ./keyd-configuration.sh /root/utono/rpd
    [root@archiso rpd]# cat /etc/vconsole.conf
    [root@archiso utono]# mkinitcpio -P

    .. (Optional) Blacklist NVIDIA drivers and removes NVIDIA-related udev rules
    [root@archiso utono]# git clone https://github.com/utono/system-config.git
    [root@archiso utono]# cd system-configs/scripts
    [root@archiso utono]# chmod +x *.sh
    [root@archiso utono]# sh nvidia-blacklist.sh ~/utono

    .. (Optional) Disable and mask SDDM:

    [root@archiso /]# systemctl disable sddm
    [root@archiso /]# systemctl mask sddm

    [root@archiso /]# localectl

    .. System has not been booted with systemd as init system (PID 1). Can't operate.
    .. Failed to connect to bus: Host is down

    [root@archiso dvorak]# exit

root@archiso: Synchronize and configure system files:
-----------------------------------------------------

.. code-block:: bash

    root@archiso ~/utono/install/archinstall-json/x## # rsync -avl ~/utono/ /mnt/archinstall/root/utono
    root@archiso ~/utono/install/archinstall-json/x## # cp -i /root/user_configuration.json .
    root@archiso ~/utono/install/archinstall-json/x## # git add .
    root@archiso ~/utono/install/archinstall-json/x## # git commit -m json
    root@archiso ~/utono/install/archinstall-json/x## # git push
    root@archiso ~/utono/install/archinstall-json/x## # reboot

Root Login: Initial Configuration
---------------------------------

.. code-block:: bash

    x15 login: root
    Password:

    passwd

    nmtui
    systemctl enable --now bluetooth.service
    systemctl restart bluetooth.service
    pacman -Syy linux linux-headers
    pacman -Syu sof-firmware
    systemctl --user enable --now pipewire pipewire-pulse
    systemctl --user enable --now wireplumber
    systemctl --user restart pipewire pipewire-pulse wireplumber
    pacman -Syy alsa-utils

    reboot

    .. wifi might be slow; reboot will help

Root Login: Install paru and additional packages
------------------------------------------------

.. code-block:: bash

    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
    reflector --country 'YourCountry' --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    systemctl list-unit-files --type=service --state=enabled
    pacman -Syu
    mkdir -p ~/Documents
    chattr -V +C ~/Documents
    mkdir -p ~/Documents/repos/paru
    cd ~/Documents/repos/paru
    sudo pacman -S --needed base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
    cd ~/utono/user-config/paclists
    ./install_packages.sh jan-2025.csv

Root Login: stow and ssh keys
---------------------------------

.. code-block:: bash


    cp -r /root/utono/tty-dotfiles ~
    cp -r /root/utono/cachy-dots ~
    mkdir -p ~/.local/bin
    # sh $HOME/tty-dotfiles/stow-root.sh
    stow -v --no-folding bat bin-mlj btop environment.d git keyd kitty ksb shell ssh starship systemd zathura
    ln -sf ~/.config/shell/profile ~/.zprofile

    chmod 0600 ~/.ssh/id_ed25519
    eval $(ssh-agent)
    ssh-add ~/.ssh/id_ed25519

    logout

    x15 login: root
    Password:

    cd ~/utono/user-config
    git stash
    git pull

    ./utono-repo-sync ~/utono

    sh /root/utono/user-config/rsync-for-new-user.sh mlj
    sh /root/utono/user-config/user-configuration.sh mlj
    sudo chown -R mlj:mlj /path/to/directory

    logout

Root Login: test sound in tty
---------------------------------

.. code-block:: bash

   systemctl --user status pipewire pipewire-pulse wireplumber
   systemctl --user enable --now pipewire pipewire-pulse wireplumber
   pw-cli info
   sudo pacman -S alsa-utils mpv
   aplay /usr/share/sounds/alsa/Front_Center.wav
   mpv https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3

Root Login: test sound in Hyprland
----------------------------------

.. code-block:: bash
    
   sudo pacman -S pipewire-pulse pavucontrol
   pw-cli list-objects | grep node
   pavucontrol
   paplay /usr/share/sounds/freedesktop/stereo/message.oga
   mpv https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3
   pw-cli info

Root Login: troubleshooting sound
----------------------------------

.. code-block:: bash
   alsamixer
   pw-metadata | grep default.audio.sink
   pactl set-default-sink <sink-name>
   systemctl --user restart pipewire pipewire-pulse wireplumber
   journalctl --user -u pipewire --follow
   






User Login: New User Setup
--------------------------

.. code-block:: bash

    x15 login: mlj
    Password:
    passwd
    .. Changing password for mlj.
    .. Current password:
    .. New password:
    .. Retype new password:
    .. passwd: password updated successfully

    mkdir -p ~/.local/bin
    cd ~/cachy-dots
    stow -v --no-folding
    ln -sf ~/.config/shell/profile ~/.zprofile

    vim ~/.zprofile
        # Comment out the lines below:
        # export WAYLAND_DISPLAY=wayland-0
        # export XDG_SESSION_TYPE=wayland

    chsh -s /bin/zsh
    sudo chown -R mlj:mlj /path/to/directory
    chmod 0600 ~/.ssh/id_ed25519
    logout

eval $(ssh-agent)
ssh-add ~/.ssh/id_ed25519
    pacman -S --needed git base-devel
git clone --depth 1 https://github.com/prasanthrangan/hyprdots ~/HyDE
cd ~/HyDE/Scripts
./install.sh

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

Optional: Run AUI Console
-------------------------

.. code-block:: bash

    aui-run -u -i /var/lib/libvirt/images/aui-console-linux_5_18_8-0702-x64.iso

