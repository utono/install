# Configuring a Bluetooth Gamepad for Neovim-Controlled Chapter Creation in MPV

This guide describes **use case #2**: configuring a Bluetooth gamepad to send keystrokes to Neovim (not MPV directly). The current Neovim line becomes a chapter title for the video currently playing in MPV. MPV is controlled via its IPC socket, and the gamepad is treated as a Bluetooth keyboard.

---

## 🚀 Overview

* The gamepad is **not exclusively grabbed** by MPV.
* Gamepad input behaves like **keyboard input**.
* Neovim sends chapter titles to MPV using the current line.
* Some buttons may use the **Hyprland mod key** for system-level actions.

---

## 🔧 Requirements

Install required tools:

```bash
sudo pacman -S python-evdev socat
```

* `python-evdev`: for any low-level input work (optional if not grabbing devices).
* `socat`: to send commands to MPV via its IPC socket.

---

## 🧠 Using keyd Effectively

### Common Commands

```bash
sudo systemctl restart keyd     # Restart keyd service completely
keyd reload                     # Reload config without stopping keyd
sudo keyd monitor               # View key press activity (helpful for mapping)
journalctl -eu keyd             # View logs for keyd (errors, device issues)
```

### Multi-Key Bind Syntax Example

```ini
<backspace>+<escape>+<enter> = reload
```

This binds three keys in combination to reload the current keyd config. Use this in a `[main]` block for a special keyboard or conditionally via `[app]` sections.

### Providing Device Identifiers to keyd

To target a specific device (such as a gamepad), use its Vendor ID and Product ID in the `[ids]` section of a keyd config:

```ini
[ids]
-2dc8:9021
```

* The `-` prefix means "apply to this device only and exclude all others."
* You can get the vendor/product IDs using:

  ```bash
  sudo keyd monitor
  cat /proc/bus/input/devices
  udevadm info --attribute-walk --name=/dev/input/eventX | grep id
  ```

This ensures your remappings apply only to your gamepad and not your main keyboard.

### Setting a Fallback Default Mapping

If you want a fallback when your gamepad is not connected, use the wildcard fallback `[*]` in a separate config like:

```ini
[ids]
*

[main]
a = noop
b = noop
c = noop
```

This will disable or neutralize those keys when no targeted device is matched. It ensures that the remappings for your gamepad do not apply to other devices like your main keyboard.

### `noop` in keyd

The `noop` action tells keyd to ignore a key entirely. This is useful when you want to disable an unwanted key:

```ini
d = noop  # disables key "d"
```

### 🔁 Toggling Gamepad Modes (MPV ↔ System)

To toggle between MPV-specific and system-wide control schemes, you can use a key as a layer switch or define conditional mappings. For example:

```ini
[main]
select = toggle(meta_layer)

[layer meta_layer]
a = meta+a
s = meta+s
j = meta+j
k = meta+k
```

You could also bind a layer switch with a held modifier:

```ini
a = hold(meta, a)
```

This allows you to use the same button for both MPV and Hyprland depending on what modifier is active.

Alternatively, define separate keyd config files for different modes and switch between them using:

```bash
ln -sf ~/.config/keyd/gamepad-mpv.conf /etc/keyd/my_gamepad.conf
sudo systemctl restart keyd
```

### 🔀 Toggle Script to Switch Configs

Save this as `~/.local/bin/toggle-gamepad-mode.sh`:

```bash
#!/usr/bin/env bash

set -e

KEYD_CONFIG_DIR=/etc/keyd
MPV_CONF=gamepad-mpv.conf
SYS_CONF=gamepad-system.conf
LINK=$KEYD_CONFIG_DIR/my_gamepad.conf

if readlink "$LINK" | grep -q "$MPV_CONF"; then
  echo "Switching to system mode..."
  ln -sf "$KEYD_CONFIG_DIR/$SYS_CONF" "$LINK"
else
  echo "Switching to MPV mode..."
  ln -sf "$KEYD_CONFIG_DIR/$MPV_CONF" "$LINK"
fi

sudo systemctl restart keyd
```

Make it executable:

```bash
chmod +x ~/.local/bin/toggle-gamepad-mode.sh
```

Run it with:

```bash
toggle-gamepad-mode.sh
```

---

## 🧾 Understanding `~/.config/keyd/app.conf`

This file defines key remappings **only when specific applications are focused**.

```ini
[*]

[mpv]
a = a
s = s
d = d
f = f
j = j
k = k
l = l
; = ;
```

### Breakdown:

* `[ * ]` is the global default mapping.
* `[mpv]` only applies when the focused window belongs to MPV.
* This config ensures that keys sent by the gamepad are passed through unchanged while MPV is focused.

You can override or disable keys contextually per app here. For example:

```ini
[firefox]
space = noop
```

Would disable the spacebar only in Firefox.

---

## 🔄 Hyprland Key Integration (Examples)

Here’s how you might map gamepad keys to interact with Hyprland:

| Key (via keyd) | Hyprland Binding                         | Description           |
| -------------- | ---------------------------------------- | --------------------- |
| META+H         | `bind = $mainMod, H, movefocus, l`       | Move focus right      |
| META+J         | `bind = $mainMod, J, movefocus, d`       | Move focus down       |
| META+K         | `bind = $mainMod, K, movefocus, u`       | Move focus up         |
| META+L         | `bind = $mainMod, L, movefocus, r`       | Move focus left       |
| META+Q         | `bind = $mainMod, Q, killactive`         | Close current window  |
| META+SPACE     | `bind = $mainMod, SPACE, togglefloating` | Toggle floating state |

These assume your gamepad is sending keys like `j`, `k`, `h`, etc., with the Meta key held using `lettermod`. Adjust to match your actual Hyprland binds.

---

## ✅ Summary

* MPV runs with IPC socket enabled
* Neovim is used to send chapters via current line
* Gamepad is paired as a Bluetooth keyboard
* No exclusive access; system/hyprland/neovim all see the input
* `keyd` is used to remap and contextualize input per app or system

This setup allows seamless chapter creation in MPV using gamepad-triggered Neovim actions, with optional Hyprland and context-aware integration.
