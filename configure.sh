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
  echo "en_GB.UTF-8 UTF-8" | run_in_chroot tee -a /etc/locale.gen > /dev/null
  echo "en_GB ISO-8859-1"  | run_in_chroot tee -a /etc/locale.gen > /dev/null
  echo "LANG=en_GB.UTF-8"  | run_in_chroot tee -a /etc/locale.conf > /dev/null

  run_in_chroot locale-gen
}

configure_keyboard() {
  echo "KEYMAP=uk" | run_in_chroot tee -a /etc/vconsole.conf > /dev/null
}

set_hostname() {
  echo "arch-linux" | run_in_chroot tee /etc/hostname > /dev/null
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
  echo 'Configuring Pacman mirrors...'
  mv /mnt/etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist.all
  sed -i 's/^#Server/Server/g' /mnt/etc/pacman.d/mirrorlist.all
  rankmirrors -n 3 /mnt/etc/pacman.d/mirrorlist.all > /mnt/etc/pacman.d/mirrorlist
  grep --no-group-separator -A1 'United Kingdom' \
    /mnt/etc/pacman.d/mirrorlist.all >> /mnt/etc/pacman.d/mirrorlist
}

set_root_password() {
  if [ -n "$ROOT_PASSWORD" ]; then
    local password="$ROOT_PASSWORD"
  else
    local password="$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c16)"
  fi
  echo "root:${password}" | run_in_chroot chpasswd
  echo "root password for new build is ${password}"
}

create_nopasswd_group() {
  run_in_chroot groupadd nopasswd
  echo "%nopasswd       ALL=NOPASSWD: ALL" | \
    run_in_chroot tee -a /etc/sudoers.d/nopasswd > /dev/null
}

create_vagrant_user() {
  run_in_chroot groupadd vagrant
  run_in_chroot useradd -m -g vagrant -s /bin/bash vagrant
  run_in_chroot usermod -a -G nopasswd vagrant
  if [ -f /tmp/insecure_public_key ]; then
    run_in_chroot mkdir -p /home/vagrant/.ssh
    cat /tmp/insecure_public_key | run_in_chroot tee -a /home/vagrant/.ssh/authorized_keys > /dev/null
    run_in_chroot chown -R vagrant: /home/vagrant/.ssh
    run_in_chroot chmod 600 /home/vagrant/.ssh/authorized_keys
    rm /tmp/insecure_public_key
  else
    echo "Cannot create vagrant user: no insecure public key has been provided!"
    return 1
  fi
}

configure_non_minimal() {
  echo 'Performing non-minimal configuration'
  configure_mirrors
}

configure_for_packer_build() {
  gen_fstab
  configure_timezone
  configure_locales
  configure_keyboard
  set_hostname
  enable_dhcpcd
  if [ -z "$MINIMAL_CONFIGURATION" ]; then
    configure_non_minimal
  else
    echo 'Skipping non-minimal configuration'
  fi
  enable_sshd
  set_root_password
  create_nopasswd_group
  create_vagrant_user
}

configure_for_other_build() {
  gen_fstab
  configure_timezone
  configure_locales
  configure_keyboard
  set_hostname
  enable_dhcpcd
  if [ -z "$MINIMAL_CONFIGURATION" ]; then
    configure_non_minimal
  else
    echo 'Skipping non-minimal configuration'
  fi
  set_root_password
  create_nopasswd_group
}

# If we're building with packer
if [ -n "$PACKER_BUILD_NAME" ]; then
  configure_for_packer_build
else
  configure_for_other_build
fi
