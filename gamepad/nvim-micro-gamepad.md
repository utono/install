## 🎮 How Gamepad Input Is Isolated to Neovim and MPV

To ensure gamepad input affects only Neovim and MPV (and not any other app), this setup uses **low-level input
access**, **custom Python logic**, and **systemd user services**. Here's how isolation is achieved:

---

### 🔒 Direct Reading from `/dev/input/event*`

Instead of letting the gamepad behave like a normal keyboard, the `nvim-micro-gamepad.py` script opens the device
file (e.g., `/dev/input/event26`) and listens directly to raw input events. To prevent these events from being
received by any other process, the device is **exclusively grabbed** using `evdev`:

* The script calls `device.grab()` where `device` is an `evdev.InputDevice` instance
* Once grabbed, **no other program can read from the gamepad**, not even the desktop environment

This is critical for ensuring keystrokes from the gamepad are not interpreted by any window manager or other input
handler. It creates a "monopoly" on input: only the Python script sees the events.

---

### ⚙️ systemd Path and Timer Units

To ensure the script runs only when MPV is active, a pair of systemd units are used:

* `nvim-micro-gamepad.path`: Watches for `/tmp/mpvsocket` (MPV IPC socket)
* `nvim-micro-gamepad.service`: Starts the script when MPV is running
* `nvim-micro-gamepad-stop.timer`: Periodically checks if the socket is gone and stops the service

This guarantees:

* The gamepad isn’t read or grabbed unless MPV is running
* The service is automatically cleaned up when MPV exits

---

### 🧠 Socket-Based Targeting of MPV and Neovim

MPV and Neovim are controlled **only via their respective Unix sockets**:

* MPV: `/tmp/mpvsocket`
* Neovim: `/tmp/nvim.sock` (or dynamic variant via `nvim-listen`)

The script sends:

* JSON commands to MPV via socket or `socat`
* Key-like strings (e.g. `"j"`, `"k"`) to Neovim via its `--server` API

Since all commands are socket-targeted, no other application can receive them accidentally.

---

### ✅ Summary

| Mechanism                | Role in Isolation                            |
| ------------------------ | -------------------------------------------- |
| `device.grab()`          | Prevents system-wide key propagation         |
| MPV socket path check    | Ensures script runs only when MPV is active  |
| systemd path/timer units | Start/stop service as MPV appears/disappears |
| IPC socket targeting     | Restricts delivery to MPV and Neovim only    |

Together, these components form a sandbox: your gamepad operates *only* inside MPV and Neovim.

# Neovim + MPV Gamepad Integration with Systemd

This guide sets up a Bluetooth keyboard-style gamepad (e.g. 8BitDo Micro) to:

* Send keystrokes exclusively to a Python script
* Send commands to MPV via its IPC socket
* Retrieve the current line from the focused Neovim instance and send it to MPV as a chapter title

---

## 🔁 Undo Setup (Start Fresh)

If you'd like to undo the udev rules and start from scratch:

```bash
sudo rm /etc/udev/rules.d/99-gamepad.rules
sudo udevadm control --reload-rules
sudo udevadm trigger

```
You should also remove your systemd user services:

```bash
systemctl --user disable --now nvim-micro-gamepad.service
systemctl --user disable --now nvim-micro-gamepad.path
systemctl --user disable --now nvim-micro-gamepad-stop.timer
rm ~/.config/systemd/user/nvim-micro-gamepad.*
rm ~/.config/mpv/python-scripts/nvim-micro-gamepad.py
```

⚠️ **Do not enable `nvim-micro-gamepad-stop.service` directly.** It is triggered only by its timer and is not meant to run standalone.

Reboot or log out/in to fully clear any device group permissions.

---

## ✅ 1. Install Required Packages

```bash
sudo pacman -S --needed python-evdev python-psutil socat
```

If you're using Hyprland:

```bash
sudo pacman -S --needed hyprland jq
```

---

## ✅ 2. Identify the Gamepad

```bash
sudo keyd monitor
blueman-manager
```

Look for:

```
device added: 2dc8:9021:... 8BitDo Micro gamepad Keyboard (/dev/input/event26)
```

Note:

* Vendor ID: `2dc8`
* Product ID: `9021`
* Device path: `/dev/input/event26`

---

## ✅ 3. Test Input

```bash
sudo evtest /dev/input/event26
```

---

## ✅ 4. Grant Access to Input

🔍 First, check if your user is already in the `input` group:

```bash
groups $USER | grep input
```

If not, add yourself to the group:

```bash
sudo usermod -aG input $USER
newgrp input  # or reboot your system for group membership to fully apply
```

---

After rebooting, verify your group membership:

```bash
groups $USER
```

You should see `input` listed among your groups.

---

## ✅ 5. Create Udev Rule

Apply:

```bash
sudo cp -v ~/utono/system-config/etc/udev/rules.d/99-gamepad.rules /etc/udev/rules.d
'/home/mlj/utono/system-config/etc/udev/rules.d/99-gamepad.rules' -> './99-gamepad.rules'
cp: cannot create regular file './99-gamepad.rules': Permission denied

sudo udevadm control --reload-rules
sudo udevadm trigger
sudo udevadm settle
```
Then turn the gamepad off and on.

---

## ✅ 6. Configure MPV IPC

Edit `~/.config/mpv/mpv.conf`:

```ini
input-ipc-server=/tmp/mpvsocket
```

Make socket world-readable:

```bash
chmod 666 /tmp/mpvsocket
```

---

## ✅ 7. symlink gamepad Script

```bash
cd ~/tty-dotfiles
stow --verbose --no-folding bin-mlj
ls -al ~/.local/bin/bin-mlj/gamepad 
   lrwxrwxrwx - mlj 11 May 13:07  mpv-micro-gamepad.py -> ../../../../tty-dotfiles/bin-mlj/.local/bin/bin-mlj/gamepad/mpv-micro-gamepad.py
   lrwxrwxrwx - mlj 11 May 13:07  nvim-micro-gamepad.py -> ../../../../tty-dotfiles/bin-mlj/.local/bin/bin-mlj/gamepad/nvim-micro-gamepad.py
   lrwxrwxrwx - mlj 11 May 13:07  zero-to-mpv-19.py -> ../../../../tty-dotfiles/bin-mlj/.local/bin/bin-mlj/gamepad/zero-to-mpv-19.py
chmod +x ~/tty-dotfiles/bin-mlj/.local/bin/bin-mlj/gamepad/nvim-micro-gamepad.py
```
---

## ✅ 8. Create systemd Service

```bash
stow --verbose --no-folding systemd -n
   MKDIR: .config/systemd/user
   LINK: .config/systemd/user/mpv-micro-gamepad.service => ../../../tty-dotfiles/systemd/.config/systemd/user/mpv-micro-gamepad.service
   LINK: .config/systemd/user/nvim-micro-gamepad-stop.service => ../../../tty-dotfiles/systemd/.config/systemd/user/nvim-micro-gamepad-stop.service
   LINK: .config/systemd/user/nvim-micro-gamepad-stop.timer => ../../../tty-dotfiles/systemd/.config/systemd/user/nvim-micro-gamepad-stop.timer
   LINK: .config/systemd/user/nvim-micro-gamepad.path => ../../../tty-dotfiles/systemd/.config/systemd/user/nvim-micro-gamepad.path
   LINK: .config/systemd/user/nvim-micro-gamepad.service => ../../../tty-dotfiles/systemd/.config/systemd/user/nvim-micro-gamepad.service
```
Enable and start:

```bash
systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable --now nvim-micro-gamepad.service
Created symlink '/home/mlj/.config/systemd/user/default.target.wants/nvim-micro-gamepad.service' -> '/home/mlj/tty-dotfiles/systemd/.config/systemd/user/nvim-micro-gamepad.service'
```

---

## ✅ 9. Optional: Autostart Only When MPV is Running

### (a) Path Unit (starts service when MPV socket appears)

```bash
nano ~/.config/systemd/user/nvim-micro-gamepad.path
```

```ini
[Unit]
Description=Start gamepad bridge when MPV socket appears

[Path]
PathExists=/tmp/mpvsocket
Unit=nvim-micro-gamepad.service

[Install]
WantedBy=default.target
```

### (b) Timer + Stop Service (stops service when MPV closes)

```bash
nano ~/.config/systemd/user/nvim-micro-gamepad-stop.service
```

```ini
[Unit]
Description=Stop gamepad bridge when MPV socket disappears
ConditionPathExists=!/tmp/mpvsocket

[Service]
Type=oneshot
ExecStart=systemctl --user stop nvim-micro-gamepad.service
```

```bash
nano ~/.config/systemd/user/nvim-micro-gamepad-stop.timer
```

```ini
[Unit]
Description=Poll to stop gamepad bridge if MPV socket is gone

[Timer]
OnUnitActiveSec=10
AccuracySec=2s
Unit=nvim-micro-gamepad-stop.service

[Install]
WantedBy=default.target
```

Enable both:

```bash
systemctl --user enable --now nvim-micro-gamepad.path
systemctl --user enable --now nvim-micro-gamepad-stop.timer
```

---

## ✅ 10. Start Neovim with Socket

```bash
chmod +x ~/tty-dotfiles/bin-mlj/.local/bin/bin-mlj/nvim/nvim-listen
chmod +x ~/tty-dotfiles/bin-mlj/.local/bin/bin-mlj/nvim/*
nvim --listen /tmp/nvim.sock
which on
on: aliased to nvim-listen
```

Or create a wrapper:

```bash
#!/usr/bin/env bash
TTY_ID=$(tty | sed 's|/dev/||g' | tr '/' '_')
SOCKET="/tmp/nvim-$USER-$TTY_ID.sock"
exec nvim --listen "$SOCKET" "$@"
```

Save it as:

```bash
mkdir -p ~/.local/bin/bin-mlj/nvim
nano -p ~/.local/bin/bin-mlj/nvim/nvim-listen
```

Alias it:

```bash
echo 'alias on="nvim-listen"' >> ~/.bashrc  # or ~/.zshrc
source ~/.bashrc
```

Or set socket discovery explicitly:

```bash
export NVIM_LISTEN_ADDRESS=/tmp/nvim.sock
```

---

## ✅ Done

* Press gamepad buttons to send commands to MPV or add chapters
* Chapter titles come from the focused Neovim line
* Logs: `journalctl --user -u nvim-micro-gamepad.service -f`
