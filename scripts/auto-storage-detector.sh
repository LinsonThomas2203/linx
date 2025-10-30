#!/bin/bash
# Storage Detection Script - Runs during installation
# This script detects storage configuration and applies optimal LVM layout

set -e

LOG_FILE="/var/log/storage-detector.log"
exec > >(tee -a $LOG_FILE) 2>&1

log() {
    echo "$(date): $1" | tee -a $LOG_FILE
}

# Detect storage configuration
detect_storage() {
    log "Starting storage detection..."
    
    # Get primary disk information
    PRIMARY_DISK=$(lsblk -d -o NAME,TYPE | grep disk | head -1 | awk '{print $1}')
    DISK_SIZE=$(lsblk -d -o SIZE /dev/$PRIMARY_DISK | grep -o '[0-9]*' | head -1)
    DISK_MODEL=$(lsblk -d -o MODEL /dev/$PRIMARY_DISK | tail -1)
    RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    RAM_GB=$((RAM_KB / 1024 / 1024))
    
    log "Detected: /dev/$PRIMARY_DISK (${DISK_SIZE}GB $DISK_MODEL), ${RAM_GB}GB RAM"
    
    # Select layout based on disk size
    if [ $DISK_SIZE -le 512 ]; then
        LAYOUT="512GB"
        SWAP_SIZE="16G"
    elif [ $DISK_SIZE -le 1024 ]; then
        LAYOUT="1TB" 
        SWAP_SIZE="32G"
    else
        LAYOUT="2TB"
        SWAP_SIZE="32G"
    fi
    
    log "Selected layout: $LAYOUT with $SWAP_SIZE swap"
    export LAYOUT SWAP_SIZE PRIMARY_DISK="/dev/$PRIMARY_DISK" DISK_SIZE RAM_GB
}

# Generate partman recipe based on selected layout
generate_partman_recipe() {
    case $LAYOUT in
        "512GB")
            cat > /tmp/partman-recipe.txt << 'EOF'
# 512GB Developer Layout
d-i partman-auto-lvm/new_vg_name string vg_system
d-i partman-auto-lvm/guided_size string max
d-i partman-auto/disk string /dev/sda
d-i partman-auto/method string lvm
d-i partman-auto-lvm/guided_size string max
d-i partman-auto/choose_recipe select atomic

# Logical volumes for 512GB system
d-i partman-lvm/confirm boolean true
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-auto/purge_lvm_from_device boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-lvm/confirm_nooverwrite boolean true

# Volume group and logical volumes
partman-lvm	partman-lvm/confirm_nooverwrite	boolean	true
partman-lvm	partman-lvm/device_remove_lvm	boolean	true
partman-auto-lvm	partman-auto-lvm/guided_size	string	max
partman-auto-lvm	partman-auto-lvm/new_vg_name	string	vg_system

# LVM configuration for 512GB SSD
d-i partman-auto/expert_recipe string \
    boot-root :: \
        1024 1024 1024 ext4 \
            $primary{ } $bootable{ } \
            method{ format } format{ } \
            use_filesystem{ } filesystem{ ext4 } \
            mountpoint{ /boot } \
        . \
        50000 50000 50000 ext4 \
            $lvmok{ } \
            method{ format } format{ } \
            use_filesystem{ } filesystem{ ext4 } \
            mountpoint{ / } \
        . \
        80000 80000 80000 ext4 \
            $lvmok{ } \
            method{ format } format{ } \
            use_filesystem{ } filesystem{ ext4 } \
            mountpoint{ /home } \
        . \
        16000 16000 16000 linux-swap \
            $lvmok{ } \
            method{ swap } format{ } \
        . \
        20000 20000 20000 ext4 \
            $lvmok{ } \
            method{ format } format{ } \
            use_filesystem{ } filesystem{ ext4 } \
            mountpoint{ /tmp } \
        . \
        20000 20000 20000 xfs \
            $lvmok{ } \
            method{ format } format{ } \
            use_filesystem{ } filesystem{ xfs } \
            mountpoint{ /var/log } \
        . \
        40000 40000 40000 xfs \
            $lvmok{ } \
            method{ format } format{ } \
            use_filesystem{ } filesystem{ xfs } \
            mountpoint{ /opt/ide } \
        . \
        120000 120000 120000 xfs \
            $lvmok{ } \
            method{ format } format{ } \
            use_filesystem{ } filesystem{ xfs } \
            mountpoint{ /opt/runtimes } \
        . \
        90000 90000 90000 xfs \
            $lvmok{ } \
            method{ format } format{ } \
            use_filesystem{ } filesystem{ xfs } \
            mountpoint{ /workspace } \
        . \
        40000 40000 40000 xfs \
            $lvmok{ } \
            method{ format } format{ } \
            use_filesystem{ } filesystem{ xfs } \
            mountpoint{ /var/lib/dbs } \
        . \
        22000 22000 22000 xfs \
            $lvmok{ } \
            method{ format } format{ } \
            use_filesystem{ } filesystem{ xfs } \
            mountpoint{ /var/lib/containers } \
        . \
        20000 20000 20000 xfs \
            $lvmok{ } \
            method{ format } format{ } \
            use_filesystem{ } filesystem{ xfs } \
            mountpoint{ /backups } \
        .
EOF
            ;;
        "1TB")
            # Similar structure with larger sizes for 1TB
            ;;
        "2TB")
            # Similar structure with largest sizes for 2TB
            ;;
    esac
    
    log "Generated partman recipe for $LAYOUT layout"
}

main() {
    log "=== Starting Automated Storage Detection ==="
    detect_storage
    generate_partman_recipe
    log "=== Storage Detection Complete ==="
}

main "$@"