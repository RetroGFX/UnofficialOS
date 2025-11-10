################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
#      Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)
#
#  This Program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2, or (at your option)
#  any later version.
#
#  This Program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.tv; see the file COPYING.  If not, write to
#  the Free Software Foundation, 51 Franklin Street, Suite 500, Boston, MA 02110, USA.
#  http://www.gnu.org/copyleft/gpl.html
################################################################################

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