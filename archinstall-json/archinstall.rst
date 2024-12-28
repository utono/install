archinstall.rst
===============

Navigate to the boot directory:
--------------------------------
.. code-block:: shell

    cd /var/lib/libvirt/boot
    wipefs --all /dev/disk/by-id/usb-My_flash_drive
    sudo sgdisk --zap-all "${DEVICE}"
    sudo cp /var/lib/libvirt/boot/archlinux-2024.12.04-x86_64.iso /dev/sda

Switch to another terminal:
---------------------------
.. code-block:: shell

    Ctrl+fn+alt f2

Start the SSH agent:
--------------------
.. code-block:: shell

    root@archiso ~ # eval $(ssh-agent)

Add your SSH private key for authentication:
--------------------------------------------
.. code-block:: shell

    root@archiso ~ # ssh-add ~/.ssh/id_ed25519

Navigate to the repository directory:
-------------------------------------
.. code-block:: shell

    root@archiso ~ # cd utono/aiso

Stash local changes and update the repository:
----------------------------------------------
.. code-block:: shell

    root@archiso ~/utono/aiso # git stash
    root@archiso ~/utono/aiso # git pull

Run a custom script to synchronize additional files:
----------------------------------------------------
.. code-block:: shell

    root@archiso ~/utono/aiso # ./git-pull-utono.sh

Change to the Archinstall configuration directory:
--------------------------------------------------
.. code-block:: shell

    root@archiso ~/utono/install # cd archinstall-json/hyprland-kde-plasma

Run Archinstall with the specified configuration:
-------------------------------------------------
.. code-block:: shell

    root@archiso ~/utono/install/archinstall-json/hyprland-kde-plasma # archinstall --config user_configuration.json --creds user_credentials.json

(Optional) Disable and mask SDDM:
---------------------------------
.. code-block:: shell

    [root@archiso /]# systemctl disable sddm
    [root@archiso /]# systemctl mask sddm

Change the default shell to Zsh for the root user:
--------------------------------------------------
.. code-block:: shell

    [root@archiso /]# chsh -s /bin/zsh

Create a directory to store custom configurations:
--------------------------------------------------
.. code-block:: shell

    [root@archiso /]# mkdir -p /root/utono

Set the directory attribute to not use copy-on-write (COW):
------------------------------------------------------------
.. code-block:: shell

    [root@archiso /]# chattr -V +C /root/utono

Navigate to the newly created directory:
-----------------------------------------
.. code-block:: shell

    [root@archiso /]# cd /root/utono

Clone the RPD repository:
--------------------------
.. code-block:: shell

    [root@archiso utono]# git clone https://github.com/utono/rpd.git

Synchronize keyboard files:
-------------------------------------------------------
.. code-block:: shell

    [root@archiso rpd]# ./keyd-configuration.sh

Handle systemd issues and finalize installation:
------------------------------------------------
.. code-block:: shell

    [root@archiso dvorak]# localectl
    System has not been booted with systemd as init system (PID 1). Can't operate.
    Failed to connect to bus: Host is down

    [root@archiso dvorak]# exit

        exit
        Installation completed without any errors. You may now reboot.

Synchronize and configure system files:
---------------------------------------
.. code-block:: shell

    root@archiso ~/utono/install/archinstall-json/hyprland-kde-plasma # rsync -av ~/utono/ /mnt/archinstall/root/utono
    root@archiso ~/utono/install/archinstall-json/hyprland-kde-plasma # reboot






-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------





Copy the Dvorak keymap to the system keymap directory:
-------------------------------------------------------
.. code-block:: shell

    [root@archiso utono]# cd rpd/kbd/usr/share/kbd/keymaps/i386/dvorak
    [root@archiso dvorak]# cp -v real_prog_dvorak.map.gz /usr/share/kbd/keymaps/i386/dvorak/

Edit the console configuration to use the custom Dvorak keymap:
---------------------------------------------------------------
.. code-block:: shell

    [root@archiso dvorak]# vim /etc/vconsole.conf

        KEYMAP=real_prog_dvorak

Synchronize custom XKB keyboard symbols:
-----------------------------------------
.. code-block:: shell

    [root@archiso dvorak]# cd /root/utono
    [root@archiso dvorak]# rsync -av --progress --stats rpd/xkb/usr/share/X11/xkb/symbols/ /usr/share/X11/xkb/symbols/

Synchronize custom Xorg configuration files:
--------------------------------------------
.. code-block:: shell

    [root@archiso dvorak]# rsync -av --progress --stats rpd/xorg.conf.d/etc/X11/xorg.conf.d/ /etc/X11/xorg.conf.d/


