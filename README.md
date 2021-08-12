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

 ## 安装了以下软件包及其依赖

  ```
  base linux-raspberrypi4 raspberrypi-bootloader raspberrypi-bootloader-x crda dhcpcd dialog haveged nano net-tools netctl openssh vi which wireless_tools wpa_supplicant
  ```

 ## 启用了以下服务

  ```
  haveged sshd systemd-networkd systemd-resolved systemd-timesyncd
  ```

  基本相当于官方 **rpi-aarch64** 镜像安装了 **linux-raspberrypi4** 和 **raspberrypi-bootloader-x**
  
  ### IMG文件的额外订制
  
  添加并启用了 **resize2fs_once.service**
  
  ```
  [Unit]
  Description=Resize the root filesystem to fill partition

  [Service]
  Type=oneshot
  ExecStart=/usr/bin/bash -c "/usr/sbin/resize2fs `/usr/bin/findmnt / -o source -n`"
  ExecStartPost=/usr/bin/systemctl disable resize2fs_once.service ; /usr/bin/rm /lib/systemd/system/resize2fs_once.service

  [Install]
  WantedBy=multi-user.target
  ```
  
  该文件会将 **root** 分区扩展至整张sd卡并在完成后将自身删除

 ## 使用方式

  **root** 的密码是 ```root```
  
  **alarm** 的密码是 ```alarm```
  
  默认没有安装 **sudo** ，所以通过 **ssh** 登录系统后需要 ```su``` 来获得 **root** 权限

