# Configuring Gamepad Input for MPV Using Evdev

---

## Essential Packages

Ensure the required dependencies are installed:

```bash
sudo pacman -S python-evdev socat
```

- **python-evdev**: Provides the ability to interact with input devices, allowing the script to capture gamepad events.
- **socat**: Enables communication with MPV's IPC socket, allowing commands to be sent to MPV from the script.

---

## Get Device ID

To identify the gamepad device, follow these steps:

1. **Monitor Input Events**
   Open a terminal and start monitoring input events before pairing the gamepad:
   ```bash
   sudo keyd monitor
   ```
   This command listens for input events from all connected devices. It helps verify that the gamepad is detected and shows the event number (`eventX`) assigned to it. Look for an entry corresponding to your gamepad.

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

## **Finding the Vendor ID and Product ID**

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


## **Making the Gamepad Exclusive to MPV**

To prevent other applications or the system from interpreting gamepad inputs, follow these steps:

**1. Modify the Python Script to Grab the Device**
Your script already includes `device.grab()`, which ensures the gamepad is exclusively used by the script while it is running. However, to make this setting persist, we need an additional step.

**2. Create a `udev` Rule to Prevent System-wide Recognition**
This step ensures the gamepad is not treated as a generic keyboard or joystick by the system.

1. **Create/Edit the udev rule:**
   ```bash
   sudo nvim /etc/udev/rules.d/99-mpv-gamepad.rules
   ```


2. **Add the following combined rule, replacing Vendor and Product ID if needed:**
   ```ini
   # Assign the gamepad to the input group and set appropriate permissions
   KERNEL=="event*", ATTRS{idVendor}=="2dc8", ATTRS{idProduct}=="9021", GROUP="input", MODE="0660"
   
   # Prevent the gamepad from being recognized as a keyboard or joystick by the system
   SUBSYSTEM=="input", ATTRS{id/vendor}=="2dc8", ATTRS{id/product}=="9021", ENV{ID_INPUT_KEYBOARD}="", ENV{ID_INPUT_JOYSTICK}=""
   ```

3. **Reload the udev rules and replug the gamepad:**
   ```bash
   sudo udevadm control --reload-rules
   sudo udevadm trigger

This prevents the gamepad from being recognized as a standard input device, ensuring only your script handles its input.

## ~/.config/mpv/python-scripts/micro-gamepad.py

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
    """Find the gamepad device path using Vendor ID and Product ID."""
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


def send_to_mpv(command):
    retries = 5
    for attempt in range(retries):
        try:
            with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
                sock.connect(MPV_SOCKET)
                sock.sendall(json.dumps(command).encode() + b'\n')
            return
        except ConnectionRefusedError:
            if attempt < retries - 1:
                time.sleep(2)
            else:
                print("Error: MPV socket connection refused. Is MPV running with --input-ipc-server?")
        except Exception as e:
            print(f"Error sending command to MPV: {e}")
            return


# if 'd' is the gamepad press, assign to real_prog_dvorak 'h'
key_map = {
    ecodes.KEY_M: {"command": ["cycle", "pause"]},
    ecodes.KEY_R: {"command": ["show-progress"]},
    ecodes.KEY_J: {"command": ["show-progress"]},
    ecodes.KEY_I: {"command": ["add", "chapter", -1]},
    ecodes.KEY_G: {"command": ["add", "chapter", 1]},
    ecodes.KEY_O: {"command": ["script-message", "add_chapter"]},
    ecodes.KEY_N: {"command": ["no-osd", "seek", 2, "exact"]},
    ecodes.KEY_S: {"command": ["no-osd", "seek", -2, "exact"]},
    ecodes.KEY_H: {"command": ["script-message", "write_chapters"]},
    ecodes.KEY_F: {"command": ["script-message", "remove_chapter"]},
    ecodes.KEY_E: {"command": ["show-progress"]},
    ecodes.KEY_C: {"command": ["add", "volume", 2]},
    ecodes.KEY_D: {"command": ["add", "volume", -2]},
}


def open_device():
    """Find and open the gamepad device."""
    while True:
        device_path = find_device()
        if device_path:
            try:
                device = InputDevice(device_path)
                device.grab()
                print(f"Listening to {device.name} at {device_path}...")
                return device
            except OSError as e:
                if e.errno == 16:  # Device is busy
                    print(f"Device {device_path} is busy. Retrying...")
                    time.sleep(2)
                else:
                    print(f"Unhandled OSError: {e}")
        else:
            print("Gamepad not found. Retrying...")
            time.sleep(2)


def main():
    """Main event loop for reading gamepad input and sending commands to MPV."""
    while True:
        device = open_device()
        try:
            for event in device.read_loop():
                if event.type == ecodes.EV_KEY:
                    key_event = categorize(event)
                    if key_event.keystate == key_event.key_down:
                        command = key_map.get(key_event.scancode)
                        if command:
                            send_to_mpv(command)
        except OSError as e:
            if e.errno == 19:
                print("Device disconnected. Reinitializing...")
                device.close()
            else:
                print(f"Unhandled OSError: {e}")


if __name__ == "__main__":
    main()

```

## **Testing `micro-gamepad.py` Before Configuring Systemd**

Before setting up the systemd service, verify that `micro-gamepad.py` works correctly:

1. **Ensure MPV is running with IPC enabled:**
   ```bash
   mpv --input-ipc-server=/tmp/mpvsocket your_video_file.mkv
   ```

2. **Run the script manually:**
   ```bash
   python3 ~/.config/mpv/python-scripts/micro-gamepad.py
   ```

3. **Test gamepad input:**
   - Press buttons on the gamepad.
   - Check if MPV responds as expected.
   - Look for logs indicating successful command execution.

4. **If MPV does not respond:**
   - Ensure the MPV socket exists: `ls -l /tmp/mpvsocket`
   - Manually send a command to MPV for testing:
     ```bash
     echo '{ "command": ["cycle", "pause"] }' | socat - /tmp/mpvsocket
     ```
   - Restart MPV and re-run the script.

Once confirmed working, proceed with configuring systemd.

## **micro-gamepad.service Systemd Configuration**

Create the following systemd service file at `~/.config/systemd/user/micro-gamepad.service`:

```ini
[Unit]
Description=8BitDo Mico gamepad as keyboard to MPV
# After=mpv.service
Before=mpv.service

[Service]
ExecStart=/usr/bin/python3 /home/mlj/.config/mpv/python-scripts/micro-gamepad.py
# ExecStart=/usr/bin/python3 /home/mlj/.config/mpv/scripts/micro-gamepad.py
# ExecStart=/usr/bin/python3 /home/mlj/.config/mpv/scripts/micro-to-mpv-26.py
Restart=always
Environment=PYTHONUNBUFFERED=1
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
```

## **Placing the Service File**

1. **Ensure the systemd user directory exists**:
   ```bash
   mkdir -p ~/.config/systemd/user
   ```

2. **Move the service file into place**:
   ```bash
   cp micro-gamepad.service ~/.config/systemd/user/micro-gamepad.service
   ```

3. **Reload systemd to recognize the new service**:
   ```bash
   systemctl --user daemon-reload
   ```

4. **Enable and Start the Service**
   ```bash
   systemctl --user enable --now micro-gamepad.service
   ```

5. **Check the Service Status**
   ```bash
   systemctl --user status micro-gamepad.service
   ```

6. **Restart the Service**
   ```bash
   systemctl --user restart micro-gamepad.service
   ```

7. **Stop the Service**
   ```bash
   systemctl --user stop micro-gamepad.service
   ```

## **When to Use `daemon-reload` vs `daemon-reexec`**

## **`systemctl --user daemon-reload`**
- **Purpose:** Reloads systemd’s configuration files **without restarting running services**.
- **Use when:**
  - Modifying or creating a new systemd service file.
  - Updating an existing service but keeping running services untouched.

## **`systemctl --user daemon-reexec`**
- **Purpose:** Fully restarts the systemd user instance, **restarting all user services**.
- **Use when:**
  - Systemd itself has been updated.
  - Services are behaving unexpectedly and need a full reset.
  - You need to refresh systemd’s internal state beyond just reloading unit files.

These commands ensure that the gamepad integration service starts automatically and can be manually controlled when needed.
