# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present UnofficialOS (https://github.com/RetroGFX/UnofficialOS)

PKG_NAME="morpheuscast-xtreme32-lr"
PKG_VERSION="1.0"
PKG_SITE="https://github.com/RetroGFX/UnofficialOSAddOns"
PKG_URL="${PKG_SITE}/raw/refs/heads/main/cores/${PKG_NAME}.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="KMFDManic MorpheusCast DC Core"
PKG_LONGDESC="MorpheusCast Xtreme is a multi-platform Sega Dreamcast emulator, built for lower-end devices"
PKG_TOOLCHAIN="manual"

unpack() {
  mkdir -p ${PKG_BUILD}
  cd ${PKG_BUILD}
  tar -xf ${SOURCES}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.xz
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/*.so ${INSTALL}/usr/lib/libretro/morpheuscast_xtreme32_libretro.so
  cp ${PKG_BUILD}/*.info ${INSTALL}/usr/lib/libretro/morpheuscast_xtreme32_libretro.info
}
