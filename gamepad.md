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

2. **Pair ERGO K860**

   Type code show in the notification.
   
   ```bash
   blueman-manager
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
4. **Test the Gamepad Input
   ```
    evtest /dev/input/eventX
   ```


## **Finding the Vendor ID and Product ID**

Instead of manually setting `/dev/input/eventX`, you can find your gamepad's **Vendor ID** and **Product ID** using:

```bash
udevadm info --attribute-walk --name=/dev/input/eventX | grep -E 'ATTRS{id/vendor}|ATTRS{id/product}'
looking at device '/devices/virtual/misc/uhid/0005:2DC8:9021.0003/input/input26/event21':
    KERNEL="event21"
    ...
looking at parent device '/devices/virtual/misc/uhid/0005:2DC8:9021.0003/input/input26':
    KERNEL="input26"
    ...
    ATTRS{id/product}=="9021"
    ATTRS{id/vendor}=="2dc8"
    ...
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

1. **Modify the Python Script to Grab the Device**
Your script already includes `device.grab()`, which ensures the gamepad is exclusively used by the script while it is running. However, to make this setting persist, we need an additional step.

2. **Create a `udev` Rule to Prevent System-wide Recognition**
This step ensures the gamepad is not treated as a generic keyboard or joystick by the system.

1. ``` cp ~/utono/system-config/etc/udev/rules.d/99-gamepad.rules /etc/udev/rules.d/

2. ``` sudo nvim /etc/udev/rules.d/99-mpv-gamepad.rules

   # Assign the gamepad to the input group and set appropriate permissions
   # Prevent the gamepad from being recognized as a keyboard or joystick by the system

   ``` SUBSYSTEM=="input", ATTRS{id/vendor}=="2dc8", ATTRS{id/product}=="9021", GROUP="input", MODE="0660"
   ``` SUBSYSTEM=="input", ATTRS{id/vendor}=="2dc8", ATTRS{id/product}=="9021", ENV{ID_INPUT_KEYBOARD}="1", ENV{ID_INPUT_JOYSTICK}="1"

3. **Turn off gamepad

4. **Reload the udev rules and replug the gamepad:**
   ```bash
   sudo udevadm control --reload-rules
   sudo udevadm trigger

This prevents the gamepad from being recognized as a standard input device, ensuring only your script handles its input.

3. **Verify udev rules are applied:
    ```bash
    udevadm info --attribute-walk --name=/dev/input/eventX | grep -E "ATTRS{id/vendor}|ATTRS{id/product}"

    If the correct Vendor ID (2DC8) and Product ID (9021) appear, the rule is applied.

3. **Verify device permissions:
    ```bash
    ls -l /dev/input/event*

    If your rule is working, the group should be input and permissions should be rw-rw----:
        crw-rw---- 1 root input 13, 64 Feb  4 14:05 /dev/input/event27
    ```

3. **Verify gamepad is in 'input' group:
    ```bash
    udevadm info --query=property --name=/dev/input/eventX | grep GROUP
   ```


3. **Add gamepad to 'input' group:
   ```
   ls -l /dev/input/event*
   crw-rw---- 1 root input 13, 64 Feb  4 14:05 /dev/input/event27

   sudo nvim /etc/udev/rules.d/99-gamepad.rules
      SUBSYSTEM=="input", ATTRS{id/vendor}=="2dc8", ATTRS{id/product}=="9021", GROUP="input", MODE="0660"
      SUBSYSTEM=="input", ATTRS{id/vendor}=="2dc8", ATTRS{id/product}=="9021", ENV{ID_INPUT_KEYBOARD}="1", ENV{ID_INPUT_JOYSTICK}="1"

   sudo udevadm control --reload-rules
   sudo udevadm trigger
   udevadm info --attribute-walk --name=/dev/input/eventX | grep GROUP
   GROUP=input
   ```

4. **Add Your User to the input Group
   ```
   groups $(whoami) | grep input
   
   sudo usermod -aG input $(whoami)
   sudo udevadm control --reload-rules
   sudo udevadm trigger
   reboot
   
   evtest /dev/input/eventX
   ```








## **Configuring MPV for IPC Communication**

MPV needs to expose an **IPC (Inter-Process Communication) server** to receive commands from the gamepad script. This is done via `mpv.conf`.

#### **1. Enable MPV's IPC Server**

Edit your MPV configuration file:
```bash
nvim ~/.config/mpv/mpv.conf
```

Add the following line:
```ini
input-ipc-server=/tmp/mpvsocket
```

This creates a **socket file** at `/tmp/mpvsocket`, allowing external scripts (like the gamepad integration) to send commands to MPV.

#### **2. Set Correct Permissions**

Ensure MPV's socket file has appropriate permissions:
```bash
ls -al /tmp/mpvsocket
srw------- - mlj 12 Feb 23:24 /tmp/mpvsocket
chmod 666 /tmp/mpvsocket
ls -al /tmp/mpvsocket
srw-rw-rw- - mlj 12 Feb 23:24 /tmp/mpvsocket
```

This allows all users and processes to send commands to MPV.

#### **3. Verify IPC Server is Running**

Start MPV with any video file:
```bash
mpv your_video_file.mkv
```

Then check if the socket exists:
```bash
ls -l /tmp/mpvsocket
```

You can manually send test commands using `socat`:
```bash
echo '{ "command": ["cycle", "pause"] }' | socat - /tmp/mpvsocket
```

If MPV pauses, the IPC server is working correctly.

## ~/.config/mpv/python-scripts/micro-gamepad.py

Instead of manually setting `DEVICE_PATH='/dev/input/eventX'`, dynamically locate the gamepad using its **Vendor ID** and **Product ID**:

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
