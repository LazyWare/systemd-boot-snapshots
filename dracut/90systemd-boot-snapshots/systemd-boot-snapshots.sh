#!/bin/sh
#
# File: systemd-boot-snapshots.sh
# Project Path: ./dracut/90systemd-boot-snapshots/systemd-boot-snapshots.sh
# Installation Path: /usr/lib/dracut/modules.d/90systemd-boot-snapshots/systemd-boot-snapshots.sh
#
# Dracut script for systemd-boot-snapshots
# Handles the mounting of kernel modules when booting from snapshots

# Get variables from dracut environment
# shellcheck disable=SC2154
root_fstype="$fstype"
root_flags="$rflags"
root_mount="$NEWROOT"
root_device="${root#block:}"

# Call the mount script to handle module mounting
systemd-boot-mount-snapshot-modules "$root_device" "$root_mount" "$root_flags" "$root_fstype" > /dev/null
