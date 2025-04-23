# File: README.md
# Project Path: ./README.md
#
# Documentation for systemd-boot-snapshots

# systemd-boot-snapshots for Arch Linux

This tool enhances systemd-boot by adding BTRFS snapshots to the boot menu.

## Features

- Boot into a system snapshot directly from the boot menu
- Support for BTRFS snapshots, including those created with "Timeshift" and "Snapper"
- Support for read-only snapshots
- Automatic overlay configuration when booting from a snapshot
- Automatic mounting of kernel modules directory from the main volume if needed
- Desktop notification when booting in snapshot mode

## Requirements

- Arch Linux or derivatives
- systemd-boot as bootloader
- BTRFS filesystem with snapshots
- mkinitcpio or dracut for generating the initramfs

## Manual Installation

1. Clone this repository or download the required files

2. Run the installation script:
   ```
   sudo bash ./install.sh
   ```

3. Update the initramfs image:
   
   With mkinitcpio (standard Arch Linux):
   ```
   sudo mkinitcpio -P
   ```
   
   With dracut (EndeavourOS, Garuda Linux):
   ```
   sudo dracut -f
   ```

4. Manually update the systemd-boot menu:
   ```
   sudo update-systemd-boot-snapshots
   ```

## AUR Package Installation

If you prefer to install via AUR, you can create and install the package:

```bash
git clone https://aur.archlinux.org/systemd-boot-snapshots.git
cd systemd-boot-snapshots
makepkg -si
```

After installation, enable the path units:
```bash
# Required for all installations
sudo systemctl enable systemd-boot-entries.path

# Only if you use Snapper
sudo systemctl enable snapper-snapshots.path

# Only if you use Timeshift
sudo systemctl enable timeshift-snapshots.path
```

## Configuration

The configuration file is located at `/etc/systemd-boot-snapshots.conf` with a fallback at `/etc/default/systemd-boot-snapshots.conf` and contains the following options:

- `SHOW_SNAPSHOTS_MAX`: maximum number of snapshots to show (default: 99999)
- `SNAPSHOT_PERIOD_TYPE`: type of snapshots to show (default: "all", options: "ondemand", "boot", "hourly", "daily", "weekly", "monthly")
- `USE_OVERLAYROOT`: whether to use an overlay to protect the snapshot (default: "true")
- `VERBOSE`: verbosity level (default: 0)

## Usage

The tool will automatically monitor the system for new snapshots or changes to the bootloader configuration and update the boot menu when necessary.

To manually populate the boot menu with available snapshots, run:
```
sudo update-systemd-boot-snapshots
```

At boot time, press the space bar to enter the boot menu.
Now you can select a snapshot entry to boot into that system state.

When booting into a snapshot, you will see a desktop notification informing you that you are in snapshot mode and that changes to the system will be discarded on reboot.

## Notes for Arch Linux and derivatives

This project has been adapted from a version originally developed for Ubuntu/Fedora. The adaptation takes into account the specificities of Arch Linux and derivatives, in particular:

1. Supports both mkinitcpio (standard Arch Linux) and dracut (EndeavourOS, Garuda Linux)
2. Handles Arch Linux-specific paths differently
3. Supports common desktop notification methods in Arch distributions
4. Automatically detects the initramfs system in use and configures accordingly
5. Automatically detects EFI partition location (supports /boot/efi, /boot, and /efi)
6. Automatically detects and adapts to Timeshift and Snapper configurations
7. Follows Arch Linux path conventions (/usr/bin instead of /usr/sbin, etc.)

## Troubleshooting

- If snapshots don't appear in the boot menu, verify that:
  - systemd-boot is properly installed and configured
  - the root filesystem is BTRFS
  - valid BTRFS snapshots exist
  - the update-systemd-boot-snapshots script runs without errors

- If you can't boot into a snapshot, verify:
  - For systems with mkinitcpio: that the systemd-boot-snapshots hook is included in /etc/mkinitcpio.conf
  - For systems with dracut: that the 90systemd-boot-snapshots module is present in /usr/lib/dracut/modules.d/
  - In both cases: that the parent_subvol kernel parameter is correct
  
- If you don't see the desktop notification, verify that:
  - the system is actually running from a snapshot
  - desktop notification packages are installed

## Version History

See [CHANGELOG.md](CHANGELOG.md) for version history and changes.
