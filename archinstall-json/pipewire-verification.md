# Post-Installation Audio Verification Checklist (TTY) - Dell XPS 17 (9700)

## Objective
Identify hardware, verify kernel modules, ensure **PipeWire** is correctly set up using only the packages defined in the `PipewireProfile` script, and use `udev` to troubleshoot device detection.

---

pacman -Syy alsa-utils

## Step 1: Identify Audio Hardware
### 1.1 List PCI Sound Devices
```bash

lspci -nnk | grep -A3 audio

Dell XPS 17 9700:
00:1f.3 Multimedia audio controller [0401]: Intel Corporation Comet Lake PCH cAVS [8086:06c8]
        Subsystem: Dell Device [1028:098f]
        Kernel driver in use: sof-audio-pci-intel-cnl
        Kernel modules: snd_hda_intel, snd_soc_avs, snd_sof_pci_intel_cnl

Dell XPS 17 9730:
 lspci -nnk | grep -A3 audio
00:1f.3 Multimedia audio controller [0401]: Intel Corporation Raptor Lake-P/U/H cAVS [8086:51ca] (rev 01)
        Subsystem: Dell Device [1028:0bda]
        Kernel driver in use: sof-audio-pci-intel-tgl
        Kernel modules: snd_hda_intel, snd_soc_avs, snd_sof_pci_intel_tgl
00:1f.4 SMBus [0c05]: Intel Corporation Alder Lake PCH-P SMBus Host Controller [8086:51a3] (rev 01)
        Subsystem: Dell Device [1028:0bda]

XPS 15 9500:
```

### 1.2 List USB Audio Devices (If Applicable)
```bash
lsusb | grep -i audio
```
**Expected Output:**
```
Bus 003 Device 002: ID 1234:5678 USB Audio Device
```

---

## Step 2: Verify and Load Required Kernel Modules
### 2.1 List Loaded Sound Modules
```bash
lsmod | grep -E 'snd_hda_intel|snd_soc_avs|snd_sof_pci_intel_cnl'
```
**Expected Modules:**
- `snd_hda_intel`
- `snd_soc_avs`
- `snd_sof_pci_intel_cnl`

**If Missing, Load Manually:**
```bash
sudo modprobe snd_sof_pci snd_sof_intel_hda_common snd_hda_intel
```

---

## Step 3: Verify Device Detection Using `udev`
### 3.1 Check If the Audio Device Is Recognized
```bash
udevadm info -e | grep -i audio -A10
```

### 3.2 Find the Device Path for the Audio Card
```bash
udevadm info /sys/class/sound/card0
```

### 3.3 Monitor Real-Time `udev` Events
```bash
udevadm monitor --property --udev
```

### 3.4 Manually Trigger a `udev` Rescan
```bash
sudo udevadm control --reload-rules && sudo udevadm trigger
```

**If That Fails, Restart `udev`:**
```bash
sudo systemctl restart systemd-udevd
```

---

## Step 4: Install Required Packages
```bash
sudo pacman -S pipewire pipewire-alsa pipewire-jack pipewire-pulse gst-plugin-pipewire libpulse wireplumber
```

---

## Step 5: Enable and Start PipeWire
```bash
systemctl --user enable --now pipewire wireplumber pipewire-pulse
```

---

## Step 6: Check PipeWire & ALSA Integration
### 6.1 Verify PipeWire Status
```bash
systemctl --user status pipewire
```

### 6.2 Verify ALSA Through PipeWire
```bash
pw-cli ls Node | grep alsa
```

---

## Step 7: Unmute and Adjust Volume Using `amixer`
```bash
amixer set Master unmute
amixer set PCM unmute
amixer set Master 80%
amixer set PCM 80%
```

**Alternative:** Use `alsamixer`
```bash
alsamixer
```

---

## Step 8: Test Audio Output
```bash
speaker-test -D hw:0,0 -c 2
```

---

## Step 9: Check System Logs for Errors
```bash
journalctl -k | grep -iE 'snd|sof|alsa|pipewire'
```

---

## Step 10: Verify User Permissions
```bash
groups | grep audio
```

**If Missing, Add User to Group:**
```bash
sudo usermod -aG audio $USER
```

---

## Step 11: Set Default Output Device (If Needed)
```bash
pactl list short sinks
pactl set-default-sink <sink_name>
```

---

## Step 12: Reboot & Verify Sound
```bash
sudo reboot
```
**Then Test Again:**
```bash
speaker-test -D hw:0,0 -c 2
```

---

## ✅ Final Troubleshooting Checklist
| **Step** | **Command** |
|----------|------------|
| **1. Identify Audio Hardware** | `lspci -nnk | grep -A3 Audio` |
| **2. Check Kernel Modules** | `lsmod | grep -E 'snd_sof_pci|snd_sof_intel_hda_common|snd_hda_intel'` |
| **3. Check If `udev` Recognizes the Sound Card** | `udevadm info -e | grep -i audio -A10` |
| **4. Find Device Path** | `udevadm info /sys/class/sound/card0` |
| **5. Monitor Real-Time `udev` Events** | `udevadm monitor --property --udev` |
| **6. Manually Trigger `udev`** | `sudo udevadm control --reload-rules && sudo udevadm trigger` |
| **7. Install Packages** | `sudo pacman -S pipewire pipewire-alsa pipewire-jack pipewire-pulse gst-plugin-pipewire libpulse wireplumber` |
| **8. Unmute & Set Volume** | `amixer set Master unmute && amixer set Master 80%` |
| **9. Test ALSA Playback** | `speaker-test -D hw:0,0 -c 2` |
| **10. Check System Logs** | `journalctl -k | grep -iE 'snd|sof|alsa|pipewire'` |
| **11. Verify User Permissions** | `groups | grep audio` |
| **12. Set Default Output** | `pactl set-default-sink <sink_name>` |
| **13. Reboot & Recheck** | `sudo reboot` |

---

**This checklist ensures Dell XPS 17 (9700) audio is properly detected, configured, and working while using only the packages from `PipewireProfile`.**

