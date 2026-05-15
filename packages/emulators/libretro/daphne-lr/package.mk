# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="daphne-lr"
PKG_VERSION="6f1695dd1f376060666eec0a416ff56bb6c9cccc"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv2+"
PKG_SITE="https://github.com/libretro/daphne"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="This is a Daphne core"
PKG_TOOLCHAIN="make"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp daphne_libretro.so ${INSTALL}/usr/lib/libretro/
}

