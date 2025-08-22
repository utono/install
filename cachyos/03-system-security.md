# CachyOS System Security Configuration

> **Note**: These configurations require root privileges. Login as root before proceeding.

```bash
xps17-2 login: root
Password:
```

## Configure System Emergency Controls

### Configure Sysrq Settings

**Reference**: [Arch Wiki: Keyboard Shortcuts](https://wiki.archlinux.org/title/Keyboard_shortcuts)

These settings allow emergency system control even when the system is unresponsive.

```bash
cd /etc/sysctl.d

# Copy the system configuration file
cp /home/mlj/utono/system-config/etc/sysctl.d/99-sysrq.conf /etc/sysctl.d/

# Apply the new sysctl settings
sysctl --system

# Verify the current Sysrq value (should be 1)
cat /proc/sys/kernel/sysrq
```

## Configure Touchpad Toggle Permissions

To allow touchpad toggle without password prompts:

```bash
# Copy sudoers rule for touchpad control
sudo cp ~/utono/system-config/etc/sudoers.d/touchpad-toggle /etc/sudoers.d
```

This enables `$HOME/utono/cachyos-hyprland-settings/etc/skel/.config/hypr/bin/toggle-touchpad.sh` to work without sudo prompts.

**File contents**:
```sudoers
mlj ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/bus/i2c/drivers/i2c_hid_acpi/unbind, /usr/bin/tee /sys/bus/i2c/drivers/i2c_hid_acpi/bind
```

> Replace `mlj` with your actual username if needed.

## Configure Laptop Lid Behavior

### Create Configuration Directory

```bash
mkdir -p /etc/systemd/logind.conf.d
cd /etc/systemd/logind.conf.d
```

### Copy Lid Behavior Configuration

```bash
cp /home/mlj/utono/system-config/etc/systemd/logind.conf.d/lid-behavior.conf /etc/systemd/logind.conf.d
```

### Apply Changes

```bash
systemctl restart systemd-logind
```

### Verify Configuration

```bash
# Check current session's idle action setting
loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') --property=IdleAction

# Check lid switch behavior
loginctl show-session | grep HandleLidSwitch
```

**Expected output**:
```plaintext
HandleLidSwitch=ignore
HandleLidSwitchDocked=ignore
```

This prevents the laptop from suspending when the lid is closed.
