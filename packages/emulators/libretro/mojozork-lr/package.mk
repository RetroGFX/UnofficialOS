# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present AmberELEC (https://github.com/AmberELEC)

PKG_NAME="mojozork-lr"
PKG_VERSION="f9211077f46160b9f6680a835fa42e0211b1d98b"
PKG_SITE="https://github.com/icculus/mojozork"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A simple Z-Machine implementation in a single C file"
PKG_TOOLCHAIN="cmake"

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET+="-DLIBRETRO=ON \
                          -DMOJOZORK_LIBRETRO=ON \
                          -DMOJOZORK_STANDALONE_DEFAULT=OFF \
                          -DMOJOZORK_MULTIZORK_DEFAULT=OFF \
                          -DMOJOZORK_SDL3_DEFAULT=OFF"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/.${TARGET_NAME}/mojozork_libretro.so ${INSTALL}/usr/lib/libretro/
}
