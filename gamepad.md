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

To identify your gamepad device, follow these steps:

### **List Input Devices**
```bash
ls /dev/input/
```
Look for entries like `eventX` (e.g., `event19`) that correspond to input devices.

### **Use `evtest` to Identify the Gamepad**

1. Install `evtest` (if not already installed):
   - **Arch Linux:**  
     ```bash
     sudo pacman -S evtest
     ```
   - **Ubuntu:**  
     ```bash
     sudo apt install evtest
     ```

2. Run `evtest` to list available devices:
   ```bash
   sudo evtest
   ```
   You will see a list of devices like:
   ```
   Available devices:
   /dev/input/event3:  "AT Translated Set 2 keyboard"
   /dev/input/event5:  "Logitech Gamepad F310"
   /dev/input/event19: "Wireless Controller"
   ```
   Identify the device corresponding to your gamepad.

3. Test the device:
   ```bash
   sudo evtest /dev/input/eventX
   ```
   Replace `eventX` with the correct event number for your gamepad. Press buttons on your gamepad to check if input events appear.

### **Use `keyd monitor` to Identify the Device**

If you are using `keyd`, you can monitor input events with:
   ```bash
   sudo keyd monitor
   ```
   This will display keypresses from all input devices, helping you confirm if your gamepad is being detected.

### **Alternative: Use `cat` to Check Input**

1. Run the following command:
   ```bash
   sudo cat /dev/input/eventX
   ```
   (Replace `eventX` with the correct device number.)

2. Press buttons or move sticks on the gamepad to see raw output.

### **Use `dmesg` to Find Device Name**
After plugging in your gamepad, run:
```bash
dmesg | grep -i input
```
This will list new input devices and their associated event numbers.

### **Use `udevadm` to Get More Info**
```bash
udevadm info --query=all --name=/dev/input/eventX
```
Replace `eventX` with the identified event number to get more details about the device.

Once you find the correct `eventX` for your gamepad, update your configuration to use it:
```bash
DEVICE_PATH='/dev/input/eventX'
```
Replace `eventX` with the correct device number (e.g., `/dev/input/event19`).

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
