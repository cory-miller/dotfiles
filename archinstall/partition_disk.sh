#!/usr/bin/env bash

set -eo pipefail

DISK="$1"

if [ -z "$DISK" ]; then
  echo "Error: No disk specified."
  echo "Usage: $0 /dev/sdX  OR  $0 /dev/nvmeXnY"
  echo "Available disks:"
  lsblk -d -o NAME,SIZE,TYPE,MODEL | grep disk
  exit 1
fi

if [ ! -b "$DISK" ]; then
  echo "Error: Block device '$DISK' does not exist."
  exit 1
fi

echo "============================================================"
echo " WARNING: THIS WILL ERASE ALL DATA ON $DISK"
echo "============================================================"
read -p "Are you sure you want to proceed? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

# Determine partition naming convention (e.g., /dev/nvme0n1 vs /dev/sda)
if [[ "$DISK" =~ [0-9]$ ]]; then
    PART_PREFIX="${DISK}p"
else
    PART_PREFIX="${DISK}"
fi

BOOT_PART="${PART_PREFIX}1"
SWAP_PART="${PART_PREFIX}2"
ROOT_PART="${PART_PREFIX}3"

echo "==> Unmounting existing mounts on $DISK..."
umount -R /mnt 2>/dev/null || true
swapoff -a 2>/dev/null || true

echo "==> Wiping filesystem signatures..."
wipefs -a "$DISK"
sgdisk --zap-all "$DISK"

echo "==> Creating Partition Table (GPT)..."
sgdisk -n 1:0:+1G -t 1:ef00 -c 1:"EFI System Partition" "$DISK"
sgdisk -n 2:0:+16G -t 2:8200 -c 2:"Linux Swap" "$DISK"
sgdisk -n 3:0:0 -t 3:8304 -c 3:"Linux Root" "$DISK"

# Force kernel to reload partition table
partprobe "$DISK"
sleep 2

echo "==> Formatting Partitions..."
mkfs.vfat -F 32 -n "EFI" "$BOOT_PART"
mkswap -L "SWAP" "$SWAP_PART"
mkfs.ext4 -F -L "ROOT" "$ROOT_PART"

echo "==> Mounting Partitions to /mnt..."
mount "$ROOT_PART" /mnt
mkdir -p /mnt/boot
mount "$BOOT_PART" /mnt/boot
swapon "$SWAP_PART"

echo "==> Disk partitioning complete! Mount layout:"
lsblk -o NAME,FSTYPE,LABEL,SIZE,MOUNTPOINTS "$DISK"

