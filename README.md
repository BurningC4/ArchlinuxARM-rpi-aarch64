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
  base linux-raspberrypi4 raspberrypi-bootloader raspberrypi-bootloader-x crda dhcpcd dialog haveged nano net-tools netctl openssh parted vi which wireless_tools wpa_supplicant
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
  ExecStartPost=/usr/bin/systemctl disable resize2fs_once.service ; /usr/bin/rm -rf /etc/systemd/system/resize2fs_once.service /usr/lib/init_resize

  [Install]
  WantedBy=multi-user.target
  ```
  
  该文件会将 **root** 分区扩展至整张sd卡并在完成后将自身删除
  
  添加了 **/usr/lib/init_resize/init_resize.sh**
  
  ```
  #!/bin/sh
  
  reboot_pi () {
    umount /boot
    mount / -o remount,ro
    sync
    echo b > /proc/sysrq-trigger
    sleep 5
    exit 0
  }
  
  check_commands () {
    if ! command -v dialog > /dev/null; then
        echo "dialog not found"
        sleep 5
        return 1
    fi
    for COMMAND in grep cut sed parted fdisk findmnt; do
      if ! command -v $COMMAND > /dev/null; then
        FAIL_REASON="$COMMAND not found"
        return 1
      fi
    done
    return 0
  }
  
  get_variables () {
    ROOT_PART_DEV=$(findmnt / -o source -n)
    ROOT_PART_NAME=$(echo "$ROOT_PART_DEV" | cut -d "/" -f 3)
    ROOT_DEV_NAME=$(echo /sys/block/*/"${ROOT_PART_NAME}" | cut -d "/" -f 4)
    ROOT_DEV="/dev/${ROOT_DEV_NAME}"
    ROOT_PART_NUM=$(cat "/sys/block/${ROOT_DEV_NAME}/${ROOT_PART_NAME}/partition")
  
    BOOT_PART_DEV=$(findmnt /boot -o source -n)
    BOOT_PART_NAME=$(echo "$BOOT_PART_DEV" | cut -d "/" -f 3)
    BOOT_DEV_NAME=$(echo /sys/block/*/"${BOOT_PART_NAME}" | cut -d "/" -f 4)
  
    ROOT_DEV_SIZE=$(cat "/sys/block/${ROOT_DEV_NAME}/size")
    TARGET_END=$((ROOT_DEV_SIZE - 1))
  
    PARTITION_TABLE=$(parted -m "$ROOT_DEV" unit s print | tr -d 's')
  
    LAST_PART_NUM=$(echo "$PARTITION_TABLE" | tail -n 1 | cut -d ":" -f 1)
  
    ROOT_PART_LINE=$(echo "$PARTITION_TABLE" | grep -e "^${ROOT_PART_NUM}:")
    ROOT_PART_END=$(echo "$ROOT_PART_LINE" | cut -d ":" -f 3)
  }
  
  fix_partuuid() {
    mount -o remount,rw "$ROOT_PART_DEV"
    mount -o remount,rw "$BOOT_PART_DEV"
    DISKID="$(tr -dc 'a-f0-9' < /dev/hwrng | dd bs=1 count=8 2>/dev/null)"
    fdisk "$ROOT_DEV" > /dev/null <<EOF
  x
  i
  0x$DISKID
  r
  w
  EOF
  
    mount -o remount,ro "$ROOT_PART_DEV"
    mount -o remount,ro "$BOOT_PART_DEV"
  }
  
  check_variables () {
    if [ "$BOOT_DEV_NAME" != "$ROOT_DEV_NAME" ]; then
        FAIL_REASON="Boot and root partitions are on different devices"
        return 1
    fi
  
    if [ "$ROOT_PART_NUM" -ne "$LAST_PART_NUM" ]; then
      FAIL_REASON="Root partition should be last partition"
      return 1
    fi
  
    if [ "$ROOT_PART_END" -gt "$TARGET_END" ]; then
      FAIL_REASON="Root partition runs past the end of device"
      return 1
    fi
  
    if [ ! -b "$ROOT_DEV" ] || [ ! -b "$ROOT_PART_DEV" ] || [ ! -b "$BOOT_PART_DEV" ] ; then
      FAIL_REASON="Could not determine partitions"
      return 1
    fi
  }
  
  main () {
    get_variables
  
    if ! check_variables; then
      return 1
    fi
  
    if [ "$ROOT_PART_END" -eq "$TARGET_END" ]; then
      reboot_pi
    fi
  
    if ! parted -m "$ROOT_DEV" u s resizepart "$ROOT_PART_NUM" "$TARGET_END"; then
      FAIL_REASON="Root partition resize failed"
      return 1
    fi
  
    fix_partuuid
  
    return 0
  }
  
  mount -t proc proc /proc
  mount -t sysfs sys /sys
  mount -t tmpfs tmp /run
  mkdir -p /run/systemd
  
  mount /boot
  mount / -o remount,ro
  
  sed -i 's| init=/usr/lib/init_resize/init_resize\.sh||' /boot/cmdline.txt
  
  mount /boot -o remount,ro
  sync
  
  echo 1 > /proc/sys/kernel/sysrq
  
  if ! check_commands; then
    reboot_pi
  fi
  
  if main; then
    dialog --infobox "Resized root filesystem. Rebooting in 5 seconds..." 20 60
    sleep 5
  else
    dialog --msgbox "Could not expand filesystem.\n${FAIL_REASON}" 20 60
    sleep 5
  fi
  
  reboot_pi
  ```

 该文件在首次开机时通过 **cmdline.txt** 运行后会被 **resize2fs_once.service** 删除
 
 ## 使用方式

  **root** 的密码是 ```root```
  
  **alarm** 的密码是 ```alarm```
  
  默认没有安装 **sudo** ，所以通过 **ssh** 登录系统后需要 ```su``` 来获得 **root** 权限

