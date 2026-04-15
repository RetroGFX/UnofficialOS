# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="duckstation-sa"
PKG_LICENSE="GPLv3"
PKG_DEPENDS_TARGET=""
PKG_VERSION="0.1-10495"
PKG_LONGDESC="Fast PlayStation 1 emulator for x86-64/AArch32/AArch64 "
PKG_TOOLCHAIN="manual"

case ${TARGET_ARCH} in
  x86_64)
    PKG_SITE="https://github.com/stenzek/duckstation"
    PKG_SOURCE_NAME="${PKG_NAME}-${PKG_VERSION}.AppImage"
    PKG_URL="${PKG_SITE}/releases/download/v${PKG_VERSION}/DuckStation-x64.AppImage"
  ;;
  aarch64)
    PKG_SITE="https://github.com/RetroGFX/UnofficialOSAddOns"
    PKG_SOURCE_NAME="${PKG_NAME}-${PKG_VERSION}-aarch64.AppImage"
    PKG_URL="${PKG_SITE}/raw/refs/heads/main/${PKG_SOURCE_NAME}"
  ;;
esac

install_script() {
  if [ ! -d "${INSTALL}/usr/config/modules" ]
  then
    mkdir -p ${INSTALL}/usr/config/modules
  fi
  cp -rf ${PKG_DIR}/sources/"${1}" ${INSTALL}/usr/config/modules
  chmod 0755 ${INSTALL}/usr/config/modules/"${1}"
}

makeinstall_target() {
  # Redefine strip or the AppImage will be stripped rendering it unusable.
  export STRIP=true
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/${PKG_SOURCE_NAME} ${INSTALL}/usr/bin/${PKG_NAME}
  cp -rf ${PKG_DIR}/scripts/*.sh ${INSTALL}/usr/bin
  chmod 755 ${INSTALL}/usr/bin/*

  mkdir -p ${INSTALL}/usr/config/duckstation
  cp -rf ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/duckstation
  
  install_script "Start Duckstation.sh"
}
