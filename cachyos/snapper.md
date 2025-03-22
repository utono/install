# Configure Snapper

### List Existing Btrfs Subvolumes

To display the current Btrfs subvolumes, run:

```bash
sudo btrfs subvolume list /
```

### Check Btrfs Mount Points

To verify the mounted Btrfs subvolumes, use:

```bash
findmnt -nt btrfs
```

### Ensure Subvolume Setup

Ensure the `@` subvolume is mounted at `/`. If preferred, create a separate snapshots subvolume:

```bash
sudo btrfs subvolume create /@snapshots
```

Verify with:

```bash
sudo btrfs subvolume list /
```

### Create a Snapper Configuration

Create a Snapper configuration for the root (`/`) filesystem:

```bash
sudo snapper -c root create-config /
```

### List Available Snapper Configurations

These correspond to the system locations where Snapper manages snapshots:

```bash
ls /etc/snapper/configs/
```

### List Snapshots for a Specific Configuration

To display existing snapshots, including their IDs, timestamps, descriptions, and types:

```bash
sudo snapper -c root list
```

### Set Permissions

Ensure proper permissions for Snapper to function correctly:

```bash
sudo chmod 750 /@snapshots
sudo chown root:root /@snapshots
ls -al /
```

### Configure Snapper

#### Configure Snapper for Root

Edit the Snapper configuration file:

```bash
sudo nvim /etc/snapper/configs/root
```

Modify or add the following settings:

```plaintext
ALLOW_USERS="mlj"
NUMBER_CLEANUP="yes"
NUMBER_MIN_AGE="1800"
NUMBER_LIMIT="10"
NUMBER_LIMIT_IMPORTANT="5"
TIMELINE_CREATE="yes"
TIMELINE_CLEANUP="yes"
```

### Enable Systemd Timers for Snapshots

To ensure regular snapshot creation and cleanup, enable the necessary systemd timers:

```bash
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer
```
### Enable GRUB Integration

This ensures that new snapshots appear in the GRUB boot menu automatically:

```bash
sudo pacman -Sy --needed grub-btrfs
sudo systemctl enable --now grub-btrfsd
```

### Update GRUB Configuration

Generate a new GRUB boot configuration file:

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

If GRUB does not detect installed OSes:

```bash
sudo os-prober
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

If `os-prober` is disabled, enable it in `/etc/default/grub`:

```bash
GRUB_DISABLE_OS_PROBER=false
```

Ensure `grub-btrfsd` is running:

```bash
sudo systemctl enable --now grub-btrfsd
```

### Perform a System Rollback

Reboot your system and select the desired snapshot in GRUB. After booting into the snapshot, permanently revert your system:

```bash
sudo snapper -c root rollback 1
reboot
```

### Delete Snapper Configuration for Home

To delete the Snapper configuration for home and remove all associated snapshots:

```bash
sudo snapper -c home delete-config
```

To delete all snapshots:

```bash
sudo rm -rf /.snapshots/home
```

If Snapper created subvolumes for snapshots, list and delete them manually:

```bash
sudo btrfs subvolume list / | grep '@snapshots/home'
sudo btrfs subvolume delete /@snapshots/home/*
sudo btrfs subvolume delete /@snapshots/home
```

### Create a Manual Snapshot

Before performing a system update, create a manual snapshot:

```bash
sudo snapper -c root create --description "Before System Update"
```

### Common Snapper Commands

#### Create a Snapshot

```bash
sudo snapper -c root create --description "Snapshot Description"
```

#### List Snapshots

```bash
sudo snapper -c root list
```

#### Delete a Snapshot

```bash
sudo snapper -c root delete <snapshot_number>
```

#### Undo Changes from a Specific Snapshot

```bash
sudo snapper -c root undochange <snapshot_number>
```

#### Rollback to a Specific Snapshot

```bash
sudo snapper -c root rollback <snapshot_number>
```

#### Show Snapshot Details

```bash
sudo snapper -c root status <snapshot_number>
```

#### Compare Two Snapshots

```bash
sudo snapper -c root diff <snapshot_1> <snapshot_2>
```

Before performing a system update, create a manual snapshot:

```bash
sudo snapper -c root create --description "Before System Update"
```

