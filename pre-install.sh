#!/bin/bash

if [ -n "$ARCH_INSTALL_DISK" ]; then
  target_volume="$ARCH_INSTALL_DISK"
else
  target_volume='/dev/sda'
fi

create_disk() {
  parted -s "$target_volume" mklabel msdos \
    mkpart primary 512KiB 300MiB set 1 boot on \
    mkpart primary 300MiB 10% \
    mkpart primary 10% 25% \
    mkpart primary 25% 100%

  mkfs.ext2 "${target_volume}1"
  mkfs.ext4 "${target_volume}2"
  mkfs.ext4 "${target_volume}3"
  mkfs.ext4 "${target_volume}4"
}

# sync-up time
echo "enabling ntp..."
timedatectl set-ntp true

echo "creating disk..."
create_disk

echo "mounting filesystems..."
mount "${target_volume}2" /mnt
mkdir /mnt/var
mount "${target_volume}3" /mnt/var
mkdir /mnt/home
mount "${target_volume}4" /mnt/home
mkdir /mnt/boot
mount "${target_volume}1" /mnt/boot
