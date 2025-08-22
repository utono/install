# GRUB and SDDM Configuration

## Configure GRUB Resolution

### 1. Check Supported Resolutions

Before setting the resolution, verify what your system supports:

1. Reboot and enter the **GRUB command line** by pressing `c` at the GRUB menu.
2. At the GRUB command line, run:
   ```bash
   videoinfo
   ```
3. Look for your desired resolution (e.g., **1920x1440**) in the output.

### 2. Set GRUB Resolution

Edit the GRUB configuration file:

```bash
sudo vim /etc/default/grub
```

Find or add the following lines:

```plaintext
GRUB_GFXMODE=1920x1440
GRUB_GFXPAYLOAD_LINUX=keep
```

**Alternative resolutions** (if 1920x1440 doesn't work):
```plaintext
GRUB_GFXMODE=3840x2400
GRUB_GFXMODE=1600x1200
GRUB_GFXMODE=1280x1024
GRUB_GFXMODE=1024x768
GRUB_GFXMODE=800x600
GRUB_GFXMODE=600x400
```

### 3. Apply Changes

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### 4. Reboot

```bash
reboot
```

## Configure SDDM

### Configure SDDM Xsetup Script

```bash
cd /usr/share/sddm/scripts/
cat Xsetup  # View current Xsetup script
cp Xsetup Xsetup.bak  # Backup existing Xsetup

# Copy the custom Xsetup script
cp -i /home/mlj/utono/system-config/usr/share/sddm/scripts/Xsetup /usr/share/sddm/scripts/

cat Xsetup  # Verify new Xsetup script
```

**Updated `Xsetup` content**:
```bash
#!/bin/sh

# Set display resolution and refresh rate
xrandr --output eDP-1 --mode 1920x1200 --rate 59.98

# Set keyboard layout environment variable
export XKB_DEFAULT_LAYOUT=real_prog_dvorak

# Apply keyboard layout settings
setxkbmap -layout real_prog_dvorak -v
```

### Configure SDDM Autologin (Optional)

View existing SDDM configuration:

```bash
cat /etc/sddm.conf
```

Ensure autologin settings directory exists:

```bash
sudo mkdir -p /etc/sddm.conf.d
```

Create autologin configuration:

```bash
echo -e "[Autologin]\nUser=mlj\nSession=hyprland" | sudo tee /etc/sddm.conf.d/autologin.conf
```

### Disable SDDM (Optional)

To disable and prevent SDDM from starting:

```bash
sudo systemctl disable sddm  
sudo systemctl mask sddm  
```

### Apply SDDM Changes

```bash
sudo systemctl restart sddm  
reboot  
```
