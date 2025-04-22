#!/bin/bash
#
# File: module-setup.sh
# Project Path: ./dracut/90systemd-boot-snapshots/module-setup.sh
# Installation Path: /usr/lib/dracut/modules.d/90systemd-boot-snapshots/module-setup.sh
#
# Dracut module for systemd-boot-snapshots
# Adds support for booting from BTRFS snapshots in systemd-boot

# Function to check if this module should be included
check() {
    return 0
}

# Function to specify module dependencies
depends() {
    # No dependencies on other modules - just need a root filesystem
    return 0
}

# Function for kernel installation (not needed)
installkernel() {
    return 0
}

# Main installation function
install() {
    # Install the main script to be executed in the pre-pivot phase
    inst_hook pre-pivot 90 "$moddir/systemd-boot-snapshots.sh"
    
    # Install the scripts for mounting modules and sending notifications
    inst_script "/usr/lib/systemd-boot-snapshots/systemd-boot-mount-snapshot-modules" "/bin/systemd-boot-mount-snapshot-modules"
    inst_script "/usr/lib/systemd-boot-snapshots/systemd-boot-snapshots-notify" "/bin/systemd-boot-snapshots-notify"
}
