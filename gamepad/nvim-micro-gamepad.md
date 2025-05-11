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
```bash
 cp ~/utono/system-config/etc/udev/rules.d/99-gamepad.rules .
'/home/mlj/utono/system-config/etc/udev/rules.d/99-gamepad.rules' -> './99-gamepad.rules'
cp: cannot create regular file './99-gamepad.rules': Permission denied

 sudo cp ~/utono/system-config/etc/udev/rules.d/99-gamepad.rules .
[sudo] password for mlj: 

 sudo udevadm control --reload-rules                              

 sudo udevadm trigger               
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
sudo pacman -S python-evdev python-psutil socat blueman bluetuith
```

If you're using Hyprland:

```bash
sudo pacman -S hyprland jq
```

---

## ✅ 2. Identify the Gamepad

```bash
sudo keyd monitor
blueman-manager  # or bluetuith
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

```bash
sudo nano /etc/udev/rules.d/99-gamepad.rules
```

Paste:

```udev
SUBSYSTEM=="input", ATTRS{id/vendor}=="2dc8", ATTRS{id/product}=="9021", GROUP="input", MODE="0660"
```

Apply:

```bash
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

## ✅ 7. Save Gamepad Script

```bash
mkdir -p ~/.config/mpv/python-scripts
nano ~/.config/mpv/python-scripts/nvim-micro-gamepad.py
```

Paste the final `nvim-micro-gamepad.py` script.

Make it executable:

```bash
chmod +x ~/.config/mpv/python-scripts/nvim-micro-gamepad.py
```

Symlink to `~/.local/bin`:

```bash
mkdir -p ~/.local/bin
ln -sf ~/.config/mpv/python-scripts/nvim-micro-gamepad.py ~/.local/bin/nvim-micro-gamepad
```

---

## ✅ 8. Create systemd Service

```bash
mkdir -p ~/.config/systemd/user
nano ~/.config/systemd/user/nvim-micro-gamepad.service
```

Paste:

```ini
[Unit]
Description=Gamepad-to-Neovim+MPV bridge (8BitDo Micro)
After=graphical-session.target

[Service]
ExecStart=%h/.config/mpv/python-scripts/nvim-micro-gamepad.py
Restart=on-failure
RestartSec=2
Environment=PATH=%h/.local/bin:/usr/bin:/bin

[Install]
WantedBy=default.target
```

Enable and start:

```bash
systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable --now nvim-micro-gamepad.service
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
nvim --listen /tmp/nvim.sock
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
mkdir -p ~/.local/bin
nano ~/.local/bin/nvim-listen
chmod +x ~/.local/bin/nvim-listen
```

Alias it:

```bash
echo 'alias nvim="nvim-listen"' >> ~/.bashrc  # or ~/.zshrc
source ~/.bashrc
```

Temporarily bypass:

```bash
\nvim file.txt
/usr/bin/nvim file.txt
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
