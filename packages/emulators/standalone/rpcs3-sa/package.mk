# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Frank Hartung (supervisedthinking (@) gmail.com)
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="rpcs3-sa"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/RPCS3/rpcs3-binaries-linux"
PKG_VERSION="026297334f28500c8cbf6a5f48f395196700d6d7"
PKG_REL_VERSION="0.0.40-19335-02629733"
PKG_URL="${PKG_SITE}/releases/download/build-${PKG_VERSION}/rpcs3-v${PKG_REL_VERSION}_linux64.AppImage"
PKG_DEPENDS_TARGET="toolchain libevdev SDL2 qt5 mesa libcom-err"
PKG_LONGDESC="PS3 Emulator appimage"
PKG_TOOLCHAIN="manual"


makeinstall_target() {
  # Redefine strip or the AppImage will be stripped rendering it unusable.
  export STRIP=true
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/${PKG_NAME}-${PKG_VERSION}.AppImage ${INSTALL}/usr/bin/${PKG_NAME}
  cp -rf ${PKG_DIR}/scripts/start_rpcs3.sh ${INSTALL}/usr/bin
  chmod 755 ${INSTALL}/usr/bin/*
  mkdir -p ${INSTALL}/usr/config/rpcs3
  cp -rf ${PKG_DIR}/config/* ${INSTALL}/usr/config/rpcs3/
}
