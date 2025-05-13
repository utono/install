## Configure Passwordless `sudo` for Mount/Umount and Other Commands

### Create the Sudoers File (Two Methods)

#### Method 1: Use `visudo` to create the file

Use the `visudo` command to safely create the configuration file:

```bash
sudo visudo -f /etc/sudoers.d/00_wheel_nopasswd
```

Paste the following contents:

```bash
sudo visudo -f /etc/sudoers.d/00_wheel_nopasswd
```

Paste the following contents:

```sudoers
# Defaults specification
Defaults editor=/usr/bin/nvim
Defaults passwd_timeout=0
Defaults timestamp_timeout=-1
Defaults timestamp_type=global

# Command aliases
Cmnd_Alias SHUTDOWN_CMDS = /usr/bin/shutdown, /usr/bin/reboot, /usr/bin/systemctl suspend, /usr/bin/wifi-menu, /usr/bin/mount, /usr/bin/umount
Cmnd_Alias PACKAGE_MGMT_CMDS = /usr/bin/pacman *
Cmnd_Alias NETWORK_CMDS = /usr/bin/ip link set wlan0 down, /usr/bin/ip link set wlan0 up
Cmnd_Alias DISPLAY_CMDS = /usr/bin/xbacklight
Cmnd_Alias KEYBOARD_CMDS = /usr/bin/loadkeys, /usr/bin/keyd, /usr/bin/keyd reload
Cmnd_Alias USER_CMDS = /usr/bin/passwd
Cmnd_Alias STORAGE_CMDS = /usr/bin/udisksctl

# User privilege specification
%wheel ALL = (ALL:ALL) ALL
%wheel ALL = (ALL:ALL) NOPASSWD: SHUTDOWN_CMDS
%wheel ALL = (ALL:ALL) NOPASSWD: PACKAGE_MGMT_CMDS
%wheel ALL = (ALL:ALL) NOPASSWD: NETWORK_CMDS
%wheel ALL = (ALL:ALL) NOPASSWD: DISPLAY_CMDS
%wheel ALL = (ALL:ALL) NOPASSWD: KEYBOARD_CMDS
%wheel ALL = (ALL:ALL) NOPASSWD: USER_CMDS
%wheel ALL = (ALL:ALL) NOPASSWD: STORAGE_CMDS
```

> ⚠️ Always use `visudo` to edit sudoers files — it checks for syntax errors.

---

#### Method 2: Use `install` to copy a version-controlled config

If you maintain your sudoers files in version control (e.g., in `~/utono/system-config/`), you can copy them into place with correct permissions in a single step:

```bash
sudo install -m 440 -o root -g root $HOME/utono/system-config/etc/sudoers.d/00_wheel_nopasswd /etc/sudoers.d/
sudo visudo -c
```

---

### Ensure User Is in the `wheel` Group

Check your groups:

```bash
groups $USER
```

If you don’t see `wheel`, add yourself:

```bash
sudo usermod -aG wheel $USER
```

If you were just added to the `wheel` group, log out and back in for group changes to take effect.
Alternatively, you can run `newgrp wheel` to apply group changes immediately in the current shell.

If you already belonged to `wheel`, no logout is necessary — changes to `/etc/sudoers.d/` apply immediately.

---

### Test the Setup

Try the following commands:

```bash
sudo -k  # Reset sudo timestamp
sudo loadkeys  # Should not prompt for password
```

> You must use `sudo` even when password is not required unless you're using a frontend like `udisksctl`.

---

### Bonus: Make rsync-Friendly

If you're syncing this config file into another system (e.g., via USB drive), ensure you use:

```bash
sudo cp 00_wheel_nopasswd /etc/sudoers.d/
sudo visudo -c  # Validate
```
