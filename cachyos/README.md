# CachyOS Installation Guide

A comprehensive guide for installing and configuring CachyOS with Real Programmers Dvorak keyboard layout, custom configurations, and specialized setups.

## Overview

This installation guide is designed for users who want to:
- Install CachyOS with custom configurations
- Use Real Programmers Dvorak keyboard layout
- Set up development environment with dotfiles
- Configure audio, gamepad, and other peripherals
- Maintain consistent settings across multiple machines

## Installation Phases

### Phase 1: Preparation
- **[00-usb-preparation.md](00-usb-preparation.md)** - Backup configurations and prepare USB drive
- **[01-keyboard-layout.md](01-keyboard-layout.md)** - Configure Real Programmers Dvorak before installation
- **[02-cachyos-install.md](02-cachyos-install.md)** - CachyOS installation with proper keyboard layout

### Phase 2: System Configuration (Root Required)
- **[03-system-security.md](03-system-security.md)** - Security settings and emergency controls
- **[04-grub-sddm-config.md](04-grub-sddm-config.md)** - Boot loader and display manager configuration

### Phase 3: User Setup
- **[05-user-setup.md](05-user-setup.md)** - User account configuration and dotfiles
- **[06-hyprland-services.md](06-hyprland-services.md)** - Desktop environment and systemd services

### Phase 4: Specialized Configuration
- **[07-audio-configuration.md](07-audio-configuration.md)** - PipeWire audio setup and troubleshooting
- **[08-gamepad-setup.md](08-gamepad-setup.md)** - Gaming peripheral configuration
- **[09-troubleshooting.md](09-troubleshooting.md)** - Common issues and solutions

## Quick Start Checklist

For experienced users who want a condensed overview:

### Pre-Installation
- [ ] Format USB drive and backup configurations (00)
- [ ] Configure keyboard layout for installation (01)
- [ ] Install CachyOS with proper settings (02)

### System Setup
- [ ] Configure system security and emergency controls (03)
- [ ] Set up GRUB resolution and SDDM (04)

### User Configuration
- [ ] Restore dotfiles and configure user environment (05)
- [ ] Set up Hyprland and systemd services (06)

### Specialized Setup
- [ ] Configure audio system (07)
- [ ] Set up gaming peripherals (08)
- [ ] Test and troubleshoot issues (09)

## Prerequisites

### Hardware
- Dell XPS 17 (9700) or compatible system
- USB drive (32GB+ recommended)
- Internet connection

### Software
- Existing Arch/CachyOS system (for backup preparation)
- SSH keys for repository access
- GITHUB_TOKEN for private repositories

### Knowledge
- Basic Linux command line usage
- Understanding of Arch Linux package management
- Git repository management

## Key Features of This Setup

### Real Programmers Dvorak
- Optimized keyboard layout for programming
- Consistent across TTY, X11, and Wayland
- Home row modifiers via keyd

### Audio Configuration
- PipeWire-based audio stack
- SOF firmware for Intel audio
- Troubleshooting for Dell XPS audio issues

### Development Environment
- Neovim with custom configuration
- Git integration with SSH keys
- Shell configuration with Zsh and Starship

### Gaming Setup
- 8BitDo gamepad integration
- MPV media player controls
- Bluetooth peripheral management

## Repository Structure

```
~/utono/install/cachyos/
├── 00-usb-preparation.md      # USB backup and preparation
├── 01-keyboard-layout.md      # RPD keyboard setup
├── 02-cachyos-install.md      # OS installation
├── 03-system-security.md     # System security config
├── 04-grub-sddm-config.md    # Boot and display manager
├── 05-user-setup.md          # User configuration
├── 06-hyprland-services.md   # Desktop environment
├── 07-audio-configuration.md # Audio setup
├── 08-gamepad-setup.md       # Gaming peripherals
├── 09-troubleshooting.md     # Problem solving
└── README.md                 # This file
```

## Support Files

The installation references various configuration files and scripts located in:
- `~/utono/system-config/` - System-level configurations
- `~/utono/tty-dotfiles/` - User dotfiles and configurations
- `~/utono/rpd/` - Real Programmers Dvorak keyboard files
- `~/utono/install/paclists/` - Package lists for installation

## Getting Help

### Troubleshooting Steps
1. Check the relevant troubleshooting section in each guide
2. Review [09-troubleshooting.md](09-troubleshooting.md) for common issues
3. Check systemd logs: `journalctl -xe`
4. Verify service status: `systemctl --failed`

### Common Issues
- **Audio not working**: See audio configuration and SOF firmware steps
- **Keyboard layout problems**: Verify keyd service and layout files
- **Display issues**: Check GRUB and SDDM configuration
- **Service failures**: Review systemd service configurations

## Contributing

To improve this documentation:
1. Test the installation process
2. Document any issues or improvements
3. Submit pull requests with updates
4. Report problems in the issue tracker

## License

This documentation and associated configuration files are provided as-is for personal use and modification.

---

**Start your installation journey with [00-usb-preparation.md](00-usb-preparation.md)**
