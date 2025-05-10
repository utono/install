# Configuring a Bluetooth Gamepad for Neovim-Controlled Chapter Creation in MPV

This guide describes **use case #2**: configuring a Bluetooth gamepad to send keystrokes to Neovim (not MPV directly). The current Neovim line becomes a chapter title for the video currently playing in MPV. MPV is controlled via its IPC socket, and the gamepad is treated as a Bluetooth keyboard.

---

## 🚀 Overview

* The gamepad is **not exclusively grabbed** by MPV.
* Gamepad input behaves like **keyboard input**.
* Neovim sends chapter titles to MPV using the current line.
* Some buttons may use the **Hyprland mod key** for system-level actions.
* Gamepad buttons can be assigned to **Neovim commands** in either **normal or visual mode**, and other buttons can be mapped to **Hyprland system controls**.

---

## 🎮 Assign Buttons to Neovim and Hyprland Separately

### Step 1: Define Key Roles in keyd

In your keyd config (e.g. `/etc/keyd/gamepad.conf`), you can assign:

* buttons like `a`, `s`, `d`, `f` to Neovim
* buttons like `j`, `k`, `l`, `;` with modifiers (e.g. `meta`) to Hyprland

```ini
[main]
a = a
s = s
d = d
f = f
j = lettermod(meta, j, 100, 200)
k = lettermod(meta, k, 100, 200)
l = lettermod(meta, l, 100, 200)
; = lettermod(meta, semicolon, 100, 200)
```

### Step 2: In Neovim

Map the direct keys to commands in normal or visual mode:

```lua
vim.keymap.set("n", "a", function() ... end, { desc = "Do something" })
vim.keymap.set("v", "d", function() ... end, { desc = "Do something in visual" })
```

These will be triggered only when Neovim is focused and in the right mode.

### Step 3: In Hyprland

Map the Meta-modified gamepad keys to global window actions:

```ini
bind = $mainMod, J, movefocus, d
bind = $mainMod, K, movefocus, u
bind = $mainMod, L, movefocus, r
bind = $mainMod, semicolon, killactive
```

This ensures only those keys prefixed with Meta (triggered via keyd) interact with the window manager.

### Optional: Add app-specific filtering in `~/.config/keyd/app.conf`

To prevent keys like `a`, `s`, `d` from doing anything when outside Neovim:

```ini
[*]
a = noop
s = noop
d = noop
f = noop

[nvim]
a = a
s = s
d = d
f = f
```

---

*(Remaining content unchanged)*
