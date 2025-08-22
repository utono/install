# Disabling Browser Swipe Navigation

This guide provides steps to disable left/right swipe gestures in popular Linux web browsers, particularly for users on Wayland-based compositors like **Hyprland**.

---

## Firefox

### Disable Horizontal Swipe Navigation

1. Open a new tab and go to `about:config`.
2. Search for the following preferences:

   * `browser.gesture.swipe.left`
   * `browser.gesture.swipe.right`
3. For each one:

   * Click the **pencil icon** to edit.
   * Clear the value (set it to an **empty string**).
   * Press **Enter** to apply.

This prevents horizontal swipe gestures (e.g., three-finger or edge swipe) from navigating forward/back in history.

---

## Chromium / Chrome / Brave

Swipe gestures are enabled by default for touchpads in Chromium-based browsers.

### Option 1: Use Startup Flag

You can disable swipe navigation using the `--disable-features` flag.

```bash
chromium --disable-features=TouchpadOverscrollHistoryNavigation
```

Replace `chromium` with `google-chrome`, `brave`, or another browser binary as needed.

### Option 2: Create a .desktop File Override

1. Copy the existing .desktop launcher:

```bash
cp /usr/share/applications/chromium.desktop ~/.local/share/applications/
```

2. Edit the copied file:

```bash
nvim ~/.local/share/applications/chromium.desktop
```

3. Modify the `Exec=` line:

```ini
Exec=chromium --disable-features=TouchpadOverscrollHistoryNavigation %U
```

4. Save and make sure your launcher uses the updated `.desktop` entry.

---

## Notes

* These changes do **not** affect vertical scrolling or pinch-to-zoom.
* Some touchpad gestures may be managed by gesture daemons (e.g. `touchegg`, `libinput-gestures`, or `ydotool`) — disabling them system-wide may require additional steps.

---

## Hyprland Users

If you're using Hyprland and want to disable workspace swipe gestures:

Add this to your `hyprland.conf`:

```ini
input {
    gestures {
        workspace_swipe = false
    }
}
```

Then reload Hyprland:

```bash
hyprctl reload
```
