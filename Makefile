# ========================================================================== #
#                                                                            #
#    pi-builder - extensible tool to build Arch Linux ARM for Raspberry Pi   #
#                 on x86_64 host using Docker.                               #
#                                                                            #
#    Copyright (C) 2019  Maxim Devaev <mdevaev@gmail.com>                    #
#                                                                            #
#    This program is free software: you can redistribute it and/or modify    #
#    it under the terms of the GNU General Public License as published by    #
#    the Free Software Foundation, either version 3 of the License, or       #
#    (at your option) any later version.                                     #
#                                                                            #
#    This program is distributed in the hope that it will be useful,         #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of          #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           #
#    GNU General Public License for more details.                            #
#                                                                            #
#    You should have received a copy of the GNU General Public License       #
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.  #
#                                                                            #
# ========================================================================== #


-include config.mk

PROJECT ?= common
STAGES ?= __init__ os __cleanup__

HOSTNAME ?= alarm
LOCALE ?= en_US
TIMEZONE ?= UTC
REPO_URL = http://mirror.archlinuxarm.org
BUILD_OPTS ?=

CARD ?= /dev/loop0
CARD_DATA_FS_TYPE ?=
CARD_DATA_FS_FLAGS ?=
CARD_DATA_BEGIN_AT ?= 4352MiB

QEMU_PREFIX ?= /usr
QEMU_RM ?= 1


# =====
_IMAGES_PREFIX = pi-builder-aarch64
_TOOLBOX_IMAGE = $(_IMAGES_PREFIX)-toolbox

_TMP_DIR = ./.tmp
_BUILD_DIR = ./.build
_BUILDED_IMAGE_CONFIG = ./.builded.conf

_QEMU_STATIC_BASE_URL = https://deb.debian.org/debian/pool/main/q/qemu
_QEMU_COLLECTION = qemu
_QEMU_STATIC = $(_QEMU_COLLECTION)/qemu-aarch64-static
_QEMU_STATIC_GUEST_PATH ?= $(QEMU_PREFIX)/bin/qemu-aarch64-static

_RPI_ROOTFS_URL = $(REPO_URL)/os/ArchLinuxARM-rpi-aarch64-latest.tar.gz
_RPI_BASE_ROOTFS_TGZ = $(_TMP_DIR)/base-rootfs-rpi4.tar.gz
_RPI_BASE_IMAGE = $(_IMAGES_PREFIX)-base-rpi4
_RPI_RESULT_IMAGE = $(PROJECT)-$(_IMAGES_PREFIX)-result-rpi4
_RPI_RESULT_ROOTFS_TAR = $(_TMP_DIR)/result-rootfs.tar
_RPI_RESULT_ROOTFS = $(_TMP_DIR)/result-rootfs

_CARD_P = $(if $(findstring mmcblk,$(CARD)),p,$(if $(findstring loop,$(CARD)),p,))
_CARD_BOOT = $(CARD)$(_CARD_P)1
_CARD_ROOTFS = $(CARD)$(_CARD_P)2


# =====
define optbool
$(filter $(shell echo $(1) | tr A-Z a-z),yes on 1)
endef

define say
@ tput -Txterm bold
@ tput -Txterm setaf 2
@ echo "===== $1 ====="
@ tput -Txterm sgr0
endef

define die
@ tput -Txterm bold
@ tput -Txterm setaf 1
@ echo "===== $1 ====="
@ tput -Txterm sgr0
@ exit 1
endef

define read_builded_config
$(shell grep "^$(1)=" $(_BUILDED_IMAGE_CONFIG) | cut -d"=" -f2)
endef

define show_running_config
$(call say,"Running configuration")
@ echo "    PROJECT = $(PROJECT)"
@ echo "    STAGES  = $(STAGES)"
@ echo
@ echo "    BUILD_OPTS = $(BUILD_OPTS)"
@ echo "    HOSTNAME   = $(HOSTNAME)"
@ echo "    REPO_URL   = $(REPO_URL)"
@ echo
@ echo "    CARD = $(CARD)"
@ echo
@ echo "    QEMU_PREFIX = $(QEMU_PREFIX)"
@ echo "    QEMU_RM     = $(QEMU_RM)"
endef

define check_build
$(if $(wildcard $(_BUILDED_IMAGE_CONFIG)),,$(call die,"Not built yet"))
endef


# =====
__DEP_BINFMT := $(if $(call optbool,$(PASS_ENSURE_BINFMT)),,binfmt)
__DEP_TOOLBOX := $(if $(call optbool,$(PASS_ENSURE_TOOLBOX)),,toolbox)


# =====
all:
	@ echo
	$(call say,"Available commands")
	@ echo "    make                     # Print this help"
	@ echo "    make shell               # Run Arch-ARM shell"
	@ echo "    make toolbox             # Build the toolbox image"
	@ echo "    make binfmt              # Configure ARM binfmt on the host system"
	@ echo "    make clean               # Remove the generated rootfs"
	@ echo "    make format              # Format $(CARD)"
	@ echo "    make install             # Install rootfs to partitions on $(CARD)"
	@ echo "    make package             # Package image"
	@ echo
	$(call show_running_config)
	@ echo


rpi rpi2 rpi3 rpi4 zero zerow generic: os


run: $(__DEP_BINFMT)
	$(call check_build)
	docker run \
			--rm \
			--tty \
			--hostname $(call read_builded_config,HOSTNAME) \
			$(if $(RUN_CMD),$(RUN_OPTS),--interactive) \
		$(call read_builded_config,IMAGE) \
		$(if $(RUN_CMD),$(RUN_CMD),/bin/bash)


shell: override RUN_OPTS:="$(RUN_OPTS) -i"
shell: run


toolbox:
	$(call say,"Ensuring toolbox image")
	docker build \
			--rm \
			--tag $(_TOOLBOX_IMAGE) \
			$(if $(TAG),--tag $(TAG),) \
			--file toolbox/Dockerfile.root \
		toolbox
	$(call say,"Toolbox image is ready")


binfmt: $(__DEP_TOOLBOX)
	$(call say,"Ensuring aarch64 binfmt")
	docker run \
			--rm \
			--tty \
			--privileged \
		$(_TOOLBOX_IMAGE) /tools/install-binfmt \
			--mount \
			aarch64 \
			$(_QEMU_STATIC_GUEST_PATH)
	$(call say,"Binfmt aarch64 is ready")


os: $(__DEP_BINFMT) _buildctx
	$(call say,"Building OS")
	rm -f $(_BUILDED_IMAGE_CONFIG)
	docker build \
			--rm \
			--tag $(_RPI_RESULT_IMAGE) \
			$(if $(TAG),--tag $(TAG),) \
			$(if $(call optbool,$(NC)),--no-cache,) \
			--build-arg "REPO_URL=$(REPO_URL)" \
			--build-arg "REBUILD=$(shell uuidgen)" \
			$(BUILD_OPTS) \
		$(_BUILD_DIR)
	echo "IMAGE=$(_RPI_RESULT_IMAGE)" > $(_BUILDED_IMAGE_CONFIG)
	echo "HOSTNAME=$(HOSTNAME)" >> $(_BUILDED_IMAGE_CONFIG)
	$(call show_running_config)
	$(call say,"Build complete")


# =====
_buildctx: _rpi_base_rootfs_tgz
	$(call say,"Assembling main Dockerfile")
	rm -rf $(_BUILD_DIR)
	mkdir -p $(_BUILD_DIR)
	ln $(_RPI_BASE_ROOTFS_TGZ) $(_BUILD_DIR)/$(PROJECT)-$(_IMAGES_PREFIX)-base-rootfs-rpi4.tgz
	cp $(_QEMU_STATIC) $(_BUILD_DIR)
	cp -r stages $(_BUILD_DIR)
	sed -i \
			-e 's|%BASE_ROOTFS_TGZ%|$(PROJECT)-$(_IMAGES_PREFIX)-base-rootfs-rpi4.tgz|g' \
			-e 's|%QEMU_GUEST_ARCH%|aarch64|g' \
			-e 's|%QEMU_STATIC_GUEST_PATH%|$(_QEMU_STATIC_GUEST_PATH)|g ' \
		$(_BUILD_DIR)/stages/__init__/Dockerfile.part
	echo -n > $(_BUILD_DIR)/Dockerfile
	for stage in $(STAGES); do \
		cat $(_BUILD_DIR)/stages/$$stage/Dockerfile.part >> $(_BUILD_DIR)/Dockerfile; \
	done
	$(call say,"Main Dockerfile is ready")


_rpi_base_rootfs_tgz:
	$(call say,"Ensuring base rootfs")
	if [ ! -e $(_RPI_BASE_ROOTFS_TGZ) ]; then \
		mkdir -p $(_TMP_DIR) \
		&& curl -L -f $(_RPI_ROOTFS_URL) -z $(_RPI_BASE_ROOTFS_TGZ) -o $(_RPI_BASE_ROOTFS_TGZ) \
	; fi
	$(call say,"Base rootfs is ready")


$(_QEMU_COLLECTION):
	$(call say,"Downloading QEMU")
	# Using i386 QEMU because of this:
	#   - https://bugs.launchpad.net/qemu/+bug/1805913
	#   - https://lkml.org/lkml/2018/12/27/155
	#   - https://stackoverflow.com/questions/27554325/readdir-32-64-compatibility-issues
	mkdir -p $(_TMP_DIR)/qemu-user-static-deb
	curl -L -f $(_QEMU_STATIC_BASE_URL)/`curl -s -S -L -f $(_QEMU_STATIC_BASE_URL)/ \
			-z $(_TMP_DIR)/qemu-user-static-deb/qemu-user-static.deb \
				| grep qemu-user-static \
				| grep _$(if $(filter-out aarch64,aarch64),i386,amd64).deb \
				| sort -n \
				| tail -n 1 \
				| sed -n 's/.*href="\([^"]*\).*/\1/p'` \
		-o $(_TMP_DIR)/qemu-user-static-deb/qemu-user-static.deb \
		-z $(_TMP_DIR)/qemu-user-static-deb/qemu-user-static.deb
	cd $(_TMP_DIR)/qemu-user-static-deb \
		&& ar vx qemu-user-static.deb \
		&& tar -xJf data.tar.xz
	rm -rf $(_QEMU_COLLECTION).tmp
	mkdir $(_QEMU_COLLECTION).tmp
	cp $(_TMP_DIR)/qemu-user-static-deb/usr/bin/qemu-aarch64-static $(_QEMU_COLLECTION).tmp
	mv $(_QEMU_COLLECTION).tmp $(_QEMU_COLLECTION)
	$(call say,"QEMU ready")


# =====
clean:
	rm -rf $(_BUILD_DIR) $(_BUILDED_IMAGE_CONFIG)


__DOCKER_RUN_TMP = docker run \
		--rm \
		--tty \
		--volume $(shell pwd)/$(_TMP_DIR):/root/$(_TMP_DIR) \
		--workdir /root/$(_TMP_DIR)/.. \
	$(_TOOLBOX_IMAGE)


__DOCKER_RUN_TMP_PRIVILEGED = docker run \
		--rm \
		--tty \
		--privileged \
		--name=result \
		--volume $(shell pwd)/$(_TMP_DIR):/root/$(_TMP_DIR) \
		--workdir /root/$(_TMP_DIR)/.. \
	$(_TOOLBOX_IMAGE)


clean-all: $(__DEP_TOOLBOX) clean
	$(__DOCKER_RUN_TMP) rm -rf $(_RPI_RESULT_ROOTFS)
	rm -rf $(_TMP_DIR)


format: $(__DEP_TOOLBOX)
	$(call check_build)
	$(call say,"Formatting $(CARD)")
	$(__DOCKER_RUN_TMP_PRIVILEGED) bash -c " \
		set -x \
		&& set -e \
		&& dd if=/dev/zero of=$(CARD) bs=1M count=32 \
		&& partprobe $(CARD) \
	"
	$(__DOCKER_RUN_TMP_PRIVILEGED) bash -c " \
		set -x \
		&& set -e \
		&& parted $(CARD) -s mklabel msdos \
		&& parted $(CARD) -a optimal -s mkpart primary fat32 $(if $(findstring generic,rpi4),32MiB,0) 256MiB \
		&& parted $(CARD) -a optimal -s mkpart primary ext4 256MiB 100% \
		&& partprobe $(CARD) \
	"
	$(__DOCKER_RUN_TMP_PRIVILEGED) bash -c " \
		set -x \
		&& set -e \
		&& yes | mkfs.vfat $(_CARD_BOOT) \
		&& yes | mkfs.ext4 $(_CARD_ROOTFS) \
	"
	$(call say,"Format complete")


extract: os $(__DEP_TOOLBOX)
	$(call check_build)
	$(call say,"Extracting image from Docker")
	$(__DOCKER_RUN_TMP) rm -rf $(_RPI_RESULT_ROOTFS)
	docker save --output $(_RPI_RESULT_ROOTFS_TAR) $(call read_builded_config,IMAGE)
	$(__DOCKER_RUN_TMP) /tools/docker-extract --root $(_RPI_RESULT_ROOTFS) $(_RPI_RESULT_ROOTFS_TAR)
	$(__DOCKER_RUN_TMP) bash -c " \
		echo $(call read_builded_config,HOSTNAME) > $(_RPI_RESULT_ROOTFS)/etc/hostname \
		&& (test -z '$(call optbool,$(QEMU_RM))' || rm $(_RPI_RESULT_ROOTFS)/$(_QEMU_STATIC_GUEST_PATH)) \
	"
	$(call say,"Extraction complete")


install: extract format
	$(call say,"Installing to $(CARD)")
	$(__DOCKER_RUN_TMP_PRIVILEGED) bash -c " \
		mkdir -p mnt/boot mnt/rootfs \
		&& mount $(_CARD_BOOT) mnt/boot \
		&& mount $(_CARD_ROOTFS) mnt/rootfs \
		&& rsync -a --info=progress2 $(_RPI_RESULT_ROOTFS)/boot/* mnt/boot \
		&& rsync -a --info=progress2 $(_RPI_RESULT_ROOTFS)/* mnt/rootfs --exclude boot \
		&& mkdir mnt/rootfs/boot \
		&& umount mnt/boot mnt/rootfs \
	"
	$(call say,"Installation complete")


package: extract
	$(call say,"Packaging to tar.gz")
	tar -czf ./ArchLinuxARM-rpi4-aarch64-latest.tar.gz -C $(_RPI_RESULT_ROOTFS)/ .

.PHONY: toolbox
.NOTPARALLEL: clean-all install
