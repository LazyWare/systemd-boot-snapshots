#!/bin/bash
# File: install.sh
# Project Path: ./install.sh
# Installation Path: N/A (used only for manual installation)
#
# Manual installation script for systemd-boot-snapshots for Arch Linux
# Supports both mkinitcpio and dracut
#

set -e

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root${NC}"
    exit 1
fi

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="/usr/share/systemd-boot-snapshots"
CONFIG_DIR="/etc/default"
BIN_DIR="/usr/bin"
DOC_DIR="/usr/share/doc/systemd-boot-snapshots"
LICENSE_DIR="/usr/share/licenses/systemd-boot-snapshots"

echo -e "${GREEN}Installing systemd-boot-snapshots...${NC}"

# Create directories if they don't exist
mkdir -p "${INSTALL_DIR}"
mkdir -p "${CONFIG_DIR}"
mkdir -p "${DOC_DIR}"
mkdir -p "${LICENSE_DIR}"

# Install main scripts
echo -e "${GREEN}Installing scripts...${NC}"
cp -v "${SCRIPT_DIR}/scripts/"*.sh "${INSTALL_DIR}/"
chmod +x "${INSTALL_DIR}"/*.sh

# Install update script
echo -e "${GREEN}Installing systemd-boot update script...${NC}"
cp -v "${SCRIPT_DIR}/bin/update-systemd-boot-snapshots" "${BIN_DIR}/"
chmod +x "${BIN_DIR}/update-systemd-boot-snapshots"

# Install mkinitcpio hook if it exists
if [ -f "${SCRIPT_DIR}/mkinitcpio/systemd-boot-snapshots.hook" ]; then
    echo -e "${GREEN}Installing mkinitcpio hook...${NC}"
    mkdir -p /usr/lib/initcpio/hooks
    mkdir -p /usr/lib/initcpio/install
    cp -v "${SCRIPT_DIR}/mkinitcpio/systemd-boot-snapshots.hook" /usr/lib/initcpio/hooks/systemd-boot-snapshots
    cp -v "${SCRIPT_DIR}/mkinitcpio/systemd-boot-snapshots.install" /usr/lib/initcpio/install/systemd-boot-snapshots
fi

# Install dracut module if it exists
if [ -f "${SCRIPT_DIR}/dracut/module-setup.sh" ]; then
    echo -e "${GREEN}Installing dracut module...${NC}"
    mkdir -p /usr/lib/dracut/modules.d/90systemd-boot-snapshots
    cp -v "${SCRIPT_DIR}/dracut/"* /usr/lib/dracut/modules.d/90systemd-boot-snapshots/
fi

# Install default configuration file
echo -e "${GREEN}Installing configuration...${NC}"
if [ ! -f "${CONFIG_DIR}/systemd-boot-snapshots.conf" ]; then
    cp -v "${SCRIPT_DIR}/config/systemd-boot-snapshots.conf" "${CONFIG_DIR}/"
else
    echo -e "${YELLOW}Configuration file already exists, not overwriting.${NC}"
    echo -e "${YELLOW}Check ${SCRIPT_DIR}/config/systemd-boot-snapshots.conf for new options.${NC}"
fi

# Install documentation
echo -e "${GREEN}Installing documentation...${NC}"
# Copy README and other markdown files
if [ -f "${SCRIPT_DIR}/README.md" ]; then
    cp -v "${SCRIPT_DIR}/README.md" "${DOC_DIR}/"
fi
# Copy any additional documentation files
for doc in "${SCRIPT_DIR}"/*.md; do
    if [ -f "$doc" ] && [ "$(basename "$doc")" != "README.md" ]; then
        cp -v "$doc" "${DOC_DIR}/"
    fi
done

# Install license files
echo -e "${GREEN}Installing license...${NC}"
if [ -f "${SCRIPT_DIR}/LICENSE" ]; then
    cp -v "${SCRIPT_DIR}/LICENSE" "${LICENSE_DIR}/"
elif [ -f "${SCRIPT_DIR}/COPYING" ]; then
    cp -v "${SCRIPT_DIR}/COPYING" "${LICENSE_DIR}/"
fi

# Setup notification files if they exist
if [ -d "${SCRIPT_DIR}/notifications" ]; then
    echo -e "${GREEN}Installing notification files...${NC}"
    mkdir -p "${INSTALL_DIR}/notifications"
    cp -rv "${SCRIPT_DIR}/notifications/"* "${INSTALL_DIR}/notifications/"
fi

# Add systemd service for automatic updates if it exists
if [ -f "${SCRIPT_DIR}/systemd/systemd-boot-snapshots.service" ]; then
    echo -e "${GREEN}Installing systemd service...${NC}"
    mkdir -p /usr/lib/systemd/system
    cp -v "${SCRIPT_DIR}/systemd/systemd-boot-snapshots.service" /usr/lib/systemd/system/
    cp -v "${SCRIPT_DIR}/systemd/systemd-boot-snapshots.path" /usr/lib/systemd/system/
    systemctl daemon-reload
    systemctl enable systemd-boot-snapshots.path
    systemctl start systemd-boot-snapshots.path
fi

echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Update your initramfs:"
echo "   - For mkinitcpio: sudo mkinitcpio -P"
echo "   - For dracut: sudo dracut -f"
echo ""
echo "2. Update systemd-boot snapshots menu:"
echo "   sudo update-systemd-boot-snapshots"
echo ""
echo "3. Reboot to test the installation"
