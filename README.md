# 简介
本项目用于每天自动生成 **树莓派4B** 的 **ArchLinuxARM** **aarch64** 系统镜像

## 下载地址

- **ArchLinuxARM-rpi-4-aarch64-latest.img.zip**：
  - https://github.com/BurningC4/ArchlinuxARM-rpi4-aarch64-builder/releases/latest/download/ArchLinuxARM-rpi-4-aarch64-latest.img.zip
- **ArchLinuxARM-rpi-4-aarch64-latest.img.zip.sha256sum**：
  - https://github.com/BurningC4/ArchlinuxARM-rpi4-aarch64-builder/releases/latest/download/ArchLinuxARM-rpi-4-aarch64-latest.img.zip.sha256sum
- **ArchLinuxARM-rpi-4-aarch64-latest.tar.gz**：
  - https://github.com/BurningC4/ArchlinuxARM-rpi4-aarch64-builder/releases/latest/download/ArchLinuxARM-rpi-4-aarch64-latest.tar.gz
- **ArchLinuxARM-rpi-4-aarch64-latest.tar.gz.sha256sum**：
  - https://github.com/BurningC4/ArchlinuxARM-rpi4-aarch64-builder/releases/latest/download/ArchLinuxARM-rpi-4-aarch64-latest.tar.gz.sha256sum

## 生成的镜像安装了以下软件包及其依赖

```
base linux-raspberrypi4 raspberrypi-bootloader raspberrypi-bootloader-x crda dhcpcd dialog haveged nano net-tools netctl openssh vi which wireless_tools wpa_supplicant
```
基本相当于官方 **rpi-aarch64** 镜像安装了 **linux-raspberrypi4** 和 **raspberrypi-bootloader-x**
