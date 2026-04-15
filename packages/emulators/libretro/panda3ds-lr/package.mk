# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)
# Copyright (C) 2022-present UnofficialOS (https://github.com/RetroGFX/UnofficialOS)
PKG_NAME="panda3ds-lr"
PKG_VERSION="944b9892f991c3aacb15436c91511543f8e665bf"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/wheremyfoodat/Panda3DS"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Panda3DS is an HLE, red-panda-themed Nintendo 3DS emulator"
PKG_TOOLCHAIN="cmake"

case ${DEVICE} in
  S922X*)
    PKG_DEPENDS_TARGET+=" ${OPENGLES}"
    PKG_PATCH_DIRS+=" gles"
    PKG_CMAKE_OPTS_TARGET+=" -DOPENGL_PROFILE=OpenGLES"
    PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_CXX_FLAGS_INIT=-march=armv8-a+crc+crypto+fp+simd"
    PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_C_FLAGS_INIT=-mno-outline-atomics"
    PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_EXE_LINKER_FLAGS_INIT=-mno-outline-atomics"
    ;;
  RK3588*)
    PKG_DEPENDS_TARGET+=" ${OPENGLES}"
    PKG_PATCH_DIRS+=" gles"
    PKG_CMAKE_OPTS_TARGET+=" -DOPENGL_PROFILE=OpenGLES"
    ;;
  *)
    PKG_DEPENDS_TARGET+=" ${OPENGL}"
    PKG_CMAKE_OPTS_TARGET+=" -DOPENGL_PROFILE=OpenGL"
    ;;
esac

PKG_CMAKE_OPTS_TARGET+=" -DBUILD_LIBRETRO_CORE=ON \
                         -DENABLE_USER_BUILD=ON \
                         -DENABLE_DISCORD_RPC=OFF \
                         -DENABLE_LUAJIT=OFF \
                         -DSDL_VIDEO=OFF \
                         -DSDL_AUDIO=OFF \
                         -DENABLE_VULKAN=OFF \
                         -DCMAKE_BUILD_TYPE=Release"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp -v ${PKG_BUILD}/.${TARGET_NAME}/panda3ds_libretro.so ${INSTALL}/usr/lib/libretro/panda3ds_libretro.so
}
