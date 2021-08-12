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

  ### 安装了以下软件包及其依赖

  ```base linux-raspberrypi4 raspberrypi-bootloader raspberrypi-bootloader-x crda dhcpcd dialog haveged nano net-tools netctl openssh vi which wireless_tools wpa_supplicant```

  ### 启用了以下服务

  ```haveged sshd systemd-networkd systemd-resolved systemd-timesyncd```

  基本相当于官方 **rpi-aarch64** 镜像安装了 **linux-raspberrypi4** 和 **raspberrypi-bootloader-x**

 ## 使用方式

  **root** 的密码是 ```root```
  
  **alarm** 的密码是 ```alarm```
  
  默认没有安装 **sudo** ，所以通过 **ssh** 登录系统后需要 ```su``` 来获得 **root** 权限

