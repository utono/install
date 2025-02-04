# Configuring Gamepad Input for MPV Using Evdev

This guide helps set up a gamepad (acting as a keyboard) to control MPV on Arch Linux and Ubuntu using `evdev`.

---

## Step 1: Install Required Tools

Ensure the following tools are installed:

### Arch Linux
```bash
sudo pacman -S python-evdev socat
```

### Ubuntu
```bash
sudo apt update && sudo apt install python3-evdev socat
```

- `python-evdev`: For reading input events from devices.
- `socat`: For sending JSON commands to MPV's IPC socket.

---

## Step 2: Enable MPV's IPC Server

Edit the MPV configuration file:

```bash
nvim ~/.config/mpv/mpv.conf
```

Add the following line:

```ini
input-ipc-server=/tmp/mpvsocket
```

Save and close the file.

---

## Step 3: Identify the Gamepad Device

Use the following commands to identify your gamepad's device:

```bash
ls /dev/input/
evtest /dev/input/<your-device>
```

Replace `<your-device>` with the correct device name (e.g., `event19`).

On Ubuntu, you may need to install `evtest` first:

```bash
sudo apt install evtest
```

---

## Step 4: Grant Permissions to Access the Gamepad Device

If you encounter "Permission denied" errors for the gamepad device (e.g., `/dev/input/event19`):

1. **Check Device Permissions**
   
   ```bash
   ls -l /dev/input/event19
   ```
   Confirm the device is in the `input` group.

2. **Add User to the Input Group**

   ```bash
   sudo usermod -aG input $(whoami)
   ```

3. **Log Out and Back In**

   Group changes take effect after re-logging.

4. **Verify Group Membership**

   ```bash
   groups
   ```

5. **Test Access**

   ```bash
   /usr/bin/python3 ~/.config/mpv/scripts/gamepad_to_mpv.py
   ```

---

## Step 5: Create and Configure the Python Script

Create a Python script to map gamepad inputs to MPV functions:

```bash
nvim ~/.config/mpv/scripts/gamepad_to_mpv.py
```

Paste the script from the original documentation here. Ensure `DEVICE_PATH` matches your device (e.g., `/dev/input/event19`).

Make the script executable:

```bash
chmod +x ~/.config/mpv/scripts/gamepad_to_mpv.py
```

---

## Step 6: Automate the Script with systemd

Create a systemd service file:

```bash
nvim ~/.config/systemd/user/gamepad_to_mpv.service
```

Add the following content:

```ini
[Unit]
Description=Gamepad Input to MPV
After=mpv.service

[Service]
ExecStart=/usr/bin/python3 /home/mlj/.config/mpv/scripts/gamepad_to_mpv.py
Restart=always

[Install]
WantedBy=default.target
```

### What `gamepad_to_mpv.service` Does

The `gamepad_to_mpv.service` systemd service automatically starts and runs the Python script that listens for gamepad input events. When a button is pressed on the gamepad, the script translates it into a corresponding command for MPV using its IPC server. This service ensures the gamepad remains functional as a remote controller for MPV, even after system reboots or MPV restarts.

### How the Python Script Listens for Input

The script's ability to listen for input events is facilitated by the `evdev` library, which:

1. Uses `InputDevice.read_loop()` to continuously read input events from the gamepad.
2. Utilizes `evdev.ecodes` and `categorize(event)` to interpret raw input events as key presses.
3. Implements a `try-except` structure to keep the script running even if the device disconnects.
4. Calls `os.path.exists(DEVICE_PATH)` to wait for the device to reconnect if it's temporarily unavailable.

Enable and start the service:

```bash
systemctl --user enable --now gamepad_to_mpv.service
```

### Difference Between `daemon-reexec` and `daemon-reload`

- `daemon-reload`: Reloads systemd manager configuration files without restarting running services.
- `daemon-reexec`: Restarts the systemd user instance entirely, which can be useful if systemd binaries have been updated or if systemd is behaving unexpectedly.

Neither command is exclusive to Ubuntu; both work on any system that uses `systemd`, including Arch Linux.

If you experience issues with user services, try running:

```bash
systemctl --user daemon-reexec
```

This ensures that systemd is fully restarted and picks up any changes.

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
