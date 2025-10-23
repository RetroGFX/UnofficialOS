# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="mcu-led"
PKG_VERSION="1.0"
PKG_SITE="https://UnofficialOS.org"
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="MCU LED Joystick LED control utility"
PKG_LONGDESC="Utility to control the LED joysticks for XiFan units."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/sources/* ${INSTALL}/usr/bin
  chmod +x ${INSTALL}/usr/bin/*
}