# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="geolith-lr"
PKG_VERSION="e9ba4248c17aa98c8a86b87f2221e48971fd0104"
PKG_ARCH="aarch64"
PKG_LICENSE="BSD"
PKG_SITE="https://github.com/libretro/geolith-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Geolith is a highly accurate emulator for the Neo Geo AES, MVS and Neo Geo CD."
PKG_TOOLCHAIN="make"

make_target() {
cd libretro
  case "${DEVICE_NAME}" in
    RK356*)
      sed -i '/a53/s//a55/g' Makefile
      sed -i '/rpi3_64/s//RK3566-BSP/' Makefile
      make -f ./Makefile platform=RK3566-BSP
      ;;
    *)
      make -f ./Makefile platform=${DEVICE_NAME}
      ;;
  esac
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp geolith_libretro.so ${INSTALL}/usr/lib/libretro/
}