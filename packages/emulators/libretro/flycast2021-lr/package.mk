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

PKG_NAME="flycast2021-lr"
PKG_VERSION="603814c9f73b773c455d9a497f389d2f93a257fd"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/ROCKNIX/distribution-sources"
PKG_URL="${PKG_SITE}/releases/download/sources/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Flycast is a multiplatform Sega Dreamcast emulator "
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-gold"
PKG_PATCH_DIRS+="${DEVICE}"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_MAKE_OPTS_TARGET+=" FORCE_GLES=1"
fi

pre_configure_target() {
  sed -i 's/define CORE_OPTION_NAME "reicast"/define CORE_OPTION_NAME "flycast2021"/g' core/libretro/libretro_core_option_defines.h
  sed -i 's/\-O[23]/-Ofast/' ${PKG_BUILD}/Makefile
  PKG_MAKE_OPTS_TARGET="${PKG_MAKE_OPTS_TARGET} ARCH=${TARGET_ARCH} HAVE_OPENMP=1 GIT_VERSION=${PKG_VERSION:0:7}  HAVE_LTCG=0"
}

pre_make_target() {
  export BUILD_SYSROOT=${SYSROOT_PREFIX}
  case ${DEVICE} in
    RK3*|S922X*)
      PKG_MAKE_OPTS_TARGET+=" platform=${DEVICE}"
    ;;
  esac
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp flycast_libretro.so ${INSTALL}/usr/lib/libretro/flycast2021_libretro.so
}
