# systemd-boot-snapshots for Arch Linux

This tool enhances systemd-boot by adding BTRFS snapshots to the boot menu.

## Features

- Boot into a system snapshot directly from the boot menu
- Organized snapshot submenu structure for better navigation
- Support for BTRFS snapshots, including those created with "Timeshift" and "Snapper"
- Support for read-only snapshots with overlayfs protection
- Automatic mounting of kernel modules directory from the main volume if needed
- Desktop notification when booting in snapshot mode
- Detailed debugging options for troubleshooting boot issues
- Customizable snapshot naming with safety indicators

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

### Basic Options

- `SHOW_SNAPSHOTS_MAX`: Maximum number of snapshots to show (default: 99999)
- `SNAPSHOT_PERIOD_TYPE`: Type of snapshots to show (default: "all", options: "ondemand", "boot", "hourly", "daily", "weekly", "monthly")
- `VERBOSE`: Verbosity level of the script (default: 0)

### Snapshot and Boot Behavior

- `USE_OVERLAYROOT`: Whether to use an overlay to protect the snapshot (default: "true")  
  When enabled, creates a tmpfs overlay that makes the snapshot appear writable while preserving the snapshot integrity. Changes made while booted in a snapshot are discarded on reboot.

  **⚠️ IMPORTANT SAFETY WARNING**:  
  - This option should **ALWAYS** be set to `true`
  - Setting to `false` will attempt to mount snapshots in read-write mode, which can permanently corrupt your snapshots
  - Corrupted snapshots cannot be used for system recovery
  - Only use `false` if you fully understand the consequences and have specific technical reasons

### User Interface Options

- `SNAPSHOTS_SUBMENU`: Place snapshots in a dedicated submenu for better organization (default: "true")
- `SNAPSHOT_TITLE_FORMAT`: Format for snapshot entry titles in the boot menu  
  (default: "{kernel_version} [{safety}] - {date} {type} {description}")

### Troubleshooting Options

- `DEBUG_BOOT`: Enable detailed debug logging during boot (default: "false")  
  When enabled, detailed logs are written to `/var/log/systemd-boot-snapshots-debug.log` to help diagnose boot issues

## Snapshot Entry Naming

Systemd-boot-snapshots allows you to customize how snapshot entries appear in the boot menu. You can configure this by editing the `SNAPSHOT_TITLE_FORMAT` parameter in the configuration file.

### Naming Format Options

The following variables are available for use in the format string:

- `{kernel_version}` - The kernel version contained in the snapshot (e.g., "5.15.0-1-arch")
- `{safety}` - Shows either "SAFE" or "CAUTION" depending on kernel compatibility with current system
- `{date}` - The date when the snapshot was created 
- `{type}` - The type or tag of the snapshot (e.g., "hourly", "daily", "pre", "post")
- `{description}` - The description or comment for the snapshot

### Examples

Default format (shows all information):
```
SNAPSHOT_TITLE_FORMAT="{kernel_version} [{safety}] - {date} {type} {description}"
```

Simple format (just kernel and date):
```
SNAPSHOT_TITLE_FORMAT="{kernel_version} - {date}"
```

Focus on system safety:
```
SNAPSHOT_TITLE_FORMAT="{safety} - {date} {description}"
```

### Safety Indicators

Entries marked as "SAFE" indicate snapshots with kernels that match your current running kernel version, meaning they are likely to boot without problems. Entries marked as "CAUTION" have different kernel versions that might not be fully compatible with your current hardware configuration.

For the most reliable boot experience, prefer snapshots marked as "SAFE" when recovering your system.

## Usage

The tool will automatically monitor the system for new snapshots or changes to the bootloader configuration and update the boot menu when necessary.

To manually populate the boot menu with available snapshots, run:
```
sudo update-systemd-boot-snapshots
```

At boot time, press the space bar to enter the boot menu.
Now you can select a snapshot entry to boot into that system state.

### Navigating the Snapshot Menu

When `SNAPSHOTS_SUBMENU` is enabled (default):
1. Select the "BTRFS Snapshots" entry in the main boot menu
2. Navigate to the snapshot you want to boot
3. Select an entry based on kernel version
   - Entries labeled "SAFE" indicate compatibility with the current system
   - Entries labeled "CAUTION" may have compatibility issues

### Booting into Snapshots

When booting into a snapshot, you will see a desktop notification informing you that you are in snapshot mode and that changes to the system will be discarded on reboot.

If you want to make permanent changes while booted in a snapshot, you will need to use your snapshot tool (Snapper/Timeshift) to restore the snapshot to your main system.

### Troubleshooting Boot Issues

If you experience problems booting into snapshots, you can enable debugging with the `DEBUG_BOOT` option in the configuration file. After enabling it, detailed logs will be written to `/var/log/systemd-boot-snapshots-debug.log` on the next boot attempt.

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

- For encrypted root partitions (LUKS):
  - Enable the `DEBUG_BOOT` option in configuration
  - Check the logs at `/var/log/systemd-boot-snapshots-debug.log`
  - Ensure LUKS device is properly unlocked before mounting snapshots

## Version History

See [CHANGELOG.md](CHANGELOG.md) for version history and changes.
