#!/usr/bin/bash

rm -rf mnt/etc/*- mnt/root/.bash_history mnt/root/.gnupg mnt/var/log/* mnt/var/lib/systemd/* 
tar -czf ./ArchLinuxARM-rpi-4-aarch64-latest.tar.gz -C mnt/ .
exit
