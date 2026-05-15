# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="dolphin-sa"
PKG_LICENSE="GPLv2"
PKG_DEPENDS_TARGET="toolchain libevdev libdrm ffmpeg zlib libpng lzo libusb zstd ecm openal-soft pulseaudio alsa-lib"
PKG_LONGDESC="Dolphin is a GameCube / Wii emulator, allowing you to play games for these two platforms on PC with improvements. "
PKG_TOOLCHAIN="cmake"

case ${DEVICE} in
  RK3588*|AMD64|S922X|RK3399)
    PKG_SITE="https://github.com/dolphin-emu/dolphin"
    PKG_URL="${PKG_SITE}.git"
    PKG_VERSION="e6583f8bec814d8f3748f1d7738457600ce0de56"
    PKG_PATCH_DIRS+=" wayland"
  ;;
  *)
    PKG_SITE="https://github.com/rtissera/dolphin"
    PKG_URL="${PKG_SITE}.git"
    PKG_VERSION="0b160db48796f727311cea16072174d96b784f80"
    PKG_GIT_CLONE_BRANCH="egldrm"
    PKG_PATCH_DIRS+=" legacy"
    PKG_PATCH_DIRS+=" ${DEVICE}"
    case ${DEVICE} in
      RK3566-BSP-RGARC|RK3566-BSP-X55)
        PKG_DEPENDS_TARGET+=" librga"
      ;;
    esac
  ;;
esac

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
  PKG_CMAKE_OPTS_TARGET+=" -DENABLE_EGL=ON"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_CMAKE_OPTS_TARGET+=" -DENABLE_EGL=ON"
fi

if [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_DEPENDS_TARGET+=" wayland ${WINDOWMANAGER} xwayland xrandr libXi"
  PKG_CMAKE_OPTS_TARGET+=" -DENABLE_WAYLAND=ON \
                           -DENABLE_X11=ON"
else
  PKG_CMAKE_OPTS_TARGET+=" -DENABLE_X11=OFF"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]
then
  PKG_DEPENDS_TARGET+=" vulkan-loader vulkan-headers"
  PKG_CMAKE_OPTS_TARGET+=" -DENABLE_VULKAN=ON"
else
  PKG_CMAKE_OPTS_TARGET+=" -DENABLE_VULKAN=OFF"
fi

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET+=" -DENABLE_HEADLESS=ON \
                           -DENABLE_EVDEV=ON \
                           -DUSE_DISCORD_PRESENCE=OFF \
                           -DBUILD_SHARED_LIBS=OFF \
                           -DLINUX_LOCAL_DEV=ON \
                           -DENABLE_PULSEAUDIO=ON \
                           -DENABLE_ALSA=ON \
                           -DENABLE_TESTS=OFF \
                           -DENABLE_LLVM=OFF \
                           -DENABLE_ANALYTICS=OFF \
                           -DENABLE_LTO=ON \
                           -DENABLE_QT=OFF \
                           -DENCODE_FRAMEDUMPS=OFF \
                           -DENABLE_CLI_TOOL=OFF"
  case ${DEVICE} in
    RK3588*|AMD64|S922X|RK3399)
      sed -i 's~#include <cstdlib>~#include <cstdlib>\n#include <cstdint>~g' ${PKG_BUILD}/Externals/VulkanMemoryAllocator/include/vk_mem_alloc.h
      sed -i 's~#include <cstdint>~#include <cstdint>\n#include <string>~g' ${PKG_BUILD}/Externals/VulkanMemoryAllocator/include/vk_mem_alloc.h
    ;;
  esac
  
# For RK3566-BSP devices, set up older g2p0 Mali driver for compatibility
  case ${DEVICE} in
    RK3566-BSP*)
      mkdir -p ${PKG_BUILD}/dolphin_mali_lib
      
      LIBMALI_BUILD=$(get_build_dir libmali)
      if [ -f ${LIBMALI_BUILD}/lib/aarch64-linux-gnu/libmali-bifrost-g52-g2p0-gbm.so ]; then
        cp ${LIBMALI_BUILD}/lib/aarch64-linux-gnu/libmali-bifrost-g52-g2p0-gbm.so \
           ${PKG_BUILD}/dolphin_mali_lib/libmali.so
        
        export CMAKE_PREFIX_PATH="${PKG_BUILD}/dolphin_mali_lib:${CMAKE_PREFIX_PATH}"
        
        MALI_LIB="${PKG_BUILD}/dolphin_mali_lib/libmali.so"
        export LDFLAGS="${LDFLAGS} -L${PKG_BUILD}/dolphin_mali_lib"
        
        ln -sf libmali.so ${PKG_BUILD}/dolphin_mali_lib/libEGL.so
        ln -sf libmali.so ${PKG_BUILD}/dolphin_mali_lib/libGLESv2.so
        ln -sf libmali.so ${PKG_BUILD}/dolphin_mali_lib/libgbm.so
        
        PKG_CMAKE_OPTS_TARGET+=" -DEGL_LIBRARY=${MALI_LIB} \
                                 -DOpenGL_GL_PREFERENCE=GLVND \
                                 -DOPENGL_egl_LIBRARY=${MALI_LIB} \
                                 -DOPENGL_gles2_LIBRARY=${MALI_LIB}"
      fi
    ;;
  esac
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/Binaries/dolphin* ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

  chmod +x ${INSTALL}/usr/bin/start_dolphin_gc.sh
  chmod +x ${INSTALL}/usr/bin/start_dolphin_wii.sh

  mkdir -p ${INSTALL}/usr/config/dolphin-emu
  cp -rf ${PKG_BUILD}/Data/Sys/* ${INSTALL}/usr/config/dolphin-emu
  cp -rf ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/dolphin-emu
  
  case ${DEVICE} in
    RK3566-BSP*)
      if [ -f ${PKG_BUILD}/dolphin_mali_lib/libmali.so ]; then
        mkdir -p ${INSTALL}/usr/lib/dolphin
        cp ${PKG_BUILD}/dolphin_mali_lib/libmali.so ${INSTALL}/usr/lib/dolphin/libmali-g2p0.so
      fi
    ;;
  esac
}

post_install() {
    case ${DEVICE} in
      RK356*)
        DOLPHIN_PLATFORM="drm"
      ;;
      RK3588*)
        DOLPHIN_PLATFORM="x11"
      ;;
      *)
        DOLPHIN_PLATFORM="wayland"
      ;;
    esac
    sed -e "s/@DOLPHIN_PLATFORM@/${DOLPHIN_PLATFORM}/g" \
        -i  ${INSTALL}/usr/bin/start_dolphin_gc.sh
    sed -e "s/@DOLPHIN_PLATFORM@/${DOLPHIN_PLATFORM}/g" \
        -i  ${INSTALL}/usr/bin/start_dolphin_wii.sh
}
