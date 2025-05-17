## 🔧 Connecting Bluetooth Devices Using `bluetoothctl`

### 📘 Common `bluetoothctl` Commands

Run this first:

```bash

sudo bluetoothctl

[8BitDo Micro gamepad]> devices
[8BitDo Micro gamepad]> connect 80:4A:F2:C1:92:D2
Attempting to connect to 80:4A:F2:C1:92:D2
hci0 80:4A:F2:C1:92:D2 type BR/EDR connected eir_len 31

[8BitDo Micro gamepad]> devices Paired

```

| Command                     | Description                                     |                               |
| --------------------------- | ----------------------------------------------- | ----------------------------- |
| `power on`                  | Turns on the Bluetooth controller               |                               |
| `agent on`                  | Enables the agent for pairing                   |                               |
| `default-agent`             | Sets the current agent as default               |                               |
| `pairable on`               | Makes the device pairable                       |                               |
| `discoverable on`           | Makes the device discoverable                   |                               |
| `scan on` / `scan off`      | Starts or stops device scanning                 |                               |
| `pair 80:4A:F2:C1:92:D2`    | Pairs with the Sonos speaker                    |                               |
| `trust 80:4A:F2:C1:92:D2`   | Marks the Sonos speaker as trusted              |                               |
| `connect 80:4A:F2:C1:92:D2` | Connects to the Sonos speaker                   |                               |
| `info 80:4A:F2:C1:92:D2`    | Shows details about the Sonos speaker           |                               |
| `remove 80:4A:F2:C1:92:D2`  | Removes the Sonos speaker                       |                               |
| `pair E4:17:D8:91:A0:98`    | Pairs with the 8BitDo gamepad                   |                               |
| `trust E4:17:D8:91:A0:98`   | Marks the 8BitDo gamepad as trusted             |                               |
| `connect E4:17:D8:91:A0:98` | Connects to the 8BitDo gamepad                  |                               |
| `info E4:17:D8:91:A0:98`    | Shows details about the 8BitDo gamepad          |                               |
| `remove E4:17:D8:91:A0:98`  | Removes the 8BitDo gamepad                      |                               |
| `devices Paired`            | Lists all paired devices                        |                               |
| `devices`                   | Lists all known devices (paired or seen before) |                               |
| `quit`                      | Exits the bluetoothctl prompt                   | Exits the bluetoothctl prompt |

This guide explains how to connect and trust two Bluetooth devices — a **Sonos speaker** and an **8BitDo Micro gamepad** — using `bluetoothctl` on Arch Linux. The instructions include all relevant diagnostic and configuration commands.

---

### 📦 Preliminaries

Ensure all relevant packages are installed:

```bash
sudo pacman -Syu bluez bluez-utils linux-firmware
```

If you're experiencing firmware issues (e.g., no Bluetooth adapter detected), reinstall the firmware:

```bash
sudo pacman -S linux-firmware --noconfirm
sudo reboot
```

---

### 🧪 Diagnostic and Preparation Commands

Check the Bluetooth service:

```bash
systemctl status bluetooth.service
sudo systemctl restart bluetooth
sudo systemctl enable --now bluetooth.service
```

Look for conflicting software:

```bash
ps aux | grep -i blueman
ps aux | grep -i bluetuith
killall blueman-manager
killall bluetuith
paru -Rns blueman bluetuith-bin
```

Verify the adapter is recognized:

```bash
lsusb | grep -i bluetooth
rfkill list
sudo rfkill unblock bluetooth
```

Start `bluetoothctl` and power on:

```bash
bluetoothctl
[bluetooth]# power on
```

Check kernel modules:

```bash
lsmod | grep -i bluetooth
lsmod | grep btusb
sudo modprobe btusb
```

Check BlueZ version:

```bash
bluetoothd -v
```

Check logs:

```bash
journalctl -xe | grep -i bluetooth
sudo journalctl -f | grep -i bluetooth
sudo dmesg | grep -i bluetooth
dmesg | grep -i bluetooth
```

Disable other Bluetooth managers if needed:

```bash
sudo systemctl stop blueman-mechanism
sudo pacman -Rns blueman
```

Run the Bluetooth daemon in debug mode (optional):

```bash
sudo bluetoothd -d -n
```

Additional diagnostics:

```bash
bluetoothctl list
bluetoothctl show
rfkill list bluetooth
lsusb | grep -i bluetooth
```

---

### 🔌 Unblock and Start Bluetooth

```bash
sudo rfkill unblock bluetooth
sudo systemctl enable --now bluetooth.service
```

If needed, restart the service manually:

```bash
sudo systemctl restart bluetooth
```

---

### 🔍 Connect Devices with `bluetoothctl`

1. **Launch ********************`bluetoothctl`********************:**

   ```bash
   bluetoothctl
   ```

2. **Enable the controller and agent:**

   ```bash
   [bluetooth]# power on
   [bluetooth]# agent on
   [bluetooth]# default-agent
   [bluetooth]# pairable on
   [bluetooth]# discoverable on
   ```

3. **Scan for devices:**

   ```bash
   [bluetooth]# scan on
   ```

   Look for your devices in the output:

   ```
   [NEW] Device 80:4A:F2:C1:92:D2 Living Room (SONOS 92D2)
   [NEW] Device E4:17:D8:91:A0:98 8BitDo Micro gamepad
   ```

   Stop scanning once you see both:

   ```bash
   [bluetooth]# scan off
   ```

4. **Pair and trust each device:**

   ```bash
   [bluetooth]# pair 80:4A:F2:C1:92:D2
   [bluetooth]# trust 80:4A:F2:C1:92:D2
   [bluetooth]# connect 80:4A:F2:C1:92:D2

   [bluetooth]# pair E4:17:D8:91:A0:98
   [bluetooth]# trust E4:17:D8:91:A0:98
   [bluetooth]# connect E4:17:D8:91:A0:98
   ```

5. **Confirm connection status:**

   ```bash
   [bluetooth]# info 80:4A:F2:C1:92:D2
   [bluetooth]# info E4:17:D8:91:A0:98
   ```

   Look for:

   ```
   Connected: yes
   Trusted: yes
   Paired: yes
   ```

6. **List all paired devices:**

   ```bash
   [bluetooth]# devices Paired
   ```

7. **Remove a device (if needed):**

   ```bash
   [bluetooth]# remove 80:4A:F2:C1:92:D2
   [bluetooth]# remove E4:17:D8:91:A0:98
   ```

8. **Exit ********************`bluetoothctl`********************:**

   ```bash
   [bluetooth]# quit
   ```

---

### 🛠️ Reconnect Troubleshooting

If a device fails to reconnect after reboot or suspend:

* Ensure the device is **powered on and in range**

* Run `bluetoothctl` and use:

  ```bash
  power on
  connect 80:4A:F2:C1:92:D2
  info 80:4A:F2:C1:92:D2

  connect E4:17:D8:91:A0:98
  info E4:17:D8:91:A0:98
  ```

* Use `devices Paired` to confirm it's still trusted

* Restart the Bluetooth service:

  ```bash
  sudo systemctl restart bluetooth
  ```

* Check logs:

  ```bash
  journalctl -xe | grep -i bluetooth
  ```

---

### ✅ Devices Successfully Connected

```bash
$ bluetoothctl devices Paired
Device 80:4A:F2:C1:92:D2 Living Room (SONOS 92D2)
Device E4:17:D8:91:A0:98 8BitDo Micro gamepad
```

You're all set.
