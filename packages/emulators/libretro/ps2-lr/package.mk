# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="ps2-lr"
PKG_VERSION="bb03c99fa968b50309bd80d74598f053fe9168ce"
PKG_GIT_CLONE_BRANCH="libretroization"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_DEPENDS_TARGET="toolchain alsa-lib freetype zlib libpng libaio libsamplerate libfmt libpcap soundtouch yamlcpp wxwidgets"
PKG_SITE="https://github.com/libretro/ps2"
PKG_URL="${PKG_SITE}.git"
PKG_SECTION="libretro"
PKG_SHORTDESC="Libretro port of PCSX2 - PlayStation 2 emulator"
PKG_DEPENDS_TARGET="toolchain"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]
then
  PKG_DEPENDS_TARGET+=" vulkan-loader vulkan-headers"
fi

if [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_DEPENDS_TARGET+=" wayland ${WINDOWMANAGER}"
fi

KG_CMAKE_OPTS_TARGET=" \
                        -DSDL2_API=TRUE \
                        -DDISABLE_PCSX2_WRAPPER=1 \
                        -DPACKAGE_MODE=FALSE \
                        -DPCSX2_TARGET_ARCHITECTURES=x86_64 \
                        -DENABLE_TESTS=OFF \
                        -DEXTRA_PLUGINS=OFF \
                        -DQT_BUILD=FALSE \
                        -DBUILD_SHARED_LIBS=OFF \
                        -DUSE_SYSTEM_LIBS=OFF \
                        -DDISABLE_ADVANCE_SIMD=ON \
                        -DUSE_VTUNE=OFF \
                        -DUSE_VULKAN=ON \
			                  -DGTK3_API=FALSE \
                        -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=FALSE \
                        -DCMAKE_BUILD_TYPE=Release"

pre_configure_target() {
  export LDFLAGS="${LDFLAGS} -laio"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/.${TARGET_NAME}/bin/pcsx2_libretro.so ${INSTALL}/usr/lib/libretro/ps2_libretro.so
}
