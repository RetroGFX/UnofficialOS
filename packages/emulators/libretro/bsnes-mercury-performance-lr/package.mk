# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="bsnes-mercury-performance-lr"
PKG_VERSION="ac0b6b1fe5cb9448492f4c6b3d815205eefbd142"
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

