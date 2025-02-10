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
udevadm info --attribute-walk --name=/dev/input/eventX | grep -E 'ATTRS{id/vendor}|ATTRS{id/product}'
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
        sys_path = f"/sys/class/input/{os.path.basename(device.path)}/device/"
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

---

## **Granting the Gamepad Access to the `input` Group**

If the device is not in the `input` group, create a custom `udev` rule:

1. Navigate to the `udev` rules directory:
   ```bash
   cd ~/utono/system-config/etc/udev/rules.d
   cp 99-gamepad.rules /etc/udev/rules.d/
   ```
2. Edit the rule:
   ```bash
   sudo nvim /etc/udev/rules.d/99-gamepad.rules
   ```
   Add one of the following lines:
   
   **Option 1: Assign by `eventX` (not recommended due to changing event numbers)**
   ```ini
   KERNEL=="event*", ATTRS{DEVNAME}=="/dev/input/eventX", GROUP="input", MODE="0660"
   ```
   Replace `eventX` with the actual device event number.
   
   **Option 2: Assign by Vendor and Product ID (preferred method)**
   ```ini
   KERNEL=="event*", ATTRS{id/vendor}=="2dc8", ATTRS{id/product}=="9021", GROUP="input", MODE="0660"
   ```
   This ensures that the correct gamepad always gets assigned to the `input` group, even if the event number changes.

3. Save and exit, then reload `udev` rules:
   ```bash
   sudo udevadm control --reload-rules
   sudo udevadm trigger
   ```

4. Verify the change:
   
   **Option 1: Using `udevadm` with Vendor and Product ID**
   ```bash
   udevadm info --attribute-walk --name=/dev/input/eventX | grep -E 'ATTRS{id/vendor}|ATTRS{id/product}'
   ```
   If the output includes the correct `id/vendor` and `id/product` values, the rule is correctly applied.
   
   **Option 2: Checking permissions directly**
   ```bash
   ls -l /dev/input/eventX
   ```
   If the group listed is `input` and the permissions include `rw-rw----`, then the rule was applied successfully.

5. **Ensure Your User is in the `input` Group**
   ```bash
   sudo usermod -aG input $(whoami)
   ```
   Log out and log back in for the changes to take effect.

6. **Verify Group Membership**
   ```bash
   groups | grep input
   ```
   If `input` is listed, your user has the required permissions.

---

This ensures that the gamepad has proper permissions and can be used automatically by MPV without requiring manual intervention.
