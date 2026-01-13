# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present AmberELEC (https://github.com/AmberELEC)

PKG_NAME="jaxe-lr"
PKG_VERSION="e8e90e3d683bb560df5882f0ad62ed28f96a541a"
PKG_ARCH="aarch64"
PKG_SITE="https://github.com/kurtjd/jaxe"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A fully-featured, cross platform XO-CHIP/S-CHIP/CHIP-8 emulator written in C and SDL"
PKG_TOOLCHAIN="make"

make_target() {
  cd ${PKG_BUILD}
  make -f Makefile.libretro
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/jaxe_libretro.so ${INSTALL}/usr/lib/libretro/
}
