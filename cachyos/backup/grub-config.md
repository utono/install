# GRUB Resolution Configuration Guide

This guide walks you through configuring GRUB to use a specific screen resolution, improving the visual experience during boot.

---

## Overview

GRUB's default resolution may not match your display's optimal settings. This configuration allows you to set a custom resolution that works best for your hardware.

---

## Step 1: Check Supported Resolutions

Before configuring a specific resolution, verify what your system supports:

### 1.1 Access GRUB Command Line

1. **Reboot your system**
2. **At the GRUB boot menu**, press `c` to open the GRUB command line
3. **Run the following command:**

```bash
videoinfo
```

### 1.2 Review Available Resolutions

Look through the output for supported resolutions. Common resolutions include:
- `800x600`
- `1024x768` 
- `1280x1024`
- `1600x1200`
- `1920x1080`
- `1920x1200`
- `1920x1440`

**Note:** Only use resolutions that appear in the `videoinfo` output.

---

## Step 2: Configure GRUB Resolution

### 2.1 Edit GRUB Configuration

Open the GRUB configuration file:

```bash
sudo vim /etc/default/grub
```

### 2.2 Set Graphics Mode

Find the `GRUB_GFXMODE` line or add it if it doesn't exist. You can specify multiple resolutions as fallbacks:

```bash
# Primary resolution (adjust to your preferred resolution)
GRUB_GFXMODE=1920x1440

# Alternative: Multiple resolutions as fallbacks
# GRUB_GFXMODE=1920x1440,1920x1200,1600x1200,1280x1024,1024x768,800x600

# Keep the same resolution for the Linux kernel
GRUB_GFXPAYLOAD_LINUX=keep
```

### 2.3 Common Resolution Options

Choose the resolution that best fits your display:

| Resolution | Aspect Ratio | Common Use Case |
|------------|--------------|-----------------|
| `800x600` | 4:3 | Older displays, safe fallback |
| `1024x768` | 4:3 | Standard older monitors |
| `1280x1024` | 5:4 | Classic LCD monitors |
| `1600x1200` | 4:3 | High-res 4:3 displays |
| `1920x1080` | 16:9 | Full HD widescreen |
| `1920x1200` | 16:10 | Widescreen with extra height |
| `1920x1440` | 4:3 | High-res 4:3 displays |

---

## Step 3: Apply Configuration Changes

### 3.1 Regenerate GRUB Configuration

After editing `/etc/default/grub`, regenerate the GRUB configuration:

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### 3.2 Verify Configuration

Check that your changes were applied:

```bash
grep GRUB_GFXMODE /etc/default/grub
```

---

## Step 4: Test the Configuration

### 4.1 Reboot System

Restart your system to apply the changes:

```bash
reboot
```

### 4.2 Verify Resolution

After reboot, the GRUB menu should display in your specified resolution. The text and menu items should appear clearer and properly sized.

---

## Troubleshooting

### Resolution Not Working

If your specified resolution doesn't work:

1. **Boot into GRUB command line** (press `c` at boot menu)
2. **Re-run `videoinfo`** to double-check supported resolutions
3. **Try a different resolution** from the supported list
4. **Use multiple fallback resolutions:**

```bash
GRUB_GFXMODE=1920x1440,1600x1200,1280x1024,1024x768
```

### System Won't Boot

If GRUB configuration causes boot issues:

1. **Boot from a live USB/CD**
2. **Mount your root partition**
3. **Chroot into your system**
4. **Reset GRUB configuration:**

```bash
# Remove custom resolution
sudo sed -i 's/GRUB_GFXMODE=.*/# GRUB_GFXMODE=auto/' /etc/default/grub

# Regenerate config
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### Display Issues

If you experience display problems:

- **Try `GRUB_GFXPAYLOAD_LINUX=text`** instead of `keep`
- **Use a more conservative resolution** like `1024x768`
- **Check if your graphics card supports the resolution**

---

## Additional Configuration Options

### Font Size Adjustment

For better readability, you can also configure GRUB font size:

```bash
# In /etc/default/grub
GRUB_FONT=/usr/share/grub/unicode.pf2
```

### Background Image

Set a custom background image:

```bash
# In /etc/default/grub  
GRUB_BACKGROUND="/path/to/your/background.png"
```

---

## Summary

1. **Check supported resolutions** with `videoinfo` in GRUB command line
2. **Edit `/etc/default/grub`** to set `GRUB_GFXMODE` and `GRUB_GFXPAYLOAD_LINUX`
3. **Regenerate GRUB config** with `grub-mkconfig`
4. **Reboot and verify** the new resolution works

This configuration improves the visual quality of your boot process and makes GRUB menus more readable on modern displays.
