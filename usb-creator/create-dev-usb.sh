#!/bin/bash
# Create Developer Installation USB

set -e

ISO_URL="http://releases.ubuntu.com/22.04/ubuntu-22.04.3-desktop-amd64.iso"
WORK_DIR="/tmp/ubuntu-dev-usb"
MOUNT_DIR="/mnt/iso"
OUTPUT_ISO="ubuntu-dev-installer.iso"

echo "=== Creating Developer Installation USB ==="

# Download Ubuntu ISO if not present
if [ ! -f "ubuntu-22.04.3-desktop-amd64.iso" ]; then
    echo "Downloading Ubuntu ISO..."
    wget $ISO_URL
fi

# Create working directories
mkdir -p $WORK_DIR $MOUNT_DIR

# Mount ISO and copy contents
echo "Extracting ISO contents..."
sudo mount -o loop ubuntu-22.04.3-desktop-amd64.iso $MOUNT_DIR
cp -rT $MOUNT_DIR $WORK_DIR
sudo umount $MOUNT_DIR

# Copy our custom files
echo "Adding custom installation scripts..."
cp -r preseed/ $WORK_DIR/preseed/
cp -r scripts/ $WORK_DIR/scripts/
cp -r configs/ $WORK_DIR/configs/

# Modify GRUB configuration
echo "Configuring GRUB boot menu..."
cp boot/grub/grub.cfg $WORK_DIR/boot/grub/grub.cfg

# Repackage as new ISO
echo "Creating custom ISO..."
sudo grub-mkrescue -o $OUTPUT_ISO $WORK_DIR

echo "Custom ISO created: $OUTPUT_ISO"
echo "Create USB with: sudo dd if=$OUTPUT_ISO of=/dev/sdX status=progress"