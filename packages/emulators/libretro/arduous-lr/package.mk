# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="arduous-lr"
PKG_VERSION="fba6f3e418218cf35a17cda8aac62133ff327f2c"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libretro/arduous"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="A Libretro emulator core for the Arduboy"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp arduous_libretro.so ${INSTALL}/usr/lib/libretro/
}
