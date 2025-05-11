# 8bitdo.com Micro-Bluetooth-gamepad
https://download.8bitdo.com/Manual/Controller/Micro/Micro-Bluetooth-gamepad-8.pdf

# Fixing 8BitDo Micro Gamepad Connection Issues with bluetuith

When using **bluetuith** to connect an 8BitDo Micro gamepad, you may encounter the status:

```
(Connected[-4], Paired)
```

This indicates that the gamepad connects briefly but fails due to a protocol negotiation error. This guide explains the cause and steps to fix it.

---

## 🚨 What Does `Connected[-4]` Mean?

This is a generic **HID (Human Interface Device) protocol failure**, which typically occurs when:

* The device is trying to connect in an unsupported or misrecognized mode
* The system cannot negotiate the expected Bluetooth profile (e.g., keyboard vs. joystick)
* The kernel driver or BlueZ stack fails to complete initialization

---

## ✅ Steps to Fix It

### 1. Remove All 8BitDo Entries

Multiple pairings may conflict.

```bash
bluetoothctl
remove XX:XX:XX:XX:XX:XX  # Use both MAC addresses shown in bluetuith
```

Alternatively, use `bluetuith` and select both entries, then disconnect and remove them.

---

### 2. Factory Reset the Gamepad

Perform a hard reset:

* Hold **Start + Select** for 8–10 seconds
* The LED should flash rapidly or turn off

This clears internal pairing data.

---

### 3. Reboot in the Correct Mode

Power on the 8BitDo Micro in the mode your script expects:

| Mode   | Button Combo | Description                          |
| ------ | ------------ | ------------------------------------ |
| XInput | `Start + X`  | Gamepad mode (often HID)             |
| DInput | `Start + B`  | Legacy DirectInput                   |
| Mac/KB | `Start + P`  | Keyboard mode (for `KEY_*` mappings) |

For `evdev.KEY_*` mappings in your Python script, use **Keyboard mode** or DInput depending on the OS response.

---

### 4. Reconnect with bluetuith or bluetoothctl

```bash
bluetoothctl
scan on
pair XX:XX:XX:XX:XX:XX
trust XX:XX:XX:XX:XX:XX
connect XX:XX:XX:XX:XX:XX
```

Confirm connection:

```bash
info XX:XX:XX:XX:XX:XX
```

Look for:

```
Connected: yes
Trusted: yes
Paired: yes
```

---

### 5. Verify Event Device with evtest

```bash
ls /dev/input/event*
evtest /dev/input/eventX
```

Press buttons on the gamepad. You should see lines like:

```
Event: time ..., type 1 (EV_KEY), code 35 (KEY_H), value 1
```

This confirms the device is now working as a keyboard.

---

## 🛠 Optional: Add Udev Rule

To ensure the correct group and permissions:

```bash
sudo nano /etc/udev/rules.d/99-gamepad.rules
```

```udev
SUBSYSTEM=="input", ATTRS{id/vendor}=="2dc8", ATTRS{id/product}=="9021", GROUP="input", MODE="0660"
```

Then reload:

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

---

## ✅ Result

You should now see only **one** entry for the 8BitDo gamepad in `bluetuith`, marked as:

```
(Connected, Paired)
```

And button presses will show up in `evtest`. Your Python script can now read and act on key events reliably.
