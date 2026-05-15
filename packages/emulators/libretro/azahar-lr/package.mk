# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present UnofficialOS (https://github.com/RetroGFX/UnofficialOS)

PKG_NAME="azahar-lr"
PKG_VERSION="921ea178b9d37ffb2cc879a12d7d790689052bf9"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/azahar-emu/azahar"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Azahar (Nintendo 3DS) Libretro Core"
PKG_TOOLCHAIN="cmake"

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_PATCH_DIRS+=" gles"
  AZAHAR_ENABLE_OPENGL="ON"
elif [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
  AZAHAR_ENABLE_OPENGL="ON"
else
  AZAHAR_ENABLE_OPENGL="OFF"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
  AZAHAR_ENABLE_VULKAN="ON"
else
  AZAHAR_ENABLE_VULKAN="OFF"
fi

PKG_CMAKE_OPTS_TARGET+=" -DENABLE_LIBRETRO=ON \
                         -DENABLE_QT=OFF \
                         -DENABLE_SDL2=OFF \
                         -DENABLE_WEB_SERVICE=OFF \
                         -DENABLE_SCRIPTING=OFF \
                         -DENABLE_OPENAL=OFF \
                         -DENABLE_CUBEB=OFF \
                         -DENABLE_LIBUSB=OFF \
                         -DENABLE_ROOM=OFF \
                         -DENABLE_ROOM_STANDALONE=OFF \
                         -DENABLE_TESTS=OFF \
                         -DUSE_DISCORD_PRESENCE=OFF \
                         -DCITRA_WARNINGS_AS_ERRORS=OFF \
                         -DENABLE_OPENGL=${AZAHAR_ENABLE_OPENGL} \
                         -DENABLE_VULKAN=${AZAHAR_ENABLE_VULKAN} \
                         -DENABLE_SOFTWARE_RENDERER=OFF \
                         -DCMAKE_BUILD_TYPE=Release"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp -v ${PKG_BUILD}/.${TARGET_NAME}/bin/Release/azahar_libretro.so \
    ${INSTALL}/usr/lib/libretro/azahar_libretro.so
}
