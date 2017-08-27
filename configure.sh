#!/bin/bash
# Note - this script assumes that the system has been installed & the root fs
# is available at /mnt.

run_in_chroot() {
  local command="$@"
  arch-chroot /mnt $command
}

gen_fstab() {
  genfstab -U /mnt >> /mnt/etc/fstab
}

configure_timezone() {
  # set time to GMT
  run_in_chroot ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
  run_in_chroot hwclock --systohc
}

configure_locales() {
  # generate locales
  run_in_chroot echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen
  run_in_chroot echo "en_GB ISO-8859-1" >> /etc/locale.gen
  run_in_chroot echo "LANG=en_GB.UTF-8" >> /etc/locale.conf

  run_in_chroot locale-gen
}

configure_keyboard() {
  echo "KEYMAP=uk" | run_in_chroot tee -a /etc/vconsole.conf
}

set_hostname() {
  echo "arch-linux" | run_in_chroot tee /etc/hostname
}

enable_dhcpcd() {
  run_in_chroot systemctl enable dhcpcd.service
}

enable_sshd() {
  run_in_chroot systemctl enable sshd.service
  sed -i 's/#PermitRootLogin .*/PermitRootLogin yes/g' '/mnt/etc/ssh/sshd_config'
  sed -i 's/#PasswordAuthentication .*/PasswordAuthentication yes/g' '/mnt/etc/ssh/sshd_config'
}

configure_mirrors() {
  mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.all
  sed -i 's/^#Server/Server/g' /etc/pacman.d/mirrorlist.all
  rankmirrors -n 3 /etc/pacman.d/mirrorlist.all > /etc/pacman.d/mirrorlist
  grep --no-group-separator -A1 'United Kingdom' \
    /etc/pacman.d/mirrorlist.all >> /etc/pacman.d/mirrorlist
}

set_root_password() {
  password="$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c16)"
  echo "root:${password}" | run_in_chroot chpasswd
  echo "root password for new build is ${password}"
}

gen_fstab

configure_timezone
configure_locales
configure_keyboard
set_hostname
enable_dhcpcd
enable_sshd
configure_mirrors
set_root_password