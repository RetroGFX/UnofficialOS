# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present UnofficialOS (https://github.com/RetroGFX/UnofficialOS)

PKG_NAME="bigpemu-sa"
PKG_VERSION="v1221"
PKG_ARCH="any"
PKG_LICENSE="Proprietary"
PKG_SITE="https://www.richwhitehouse.com/jaguar/"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="BigPEmu - The World's Prefurred Large Pussycat Emulator."
PKG_TOOLCHAIN="manual"

case ${TARGET_ARCH} in
  x86_64)
    PKG_URL="${PKG_SITE}/builds/BigPEmu_Linux64_${PKG_VERSION}.tar.gz"
    PKG_SOURCE_NAME="bigpemu-x86_64-${PKG_VERSION}.tar.gz"
  ;;
  aarch64)
    PKG_URL="${PKG_SITE}/builds/BigPEmu_LinuxARM64_${PKG_VERSION}.tar.gz"
    PKG_SOURCE_NAME="bigpemu-aarch64-${PKG_VERSION}.tar.gz"
  ;;
esac

pre_make_target() {
  case ${DEVICE} in
    RK3566-BSP*)
      GL4ES_DIR="${PKG_BUILD}/gl4es_bigpemu"
      git clone --depth=1 https://github.com/ptitSeb/gl4es.git ${GL4ES_DIR}
      mkdir -p ${GL4ES_DIR}/build
      cd ${GL4ES_DIR}/build
      cmake .. -DODROID=1 \
               -DNOX11=1 \
               -DNOEGL=1 \
               -DCMAKE_BUILD_TYPE=RelWithDebInfo \
               -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
      make -j$(getconf _NPROCESSORS_ONLN)
      ${STRIP} ${GL4ES_DIR}/lib/libGL.so.1
    ;;
  esac
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/share/bigpemu
 
  # Copy gl4es lib and symlinks before removing build dir
  case ${DEVICE} in
    RK3566-BSP*)
      GL4ES_DIR="${PKG_BUILD}/gl4es_bigpemu"
      if [ -f ${GL4ES_DIR}/lib/libGL.so.1 ]; then
        cp ${GL4ES_DIR}/lib/libGL.so.1 ${INSTALL}/usr/share/bigpemu/
        ln -sf libGL.so.1 ${INSTALL}/usr/share/bigpemu/libOpenGL.so
        ln -sf libOpenGL.so ${INSTALL}/usr/share/bigpemu/libOpenGL.so.0
      fi
    ;;
  esac
 
  # Remove gl4es build dir then copy bigpemu files
  rm -rf ${PKG_BUILD}/gl4es_bigpemu
  cp -rf ${PKG_BUILD}/* ${INSTALL}/usr/share/bigpemu/
 
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  chmod 755 ${INSTALL}/usr/bin/*
 
  mkdir -p ${INSTALL}/usr/config/bigpemu/userdata
  cp -rf ${PKG_DIR}/config/${DEVICE}/BigPEmuConfig.bigpcfg* ${INSTALL}/usr/config/bigpemu/userdata/
}
