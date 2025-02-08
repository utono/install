# Configuring Gamepad Input for MPV Using Evdev

---

## Step 1: Install Required Tools

sudo pacman -S python-evdev socat

## Step 2: Enable MPV's IPC Server

nvim ~/.config/mpv/mpv.conf

   input-ipc-server=/tmp/mpvsocket

chmod 666 /tmp/mpvsocket

## Step 4: Grant Permissions to Access the Gamepad Device

bluetuith - pair gamepad
sudo keyd monitor
   device added: 2dc8:9021:27abd54c 8BitDo Micro gamepad Keyboard (/dev/input/event19)

bluetuith - pair gamepad
reboot
sudo keyd monitor
   device added: 2dc8:9021:27abd54c 8BitDo Micro gamepad Keyboard (/dev/input/event19)

bluetuith - pair gamepad
reboot
sudo keyd monitor
   device added: 2dc8:9021:27abd54c 8BitDo Micro gamepad Keyboard (/dev/input/event19)

cat /proc/bus/input/devices

   Handlers=event13

nvim ~/.config/mpv/scripts/micro-to-mpv-19.py:

   DEVICE_PATH='/dev/input/eventX'

udevadm info --query=property --name=/dev/input/event19 | grep GROUP
   
   If the output includes `GROUP=input`, then the device belongs to the `input` group.

3. **Add the Device to the `input` Group**
   
   If the device is not in the `input` group, create a custom `udev` rule:
   
   ```bash
   cp ~/utono/system-config/etc/udev/rules.d/99-gamepad.rules /etc/udev/rules.d/
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

   sudo usermod -aG input $(whoami)

5. **Log Out and Back In**

   Group changes take effect after re-logging.

6. **Verify Group Membership**

   ```bash
   groups
   ```

7. **Test Access**

   ```bash
   /usr/bin/python3 ~/.config/mpv/scripts/micro-to-mpv-19.py
   ```

---

## Step 6: Automate the Script with systemd

mkdir -p ~/.config/systemd/user
cp ~/tty-dotfiles/systemd/.config/systemd/user/gamepad_to_mpv.service ~/.config/systemd/user/gamepad_to_mpv.service
# ln -s ~/tty-dotfiles/systemd/.config/systemd/user/gamepad_to_mpv.service ~/.config/systemd/user/gamepad_to_mpv.service
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
