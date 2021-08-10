#!/usr/bin/bash

pacman -Syu --ask=4 arch-install-scripts
pacstrap -cGM /mnt base linux-raspberrypi4 crda dhcpcd dialog haveged nano net-tools netctl openssh raspberrypi-bootloader raspberrypi-bootloader-x vi which wireless_tools wpa_supplicant
exit
