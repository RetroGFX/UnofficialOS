# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="bsnes-mercury-performance-lr"
PKG_VERSION="0f35d044bf2f2b879018a0500e676447e93a1db1"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/bsnes-mercury"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="libretro"
PKG_SHORTDESC="BSNES Super Nintendo Libretro Core"
PKG_IS_ADDON="no"
PKG_TOOLCHAIN="make"
PKG_AUTORECONF="no"

pre_configure_target() {
  sed -i 's/\-O[23]/-Ofast/' ${PKG_BUILD}/Makefile
}

pre_make_target() {
    PKG_MAKE_OPTS_TARGET+=" platform=${DEVICE}"
}

make_target() {
  make PROFILE=performance
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp bsnes_mercury_performance_libretro.so ${INSTALL}/usr/lib/libretro/
}

