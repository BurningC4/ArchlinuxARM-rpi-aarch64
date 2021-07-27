# 简介
本项目用于每半月自动生成 **树莓派4B** 的 **ArchLinuxARM** **aarch64** 压缩档

## 下载地址

- **ArchLinuxARM-rpi-4-aarch64-latest.tar.gz**：
  - https://github.com/BurningC4/ArchlinuxARM-rpi4-aarch64-builder/raw/release/ArchLinuxARM-rpi-4-aarch64-latest.tar.gz
- **ArchLinuxARM-rpi-4-aarch64-latest.tar.gz.sha256sum**：
  - https://github.com/BurningC4/ArchlinuxARM-rpi4-aarch64-builder/raw/release/ArchLinuxARM-rpi-4-aarch64-latest.tar.gz.sha256sum

## 编译方法

```bash
git clone https://github.com/BurningC4/ArchlinuxARM-rpi4-aarch64-builder
cd ArchlinuxARM-rpi4-aarch64-builder
make package
```
文件会出现在 **release** 文件夹内
