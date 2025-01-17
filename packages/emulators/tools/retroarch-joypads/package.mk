# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="retroarch-joypads"
PKG_VERSION="e7881a84d9a5fc1569f6d50f675dce7fdd7a0480"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/libretro/retroarch-joypad-autoconfig"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="RetroArch joypad autoconfigs."
PKG_TOOLCHAIN="manual"

make_target() {
  :
}

makeinstall_target() {
  INSTALLDIR="${INSTALL}/usr/share/libretro/autoconfig"
  mkdir -p ${INSTALLDIR}
  for JOYDIR in linuxraw sdl2 udev x xinput
  do
    cp ${PKG_BUILD}/${JOYDIR}/*cfg ${INSTALLDIR}
  done
  if [ -d "${PKG_DIR}/gamepads" ]
  then
    cp -r ${PKG_DIR}/gamepads/* ${INSTALLDIR} ||:
  fi
}

post_install() {
  enable_service tmp-joypads.mount
}
