#!/usr/bin/bash

pacman-key --init
pacman-key --populate archlinuxarm
sed -i -e "s/^CheckSpace/#CheckSpace/g" /etc/pacman.conf
pacman -Sy --ask=4 arch-install-scripts
pacstrap -cGM /mnt base linux-raspberrypi4 crda dhcpcd dialog haveged nano net-tools netctl openssh raspberrypi-bootloader raspberrypi-bootloader-x vi which wireless_tools wpa_supplicant
exit
