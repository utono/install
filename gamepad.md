# Configuring Gamepad Input for MPV Using Evdev

---

## Essential Packages

Ensure the required dependencies are installed:

```bash
sudo pacman -S python-evdev socat
```

---

## Get Device ID

To identify the gamepad device, follow these steps:

1. **Monitor Input Events**
   Open a terminal and start monitoring input events before pairing the gamepad:
   ```bash
   sudo keyd monitor
   ```

2. **Pair the Gamepad**
   In another terminal, use `bluetuith` to pair your gamepad:
   ```bash
   bluetuith
   ```

3. **Check the Assigned Event Device**
   Once paired, return to the `keyd monitor` tab. You should see an output similar to:
   ```
   device added: 2dc8:9021:27abd54c 8BitDo Micro gamepad Keyboard (/dev/input/eventX)
   ```

### **Finding the Vendor ID and Product ID**

Instead of manually setting `/dev/input/eventX`, you can find your gamepad's **Vendor ID** and **Product ID** using:

```bash
udevadm info --query=all --name=/dev/input/eventX | grep -E 'ID_VENDOR_ID|ID_MODEL_ID'
```

Alternatively, you can find all input devices and their properties:

```bash
cat /proc/bus/input/devices
```

Look for your gamepad entry, which will show lines like:
```
I: Bus=0005 Vendor=2dc8 Product=9021 Version=011b
```
- **Vendor ID**: `2dc8`
- **Product ID**: `9021`

You can then use these values in your script.

### **Dynamically Locating the Gamepad**

Instead of manually setting `DEVICE_PATH='/dev/input/eventX'`, dynamically locate the gamepad using its **Vendor ID** and **Product ID**:

```python
#!/usr/bin/env python3

import os
import socket
import json
import time
from evdev import InputDevice, list_devices, categorize, ecodes

VENDOR_ID = "2DC8"  # Your gamepad's Vendor ID
PRODUCT_ID = "9021"  # Your gamepad's Product ID
MPV_SOCKET = "/tmp/mpvsocket"


def find_device():
    """Find device path using vendor/product ID."""
    for dev_path in list_devices():
        device = InputDevice(dev_path)
        sys_path = f"/sys/class/input/{os.path.basename(device.fn)}/device/"
        try:
            with open(f"{sys_path}id/vendor") as f:
                vid = f.read().strip()
            with open(f"{sys_path}id/product") as f:
                pid = f.read().strip()
            if vid.lower() == VENDOR_ID.lower() and pid.lower() == PRODUCT_ID.lower():
                return dev_path
        except FileNotFoundError:
            continue
    return None

... (rest of the script remains unchanged) ...














# Configuring Gamepad Input for MPV Using Evdev

---

## Essential Packages

sudo pacman -S python-evdev socat

## Get device id

Start 'sudo keyd monitor' in a tab before pairing gamepad 
in another tab using bluetuith.

   sudo keyd monitor
   bluetuith
   sudo keyd monitor
      device added: 2dc8:9021:27abd54c 8BitDo Micro gamepad Keyboard (/dev/input/eventX)

   nvim ~/.config/mpv/scripts/micro-to-mpv-X.py:

      DEVICE_PATH='/dev/input/eventX'

## Add the Device to the `input` Group**

If the device is not in the `input` group, create a custom `udev` rule:

   cd ~/utono/system-config/etc/udev/rules.d
   cp 99-gamepad.rules /etc/udev/rules.d/
   sudo nvim /etc/udev/rules.d/99-gamepad.rules

Add the following line, replacing `Your Device Path` with the `DEVNAME` value found earlier:

   KERNEL=="event*", ATTRS{DEVNAME}=="/dev/input/eventX", GROUP="input", MODE="0660"

Save and exit, then reload `udev` rules:

   sudo udevadm control --reload-rules
   sudo udevadm trigger

   udevadm info --query=property --name=/dev/input/eventX | grep GROUP

If the output includes `GROUP=input`, then the device belongs to the `input` group.

## Add User to the Input Group

   sudo usermod -aG input $(whoami)

Log out and back in.
Group changes take effect after re-logging.

Verify Group Membership

   groups

## Enable MPV's IPC Server

nvim ~/.config/mpv/mpv.conf

   input-ipc-server=/tmp/mpvsocket

chmod 666 /tmp/mpvsocket

## Test python script

   cd ~/.config/mpv/scripts/
   /usr/bin/python3 micro-to-mpv-X.py

## Automate the Script with systemd

mkdir -p ~/.config/systemd/user
cd ~/tty-dotfiles/systemd/.config/systemd/user
cp gamepad_to_mpv.service ~/.config/systemd/user/gamepad_to_mpv.service
systemctl --user daemon-reload
systemctl --user enable --now gamepad_to_mpv.service
reboot
systemctl --user status gamepad_to_mpv.service

---

## Step 7: Test the Setup

1. Start MPV with your video file:

   ```bash
   mpv your_video_file.mkv
   ```

2. Ensure the Python script is running:

   ```bash
   systemctl --user status gamepad_to_mpv.service
   ```

3. Verify the MPV socket exists:

   ```bash
   ls /tmp/mpvsocket
   ```

4. Send test commands to MPV (optional):  

   ```bash
   echo '{ "command": ["cycle", "pause"] }' | socat - /tmp/mpvsocket
   ```

---

## Debugging

- Restart the service if needed:

  ```bash
  systemctl --user restart gamepad_to_mpv.service
  ```

- View logs:

  ```bash
  journalctl --user -u gamepad_to_mpv.service
  ```

- Stop the service:

  ```bash
  systemctl --user stop gamepad_to_mpv.service
  ```

This setup ensures the gamepad (acting as a keyboard) exclusively controls MPV.

cat /proc/bus/input/devices

   Handlers=event13


