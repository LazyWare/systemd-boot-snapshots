# File: CHANGELOG.md
# Project Path: ./CHANGELOG.md
# Installation Path: /usr/share/doc/systemd-boot-snapshots/CHANGELOG.md

# Changelog

All notable changes to the systemd-boot-snapshots project will be documented in this file.

## [0.1.0] - 2025-04-23

### Added
- Initial release for Arch Linux
- Support for both mkinitcpio (Arch Linux) and dracut (EndeavourOS, Garuda Linux)
- Automatic detection of BTRFS snapshots from Timeshift and Snapper
- Automatic addition of snapshots to systemd-boot menu
- Desktop notifications when booting into a snapshot
- Automatic overlay configuration for snapshot protection
- Automatic mounting of kernel modules from parent volume when needed
- Path monitors for detecting new snapshots
- AUR package support

### Changed
- Adapted from the original Ubuntu/Fedora implementation
- Restructured to follow Arch Linux paths and conventions
- Removed initramfs-tools dependencies
- Added support for multiple notification systems for Arch desktop environments

### Fixed
- Correct handling of systemd paths for Arch Linux
- Proper detection of boot partition path
- Safe handling of read-only snapshots

## [0.0.1] - 2023-07-22

### Added
- Original implementation for Ubuntu by Usarin Heininga
