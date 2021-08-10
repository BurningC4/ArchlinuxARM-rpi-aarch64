#!/usr/bin/bash

arch-chroot ./mnt /usr/bin/systemctl enable sshd systemd-networkd systemd-resolved systemd-timesyncd haveged
arch-chroot ./mnt /usr/bin/echo -e '[Match]\nName=en*\n\n[Network]\nDHCP=yes\nDNSSEC=no'>/etc/systemd/network/en.network
arch-chroot ./mnt /usr/bin/echo -e '[Match]\nName=eth*\n\n[Network]\nDHCP=yes\nDNSSEC=no'>/etc/systemd/network/eth.network
arch-chroot ./mnt /usr/bin/echo '/dev/mmcblk0p1  /boot   vfat    defaults        0       0'>>/etc/fstab
arch-chroot ./mnt /usr/bin/echo 'alarm'>/etc/hostname
arch-chroot ./mnt /usr/bin/echo 'LANG=C'>/etc/locale.conf
arch-chroot ./mnt /usr/bin/echo "root:root" | chpasswd
arch-chroot ./mnt /usr/bin/useradd -d /home/alarm -m -U -p `openssl passwd -6 alarm` alarm
arch-chroot ./mnt /usr/bin/rm /etc/resolv.conf
arch-chroot ./mnt /usr/bin/ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
exit