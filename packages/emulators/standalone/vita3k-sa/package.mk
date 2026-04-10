# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="vita3k-sa"
PKG_VERSION="3944"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/Vita3K/Vita3K"
PKG_URL="${PKG_SITE}-builds/releases/download/${PKG_VERSION}/Vita3K-x86_64.AppImage"
PKG_DEPENDS_TARGET="toolchain libevdev SDL2 qt5 fuse2 mesa libcom-err"
PKG_LONGDESC="Experimental PlayStation Vita emulator"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  # Redefine strip or the AppImage will be stripped rendering it unusable.
  export STRIP=true
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/config/vita3k
  mkdir -p ${INSTALL}/usr/config/vita3k/sources
  cp ${PKG_BUILD}/${PKG_NAME}-${PKG_VERSION}.AppImage ${INSTALL}/usr/bin/${PKG_NAME}
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin/
  chmod 755 ${INSTALL}/usr/bin/*
  cp -rf ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/vita3k/
  cp ${PKG_DIR}/sources/vita-gamelist.txt ${INSTALL}/usr/config/vita3k/sources/vita-gamelist.txt
}
