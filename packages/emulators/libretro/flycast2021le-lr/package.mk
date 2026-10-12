# SPDX-License-Identifier: GPL-2.0-or-later

PKG_NAME="flycast2021le-lr"
PKG_VERSION="408ee72169d30040adbb7ef579ac93cc1e28ac54"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/navy1978/flycast2022-lowend"
PKG_URL="${PKG_SITE}.git"
PKG_ARCH="aarch64"
PKG_DEPENDS_TARGET="toolchain ${OPENGLES}"
PKG_LONGDESC="flycast2021le libretro core, installed alongside Flycast and Flycast2021."
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="-lto -gold"

pre_configure_target() {
  # Keep the distribution's CPU/sysroot/linker flags. The generic ARM64
  # platform supplies the dynarec and GLES flags without hardcoding a CPU.
  sed -i -e '/^CFLAGS *:=/d' -e '/^CXXFLAGS *:=/d' -e '/^LDFLAGS *:=/d' \
    -e 's/^INCFLAGS *:=.*/INCFLAGS := $(CPPFLAGS)/' \
    "${PKG_BUILD}/Makefile"
  sed -i 's/define CORE_OPTION_NAME "reicast"/define CORE_OPTION_NAME "flycast2021le"/' \
    "${PKG_BUILD}/core/libretro/libretro_core_option_defines.h"
  sed -i 's/info->library_name = "Flycast"/info->library_name = "Flycast 2021 LE"/' \
    "${PKG_BUILD}/core/libretro/libretro.cpp"
}

make_target() {
  # Use the fork's handheld defaults; experimental options remain opt-in.
  CFLAGS="${CFLAGS} -DLOW_END -DLOW_RES" \
  CXXFLAGS="${CXXFLAGS} -DLOW_END -DLOW_RES" \
  make -C "${PKG_BUILD}" platform=arm64 ARCH=aarch64 FORCE_GLES=1 \
    CC_AS="${CC}" HAVE_OPENMP=1 HAVE_LTCG=0 GIT_VERSION="${PKG_VERSION:0:7}"
}

makeinstall_target() {
  mkdir -p "${INSTALL}/usr/lib/libretro"
  cp "${PKG_BUILD}/flycast_libretro.so" \
    "${INSTALL}/usr/lib/libretro/flycast2021le_libretro.so"
  cp "${PKG_DIR}/config/flycast2021le_libretro.info" \
    "${INSTALL}/usr/lib/libretro/"
}
