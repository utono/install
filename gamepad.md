# Configuring Gamepad Input for MPV Using Evdev

---

## Step 1: Install Required Tools

```bash
sudo pacman -S python-evdev socat
```

---

## Step 2: Enable MPV's IPC Server

```bash
nvim ~/.config/mpv/mpv.conf
```

Add the following line:

```ini
input-ipc-server=/tmp/mpvsocket
```

---

## Step 3: Identify the Gamepad Device

### **Use `keyd monitor` to Identify the Device**

   ```bash
   sudo keyd monitor
   ```
Update ~/.config/mpv/scripts/gamepad_to_mpv.py:

```bash
DEVICE_PATH='/dev/input/eventX'
```

### **Find the Gamepad Name**

To correctly configure `udev` rules, find the exact name of your gamepad:

```bash
udevadm info --query=property --name=/dev/input/eventX | grep DEVNAME
```

Replace `eventX` with your actual gamepad event number (e.g., `event19`).
The output will look like this:

```bash
DEVNAME="/dev/input/event19"
```

Use the `DEVNAME` value in the `udev` rule in the next step.

---

## Step 4: Grant Permissions to Access the Gamepad Device

If you encounter "Permission denied" errors for the gamepad device (e.g., `/dev/input/event19`):

1. **Check Device Permissions**
   
   ```bash
   ls -l /dev/input/event19
   ```
   
   Confirm the device is in the `input` group.

2. **Confirm the Device is in the `input` Group**
   
   ```bash
   udevadm info --query=property --name=/dev/input/event19 | grep GROUP
   ```
   
   If the output includes `GROUP=input`, then the device belongs to the `input` group.

3. **Add the Device to the `input` Group**
   
   If the device is not in the `input` group, create a custom `udev` rule:
   
   ```bash
   sudo nvim /etc/udev/rules.d/99-gamepad.rules
   ```
   
   Add the following line, replacing `Your Device Path` with the `DEVNAME` value found earlier:
   
   ```ini
   KERNEL=="event*", ATTRS{DEVNAME}=="/dev/input/event19", GROUP="input", MODE="0660"
   ```
   
   Save and exit, then reload `udev` rules:
   
   ```bash
   sudo udevadm control --reload-rules
   sudo udevadm trigger
   ```

4. **Add User to the Input Group**

   ```bash
   sudo usermod -aG input $(whoami)
   ```

5. **Log Out and Back In**

   Group changes take effect after re-logging.

6. **Verify Group Membership**

   ```bash
   groups
   ```

7. **Test Access**

   ```bash
   /usr/bin/python3 ~/.config/mpv/scripts/gamepad_to_mpv.py
   ```

---

## Step 6: Automate the Script with systemd

The systemd service file is located at `~/tty-dotfiles/systemd/.config/systemd/user/gamepad_to_mpv.service`. Create a symlink to it in `~/.config/systemd/user` to ensure it is recognized by systemd:

```bash
mkdir -p ~/.config/systemd/user
ln -s ~/tty-dotfiles/systemd/.config/systemd/user/gamepad_to_mpv.service ~/.config/systemd/user/gamepad_to_mpv.service
```

Enable and start the service:

```bash
systemctl --user enable --now gamepad_to_mpv.service
```

On Ubuntu, ensure that `systemd` user services are enabled:

```bash
systemctl --user daemon-reexec
```

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
