## 🎮 How Gamepad Input Is Isolated to Neovim and MPV

To ensure gamepad input affects only Neovim and MPV (and not any other app), this setup uses **low-level input
access**, **custom Python logic**, and **systemd user services**. Here's how isolation is achieved:

---

### 🔒 Direct Reading from `/dev/input/event*`

Instead of letting the gamepad behave like a normal keyboard, the `$HOME/tty-dotfiles/bin-mlj/.local/bin/bin-mlj/gamepad/nvim-micro-gamepad.py` script opens the device
file (e.g., `/dev/input/event26`) and listens directly to raw input events. To prevent these events from being
received by any other process, the device is **exclusively grabbed** using `evdev`:

* The script calls `device.grab()` where `device` is an `evdev.InputDevice` instance
* Once grabbed, **no other program can read from the gamepad**, not even the desktop environment

This is critical for ensuring keystrokes from the gamepad are not interpreted by any window manager or other input
handler. It creates a "monopoly" on input: only the Python script sees the events.

---

### 🎯 How the Gamepad Is Identified and Grabbed

Before exclusive grabbing can occur, the gamepad must be precisely identified. This is done via **udev rules**, **manual inspection of `/dev/input/event*`**, and **Python `evdev` matching**.

#### 🔎 Device Detection and Matching

The Python script does *not* assume a fixed device path. Instead, it dynamically scans all available input devices:

```python
from evdev import InputDevice, list_devices

for path in list_devices():
    dev = InputDevice(path)
    if dev.name == "8BitDo Micro gamepad Keyboard" and dev.info.vendor == 0x2dc8 and dev.info.product == 0x9021:
        gamepad = dev
        break
```

This ensures robust identification even if the gamepad enumerates to a different `/dev/input/eventX` on reboot.

#### 📎 Why Vendor and Product ID?

The `vendor` and `product` IDs (e.g. `2dc8:9021`) uniquely identify the hardware. Even if the device name is ambiguous (some gamepads register as "Keyboard"), these IDs guarantee exact matching.

You can discover them with:

```bash
sudo evtest
# or
sudo udevadm info --attribute-walk --name=/dev/input/event26
```

#### 🔐 Exclusive Access with `grab()`

Once identified, the script opens the device and **calls `gamepad.grab()`**, which:

* Locks the device from all other applications, including X11/Wayland
* Prevents unintended input leaks to desktops, terminals, games, etc.
* Allows the script to safely intercept **only relevant key presses**

This is critical to isolating input to Neovim and MPV and is the linchpin of the sandboxed architecture.

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
* Key-like strings (e.g. "j", "k") to Neovim via its `--server` API

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

* `$HOME/tty-dotfiles/systemd/.config/systemd/user/nvim-micro-gamepad.path`: Watches for `/tmp/mpvsocket` (MPV IPC socket)
* `$HOME/tty-dotfiles/systemd/.config/systemd/user/nvim-micro-gamepad.service`: Starts the script when MPV is running
* `$HOME/tty-dotfiles/systemd/.config/systemd/user/nvim-micro-gamepad-stop.timer`: Periodically checks if the socket is gone and stops the service

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
systemctl --user stop nvim-micro-gamepad.service
systemctl --user disable --now nvim-micro-gamepad.path
systemctl --user stop nvim-micro-gamepad.service
systemctl --user disable --now nvim-micro-gamepad-stop.timer
systemctl --user stop nvim-micro-gamepad-stop.timer

rm ~/.config/systemd/user/nvim-micro-gamepad.*

systemctl --user daemon-reload
systemctl --user status

rm $HOME/.local/bin/bin-mlj/gamepad/nvim-micro-gamepad.py
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
sudo bluetoothctl

 sudo libinput list-devices | grep -A 5 Keyboard
Device:                  8BitDo Micro gamepad Keyboard
Kernel:                  /dev/input/event21
Id:                      bluetooth:2dc8:9021
Group:                   16
Seat:                    seat0, default
Capabilities:            keyboard pointer 

Note:

* Vendor ID: `2dc8`
* Product ID: `9021`
* Device path: `/dev/input/event21`

 ls -l /dev/input/event21                               
crw-rw---- 13,85 root  1 Jun 13:37  /dev/input/event21

 udevadm info --name=/dev/input/event21 --attribute-walk

...
  looking at device '/devices/virtual/misc/uhid/0005:2DC8:9021.0003/input/input26/event21':
    KERNEL=="event21"
    SUBSYSTEM=="input"
    DRIVER==""
    ATTR{power/control}=="auto"
    ATTR{power/runtime_active_time}=="0"
    ATTR{power/runtime_status}=="unsupported"
    ATTR{power/runtime_suspended_time}=="0"

  looking at parent device '/devices/virtual/misc/uhid/0005:2DC8:9021.0003/input/input26':
    KERNELS=="input26"
    SUBSYSTEMS=="input"
    DRIVERS==""
    ATTRS{capabilities/abs}=="100000000"
    ATTRS{capabilities/ev}=="12001f"
    ATTRS{capabilities/ff}=="0"
    ATTRS{capabilities/key}=="3f00033fff 0 0 483ffff17aff32d bfd4444600000000 1 130ff38b17d007 ffff7bfad941dfff ffbeffdfffefffff fffffffffffffffe"
    ATTRS{capabilities/led}=="1f"
    ATTRS{capabilities/msc}=="10"
    ATTRS{capabilities/rel}=="1040"
    ATTRS{capabilities/snd}=="0"
    ATTRS{capabilities/sw}=="0"
    ATTRS{id/bustype}=="0005"

    ATTRS{id/product}=="9021"
    ATTRS{id/vendor}=="2dc8"

    ATTRS{id/version}=="0100"
    ATTRS{inhibited}=="0"
    ATTRS{name}=="8BitDo Micro gamepad Keyboard"
    ATTRS{phys}=="98:59:7a:f7:60:ec"
    ATTRS{power/control}=="auto"
    ATTRS{power/runtime_active_time}=="0"
    ATTRS{power/runtime_status}=="unsupported"
    ATTRS{power/runtime_suspended_time}=="0"
    ATTRS{properties}=="0"
    ATTRS{uniq}=="e4:17:d8:5e:f4:f6"

  looking at parent device '/devices/virtual/misc/uhid/0005:2DC8:9021.0003':
    KERNELS=="0005:2DC8:9021.0003"
    SUBSYSTEMS=="hid"
    DRIVERS=="hid-generic"
    ATTRS{country}=="21"
    ATTRS{power/control}=="auto"
    ATTRS{power/runtime_active_time}=="0"
    ATTRS{power/runtime_status}=="unsupported"
    ATTRS{power/runtime_suspended_time}=="0"
lines 1-52

 sudo evtest

No device specified, trying to scan all of /dev/input/event*
Available devices:
/dev/input/event0:           Lid Switch
/dev/input/event1:           Power Button
/dev/input/event10:         VEN_04F3:00 04F3:32AA Mouse
/dev/input/event11:         VEN_04F3:00 04F3:32AA Touchpad
/dev/input/event12:         Dell Privacy Driver
/dev/input/event13:         Dell WMI hotkeys
/dev/input/event14:         PS/2 Generic Mouse
/dev/input/event15:         sof-soundwire Headset Jack
/dev/input/event16:         sof-soundwire HDMI/DP,pcm=5
/dev/input/event17:         sof-soundwire HDMI/DP,pcm=6
/dev/input/event18:         sof-soundwire HDMI/DP,pcm=7
/dev/input/event19:         keyd virtual keyboard
/dev/input/event2:           Sleep Button
/dev/input/event20:         keyd virtual pointer
/dev/input/event21:         8BitDo Micro gamepad Keyboard
/dev/input/event3:           Power Button
/dev/input/event4:           AT Translated Set 2 keyboard
/dev/input/event5:           Video Bus
/dev/input/event6:           Video Bus
/dev/input/event7:           Intel HID events
/dev/input/event8:           Intel HID 5 button array
/dev/input/event9:           PC Speaker
Select the device event number [0-21]: 

```

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
 pwd                
/home/mlj/.local/bin/bin-mlj/gamepad
 la               
lrwxrwxrwx - mlj 31 May 04:26  add_chapter_from_nvim.sh -> ../../../../tty-dotfiles/bin-mlj/.local/bin/bin-mlj/gamepad/add_chapter_from_nvim.sh
lrwxrwxrwx - mlj 31 May 04:26  nvim-micro-gamepad.py -> ../../../../tty-dotfiles/bin-mlj/.local/bin/bin-mlj/gamepad/nvim-micro-gamepad.py

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

---

## ⚠️ What To Do When You Change `nvim-micro-gamepad.py`

Any change to your gamepad integration script **requires reloading the systemd service** and possibly restarting your input permissions.
**If you edit or replace**
`$HOME/tty-dotfiles/bin-mlj/.local/bin/bin-mlj/gamepad/nvim-micro-gamepad.py`,
follow these steps **to ensure the new code is in effect**:

---

### 1. Resymlink or Restow (If Moved/Renamed)

If you’ve moved, renamed, or restructured the file, update the symlink with GNU Stow:

```bash
cd ~/tty-dotfiles
stow --verbose --no-folding bin-mlj
```

---

### 2. Make Sure Script Is Executable

```bash
chmod +x ~/tty-dotfiles/bin-mlj/.local/bin/bin-mlj/gamepad/nvim-micro-gamepad.py
```

---

### 3. **Reload and Restart the systemd User Service**

This ensures systemd picks up the new version and restarts it if it’s already running:

```bash
systemctl --user daemon-reload
systemctl --user restart nvim-micro-gamepad.service
```

If you’re using the path or timer unit for MPV auto-activation, also restart those if necessary:

```bash
systemctl --user restart nvim-micro-gamepad.path
systemctl --user restart nvim-micro-gamepad-stop.timer
```

---

### 4. (Optional) Check Journal for Errors

Immediately after restart, check for Python errors, import issues, or device grab failures:

```bash
journalctl --user -u nvim-micro-gamepad.service -f
```

---

### 5. **If You Modified Device Access Logic:**

If your change affects which `/dev/input/event*` device is opened or how permissions are handled:

* **Power cycle the gamepad** (off/on) if it disconnects.
* If you changed the udev rule, reload rules and unplug/replug or power cycle the gamepad:

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

---

### 6. **If the Script Fails To Start or Can’t Grab the Device**

* Make sure no old script instance is running (`ps aux | grep nvim-micro-gamepad` and `kill` if needed)
* If the device is already grabbed, only a system reboot or full power-cycle will fully release it.

---

### 7. **Summary Table**

| Action                                                | When Required                                 |
| ----------------------------------------------------- | --------------------------------------------- |
| `stow` or relink                                      | After moving/renaming the script              |
| `chmod +x`                                            | If the script isn’t executable                |
| `systemctl --user daemon-reload`                      | After editing the script                      |
| `systemctl --user restart nvim-micro-gamepad.service` | After every change (code, path, permissions)  |
| `journalctl --user -u nvim-micro-gamepad.service -f`  | Debug Python or device issues                 |
| `sudo udevadm control --reload-rules`                 | If you modified device permissions/udev rules |
| Power cycle device                                    | If device remains grabbed/locked              |

---

**If the service still won’t run after editing:**

* Double-check the path, permissions, and that the device is present.
* Try disabling/enabling the user service:

  ```bash
  systemctl --user disable --now nvim-micro-gamepad.service
  systemctl --user enable --now nvim-micro-gamepad.service
  ```
* Log out/in or reboot if all else fails.

---

Add this right after your setup steps (or as an appendix), so you always have a reliable post-edit checklist for updating and testing your gamepad script integration!

