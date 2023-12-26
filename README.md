# 简介
- 本项目用于每天自动生成 **树莓派** 的 **ArchLinuxARM** **aarch64** 系统镜像
- 生成的镜像包含树莓派官方的闭源固件

 ## 下载地址

- **ArchLinuxARM-rpi-aarch64-latest.img.zip**：
  - https://github.com/BurningC4/ArchlinuxARM-rpi-aarch64/releases/latest/download/ArchLinuxARM-rpi-aarch64-latest.img.zip
- **ArchLinuxARM-rpi-aarch64-latest.img.zip.sha256sum**：
  - https://github.com/BurningC4/ArchlinuxARM-rpi-aarch64/releases/latest/download/ArchLinuxARM-rpi-aarch64-latest.img.zip.sha256sum
- **ArchLinuxARM-rpi-aarch64-latest.tar.gz**：
  - https://github.com/BurningC4/ArchlinuxARM-rpi-aarch64/releases/latest/download/ArchLinuxARM-rpi-aarch64-latest.tar.gz
- **ArchLinuxARM-rpi-aarch64-latest.tar.gz.sha256sum**：
  - https://github.com/BurningC4/ArchlinuxARM-rpi-aarch64/releases/latest/download/ArchLinuxARM-rpi-aarch64-latest.tar.gz.sha256sum

 ## 安装了以下软件包及其依赖

  ```
  archlinuxarm-keyring base dhcpcd dialog linux-rpi nano net-tools netctl openssh raspberrypi-bootloader firmware-raspberrypi vi which wireless-regdb wireless_tools wpa_supplicant
  ```
  

 ## 启用了以下服务

  ```
  sshd systemd-networkd systemd-resolved systemd-timesyncd
  ```

  基本相当于官方 **rpi-aarch64** 镜像安装了 **linux-rpi**

  ### IMG文件的额外订制
  
  添加并启用了 **resize2fs_once.service**
  
  ```
  [Unit]
  Description=Resize the root filesystem to fill partition

  [Service]
  Type=oneshot
  ExecStart=/usr/local/bin/growpart /dev/mmcblk0 2 ; /usr/sbin/resize2fs /dev/mmcblk0p2
  ExecStartPost=/usr/bin/systemctl disable resize2fs_once.service ; /usr/bin/rm -rf /etc/systemd/system/resize2fs_once.service /usr/local/bin/growpart

  [Install]
  WantedBy=multi-user.target
  ```
  
  该文件会将 **root** 分区扩展至整张sd卡并在完成后将自身删除
  
  添加了来自 **cloud-guest-utils** 的 **growpart** ，该文件在首次开机时被 **resize2fs_once.service** 使用后删除
 
 ## 使用方式

  **root** 的密码是 ```root```
  
  **alarm** 的密码是 ```alarm```
  
  默认没有安装 **sudo** ，所以通过 **ssh** 登录系统后需要 ```su``` 来获得 **root** 权限

