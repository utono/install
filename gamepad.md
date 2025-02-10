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

## **Managing the `micro-blue.service` Systemd Service**

To ensure the service starts automatically and can be managed manually, use the following commands:

1. **Reload the Systemd User Daemon** (use this after modifying systemd service files):
   ```bash
   systemctl --user daemon-reload
   ```

2. **Fully Restart the Systemd User Daemon** (use this when systemd itself is updated or behaving unexpectedly):
   ```bash
   systemctl --user daemon-reexec
   ```

3. **Enable and Start the Service**
   ```bash
   systemctl --user enable --now micro-blue.service
   ```

4. **Check the Service Status**
   ```bash
   systemctl --user status micro-blue.service
   ```

5. **Restart the Service**
   ```bash
   systemctl --user restart micro-blue.service
   ```

6. **Stop the Service**
   ```bash
   systemctl --user stop micro-blue.service
   ```

### **When to Use `daemon-reload` vs `daemon-reexec`**

#### **`systemctl --user daemon-reload`**
- **Purpose:** Reloads systemd’s configuration files **without restarting running services**.
- **Use when:**
  - Modifying or creating a new systemd service file.
  - Updating an existing service but keeping running services untouched.

#### **`systemctl --user daemon-reexec`**
- **Purpose:** Fully restarts the systemd user instance, **restarting all user services**.
- **Use when:**
  - Systemd itself has been updated.
  - Services are behaving unexpectedly and need a full reset.
  - You need to refresh systemd’s internal state beyond just reloading unit files.

These commands ensure that the gamepad integration service starts automatically and can be manually controlled when needed.
