# File: install.sh
# Project Path: ./install.sh
# Installation Path: N/A (used for manual installation)
#
# Installation script for systemd-boot-snapshots
# Supports both mkinitcpio and dracut

set -e

# Function to display script usage
show_help() {
    echo "Installation of systemd-boot-snapshots for Arch Linux"
    echo ""
    echo "Usage: $0 [options]"
    echo "  --help         Show this help message"
    echo "  --uninstall    Uninstall systemd-boot-snapshots"
    echo ""
}

# Detect which initramfs system is in use
detect_initramfs_system() {
    if command -v dracut >/dev/null 2>&1; then
        echo "dracut"
    else
        echo "mkinitcpio"
    fi
}

# Function to detect EFI partition mount point
detect_efi_mount() {
    # Try common EFI mount locations
    for mount_point in "/boot/efi" "/boot" "/efi"; do
        if mountpoint -q "$mount_point" && [ -d "$mount_point/EFI" ]; then
            echo "$mount_point"
            return 0
        fi
    done
    
    # If no standard location is found, try to find it from fstab or mounted partitions
    local efi_mount
    efi_mount=$(grep -E "/boot/efi|/boot|/efi" /etc/fstab | grep -i "vfat|fat32" | awk '{print $2}' | head -n 1)
    
    if [ -n "$efi_mount" ] && [ -d "$efi_mount/EFI" ]; then
        echo "$efi_mount"
        return 0
    fi
    
    # Last resort, check mounted filesystems
    efi_mount=$(mount | grep "vfat" | grep -E "/boot/efi|/boot|/efi" | awk '{print $3}' | head -n 1)
    
    if [ -n "$efi_mount" ] && [ -d "$efi_mount/EFI" ]; then
        echo "$efi_mount"
        return 0
    fi
    
    echo ""
    return 1
}

# Function to determine snapshot tools and paths
detect_snapshot_tools() {
    local snapshot_tools=""
    
    # Check for Timeshift
    if command -v timeshift >/dev/null 2>&1; then
        snapshot_tools="$snapshot_tools timeshift"
        # Check if custom path is configured
        if [ -f /etc/timeshift.json ]; then
            # Extract snapshot path from timeshift config
            TIMESHIFT_PATH=$(grep -o '"backup_device_uuid" : "[^"]*"' /etc/timeshift.json | cut -d'"' -f4)
            if [ -n "$TIMESHIFT_PATH" ]; then
                echo "Found Timeshift config with UUID: $TIMESHIFT_PATH"
            fi
        fi
    fi
    
    # Check for Snapper
    if command -v snapper >/dev/null 2>&1; then
        snapshot_tools="$snapshot_tools snapper"
        # Check if custom path is configured
        if [ -d /etc/snapper/configs ]; then
            # List snapper configs
            echo "Found Snapper configurations:"
            ls -1 /etc/snapper/configs
        fi
    fi
    
    echo "$snapshot_tools"
}

# Function to install
install_snapshots() {
    echo "Installing systemd-boot-snapshots..."
    
    INITRAMFS_SYSTEM=$(detect_initramfs_system)
    echo "Detected initramfs system: $INITRAMFS_SYSTEM"
    
    EFI_MOUNT=$(detect_efi_mount)
    if [ -z "$EFI_MOUNT" ]; then
        echo "Warning: Could not detect EFI partition mount point. Defaulting to /boot/efi"
        EFI_MOUNT="/boot/efi"
    else
        echo "Detected EFI partition mounted at: $EFI_MOUNT"
    fi
    
    SNAPSHOT_TOOLS=$(detect_snapshot_tools)
    echo "Detected snapshot tools: $SNAPSHOT_TOOLS"
    
    # Create required directories
    mkdir -p /etc/default
    mkdir -p /usr/bin
    mkdir -p /usr/lib/systemd-boot-snapshots
    mkdir -p /usr/lib/systemd/system
    
    # Install configuration files
    install -Dm644 systemd-boot-snapshots.conf /etc/default/systemd-boot-snapshots.conf
    
    # Copy default config to /etc/ if it doesn't exist
    if [ ! -f /etc/systemd-boot-snapshots.conf ]; then
        install -Dm644 systemd-boot-snapshots.conf /etc/systemd-boot-snapshots.conf
    fi
    
    # Install main scripts
    install -Dm755 update-systemd-boot-snapshots /usr/bin/update-systemd-boot-snapshots
    install -Dm755 systemd-boot-mount-snapshot-modules /usr/lib/systemd-boot-snapshots/systemd-boot-mount-snapshot-modules
    install -Dm755 systemd-boot-snapshots-notify /usr/lib/systemd-boot-snapshots/systemd-boot-snapshots-notify
    
    # Update EFI path in systemd-boot-entries.path
    sed -i "s|PathModified=/boot/efi/loader/entries|PathModified=$EFI_MOUNT/loader/entries|g" systemd-boot-entries.path
    
    # Install systemd files
    install -Dm644 update-systemd-boot-snapshots.service /usr/lib/systemd/system/update-systemd-boot-snapshots.service
    install -Dm644 systemd-boot-entries.path /usr/lib/systemd/system/systemd-boot-entries.path
    install -Dm644 snapper-snapshots.path /usr/lib/systemd/system/snapper-snapshots.path
    install -Dm644 timeshift-snapshots.path /usr/lib/systemd/system/timeshift-snapshots.path
    
    # Installation specific to initramfs system
    if [ "$INITRAMFS_SYSTEM" = "dracut" ]; then
        # Installation for dracut
        mkdir -p /usr/lib/dracut/modules.d/90systemd-boot-snapshots
        install -Dm755 dracut/90systemd-boot-snapshots/module-setup.sh /usr/lib/dracut/modules.d/90systemd-boot-snapshots/module-setup.sh
        install -Dm755 dracut/90systemd-boot-snapshots/systemd-boot-snapshots.sh /usr/lib/dracut/modules.d/90systemd-boot-snapshots/systemd-boot-snapshots.sh
        ln -sf /usr/lib/systemd-boot-snapshots/systemd-boot-mount-snapshot-modules /usr/lib/dracut/modules.d/90systemd-boot-snapshots/systemd-boot-mount-snapshot-modules.sh
        ln -sf /usr/lib/systemd-boot-snapshots/systemd-boot-snapshots-notify /usr/lib/dracut/modules.d/90systemd-boot-snapshots/systemd-boot-snapshots-notify
        echo "Dracut configuration installed."
    else
        # Installation for mkinitcpio
        mkdir -p /usr/lib/initcpio/hooks
        mkdir -p /usr/lib/initcpio/install
        install -Dm644 mkinitcpio/hooks/systemd-boot-snapshots /usr/lib/initcpio/hooks/systemd-boot-snapshots
        install -Dm644 mkinitcpio/install/systemd-boot-snapshots /usr/lib/initcpio/install/systemd-boot-snapshots
        
        # Add systemd-boot-snapshots module to mkinitcpio.conf if not already present
        if ! grep -q "systemd-boot-snapshots" /etc/mkinitcpio.conf; then
            if grep -q "HOOKS=.*block" /etc/mkinitcpio.conf; then
                sed -i 's/\(HOOKS=.*block\)/\1 systemd-boot-snapshots/' /etc/mkinitcpio.conf
            else
                sed -i 's/\(HOOKS=.*autodetect\)/\1 systemd-boot-snapshots/' /etc/mkinitcpio.conf
            fi
        fi
        echo "Mkinitcpio configuration installed."
    fi
    
    # Enable systemd services based on detected tools
    systemctl daemon-reload
    systemctl enable systemd-boot-entries.path
    
    # Enable snapshot monitoring based on detected tools
    if echo "$SNAPSHOT_TOOLS" | grep -q "snapper"; then
        systemctl enable snapper-snapshots.path
        echo "Snapper snapshot monitoring enabled."
    fi
    
    if echo "$SNAPSHOT_TOOLS" | grep -q "timeshift"; then
        systemctl enable timeshift-snapshots.path
        echo "Timeshift snapshot monitoring enabled."
    fi
    
    # Update initramfs
    echo "Updating initramfs..."
    if [ "$INITRAMFS_SYSTEM" = "dracut" ]; then
        # Update initramfs with dracut
        dracut -f
    else
        # Update initramfs with mkinitcpio
        mkinitcpio -P
    fi
    
    echo "Installation complete. Running update-systemd-boot-snapshots..."
    update-systemd-boot-snapshots
    
    echo "systemd-boot-snapshots v0.1.1 has been successfully installed and configured."
    echo "You can now boot into snapshots from the systemd-boot menu (press space at boot)."
}

# Function to uninstall
uninstall_snapshots() {
    echo "Uninstalling systemd-boot-snapshots..."
    
    INITRAMFS_SYSTEM=$(detect_initramfs_system)
    
    # Disable systemd services
    systemctl disable --now timeshift-snapshots.path snapper-snapshots.path systemd-boot-entries.path update-systemd-boot-snapshots.service
    systemctl daemon-reload
    
    # Remove common files
    rm -f /etc/default/systemd-boot-snapshots.conf
    rm -f /etc/systemd-boot-snapshots.conf
    rm -f /usr/bin/update-systemd-boot-snapshots
    rm -f /usr/lib/systemd-boot-snapshots/systemd-boot-mount-snapshot-modules
    rm -f /usr/lib/systemd-boot-snapshots/systemd-boot-snapshots-notify
    rm -f /usr/lib/systemd/system/update-systemd-boot-snapshots.service
    rm -f /usr/lib/systemd/system/systemd-boot-entries.path
    rm -f /usr/lib/systemd/system/snapper-snapshots.path
    rm -f /usr/lib/systemd/system/timeshift-snapshots.path
    
    # Removal specific to initramfs system
    if [ "$INITRAMFS_SYSTEM" = "dracut" ]; then
        # Removal for dracut
        rm -rf /usr/lib/dracut/modules.d/90systemd-boot-snapshots
    else
        # Removal for mkinitcpio
        rm -f /usr/lib/initcpio/hooks/systemd-boot-snapshots
        rm -f /usr/lib/initcpio/install/systemd-boot-snapshots
        
        # Remove module from mkinitcpio.conf
        sed -i 's/ systemd-boot-snapshots//' /etc/mkinitcpio.conf
    fi
    
    # Remove directory
    rmdir --ignore-fail-on-non-empty /usr/lib/systemd-boot-snapshots/
    
    # Update initramfs
    echo "Updating initramfs..."
    if [ "$INITRAMFS_SYSTEM" = "dracut" ]; then
        dracut -f
    else
        mkinitcpio -P
    fi
    
    echo "systemd-boot-snapshots has been successfully uninstalled."
}

# Process arguments
if [ "$1" = "--help" ]; then
    show_help
    exit 0
elif [ "$1" = "--uninstall" ]; then
    uninstall_snapshots
    exit 0
else
    install_snapshots
fi
