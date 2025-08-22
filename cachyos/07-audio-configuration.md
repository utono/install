# Audio Configuration for CachyOS

Configure PipeWire audio system and troubleshoot common audio issues, particularly for Dell XPS 17 systems with Intel audio hardware.

## Overview

CachyOS uses PipeWire as the modern audio server, replacing PulseAudio and ALSA directly. This guide covers:
- Initial PipeWire setup
- SOF (Sound Open Firmware) configuration for Intel audio
- Troubleshooting audio issues
- Dell XPS 17 specific configurations

## Initial PipeWire Setup

### Install Audio Packages
```bash
# Core PipeWire packages
sudo pacman -S pipewire pipewire-pulse pipewire-alsa pipewire-jack

# Additional utilities
sudo pacman -S wireplumber pavucontrol alsa-utils

# GStreamer integration
sudo pacman -S gst-plugin-pipewire
```

### Enable PipeWire Services
```bash
# Enable user services (run as regular user, not root)
systemctl --user enable --now pipewire pipewire-pulse wireplumber

# Check service status
systemctl --user status pipewire pipewire-pulse wireplumber
```

### Verify Audio Setup
```bash
# Check available sinks (audio outputs)
pactl list short sinks

# Check available sources (audio inputs)  
pactl list short sources

# Test audio output
paplay /usr/share/sounds/freedesktop/stereo/message.oga

# Or test with speaker-test
speaker-test -c 2 -t wav
```

## Dell XPS 17 Specific Configuration

### Check Hardware Detection
```bash
# Identify audio hardware
lspci -nnk | grep -A3 audio

# Expected output for Dell XPS 17 (9700):
# 00:1f.3 Multimedia audio controller: Intel Corporation Comet Lake PCH cAVS
# 01:00.1 Audio device: NVIDIA Corporation TU106 High Definition Audio Controller

# Check ALSA devices
aplay -l

# Check for SOF firmware loading
dmesg | grep -i sof
```

### SOF Firmware Issues

If audio doesn't work immediately, you may need SOF firmware fixes:

#### Method 1: Use Backup SOF Firmware
```bash
# Navigate to system config
cd ~/utono/system-config

# Run the SOF firmware restore script
chmod +x misc-md/install-sof-from-backup.sh
sudo ./misc-md/install-sof-from-backup.sh

# Reboot to apply firmware changes
sudo reboot
```

#### Method 2: Manual SOF Setup
```bash
# Install SOF firmware package
sudo pacman -S sof-firmware

# Download and install UCM2 profiles (if needed)
cd ~/Downloads

# Download SOF SoundWire profiles from Arch forum
# curl -L -o sof-soundwire.zip "https://bbs.archlinux.org/profile.php?id=173653&attach=sof-soundwire.zip"

# Install UCM2 profiles
# sudo unzip -o sof-soundwire.zip -d /usr/share/alsa/ucm2/
```

## Troubleshooting Audio Issues

### Hard Audio Reset
If audio stops working or only shows "auto_null" sinks:

```bash
# Use the audio fix script
cd ~/utono/system-config
chmod +x misc-md/fix-audio.sh
./misc-md/fix-audio.sh
```

### Manual Audio Reset
```bash
# Stop all PipeWire services
systemctl --user stop pipewire.service pipewire.socket pipewire-pulse.service pipewire-pulse.socket wireplumber.service

# Kill any remaining processes
pkill -x pipewire || true
pkill -x pipewire-pulse || true  
pkill -x wireplumber || true

# Remove WirePlumber state
rm -rf ~/.local/state/wireplumber

# Restart services
systemctl --user start pipewire.socket pipewire-pulse.socket wireplumber.service

# Wait for initialization
sleep 4

# Check for real sinks
pactl list short sinks
```

### Check Audio State
Save current audio state for debugging:

```bash
# Save audio configuration for troubleshooting
cd ~/utono/system-config
chmod +x misc-md/save-audio-state.sh
./misc-md/save-audio-state.sh ~/audio-logs/$(date +%Y-%m-%d)-audio.txt
```

## Common Audio Problems

### Problem: No Audio Devices Detected
**Symptoms**: Only "auto_null" sink appears

**Solutions**:
1. Check if SOF firmware loaded properly: `dmesg | grep -i sof`
2. Restart PipeWire services: Use hard reset method above
3. Install SOF firmware: `sudo pacman -S sof-firmware`
4. Reboot system

### Problem: Audio Works But Low Quality
**Symptoms**: Audio plays but sounds poor or choppy

**Solutions**:
```bash
# Check sample rate and format
pactl list sinks | grep -E "(Sample|Format)"

# Set higher quality format (if needed)
pactl set-default-sink-volume @DEFAULT_SINK@ 80%

# Check for buffer underruns
journalctl --user -u pipewire -f
```

### Problem: Microphone Not Working
**Symptoms**: No input devices detected

**Solutions**:
```bash
# Check microphone hardware
arecord -l

# List input sources
pactl list short sources

# Test microphone
arecord -f cd -d 5 test.wav && aplay test.wav

# Unmute microphone in alsamixer
alsamixer
```

### Problem: HDMI Audio Not Available
**Symptoms**: Only built-in speakers work, no HDMI output

**Solutions**:
```bash
# Check HDMI audio devices
aplay -l | grep HDMI

# List all sinks including HDMI
pactl list sinks | grep -E "(Name|hdmi|HDMI)"

# Manually set HDMI as default (replace with actual sink name)
pactl set-default-sink alsa_output.pci-0000_01_00.1.hdmi-stereo
```

## Advanced Configuration

### Set Default Audio Device
```bash
# List available sinks
pactl list short sinks

# Set specific sink as default
pactl set-default-sink <sink-name>

# Set default volume
pactl set-sink-volume @DEFAULT_SINK@ 80%
```

### Configure Audio Quality
```bash
# Edit PipeWire configuration (if needed)
mkdir -p ~/.config/pipewire
cp /usr/share/pipewire/pipewire.conf ~/.config/pipewire/

# Edit sample rate and buffer settings
vim ~/.config/pipewire/pipewire.conf
```

### Monitor Audio in Real-Time
```bash
# Watch PipeWire activity
journalctl --user -u pipewire -f

# Monitor WirePlumber
journalctl --user -u wireplumber -f

# Real-time sink monitoring
watch -n 1 pactl list short sinks
```

## Testing Audio Configuration

### Complete Audio Test
```bash
echo "=== Audio System Test ==="

echo "1. Checking PipeWire services..."
systemctl --user is-active pipewire pipewire-pulse wireplumber

echo "2. Checking available sinks..."
pactl list short sinks

echo "3. Checking default sink..."
pactl get-default-sink

echo "4. Testing speaker output..."
speaker-test -c 2 -t wav -l 1

echo "5. Testing with audio file..."
paplay /usr/share/sounds/freedesktop/stereo/message.oga

echo "6. Checking microphone..."
arecord -f cd -d 2 /tmp/test.wav 2>/dev/null && echo "Microphone working" && rm /tmp/test.wav

echo "Audio test complete!"
```

## Persistent Configuration

### Save Working Configuration
```bash
# Save current PipeWire state
pw-dump > ~/.config/pipewire/restore.json

# Backup working audio logs
mkdir -p ~/audio-backups
cp ~/.local/state/wireplumber/* ~/audio-backups/ 2>/dev/null || true
```
