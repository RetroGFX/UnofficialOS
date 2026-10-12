# SPDX-License-Identifier: GPL-2.0-or-later

PKG_NAME="retrorun"
PKG_VERSION="015972c744051ebecb37e4bd0496ee98a94ed726"
PKG_LICENSE="GPLv2+"
PKG_SITE="https://github.com/navy1978/retrorun"
PKG_URL="${PKG_SITE}.git"
PKG_ARCH="aarch64"
PKG_DEPENDS_TARGET="toolchain SDL2 libpng curl zlib ${OPENGLES}"
PKG_LONGDESC="Lightweight SDL2/OpenGL ES libretro frontend."
PKG_TOOLCHAIN="manual"

make_target() {
  make -C "${PKG_BUILD}" sdl2 config=release \
    SDL_CFLAGS="$("${PKG_CONFIG}" --cflags sdl2)" \
    SDL_LIBS="$("${PKG_CONFIG}" --libs sdl2)"
}

makeinstall_target() {
  mkdir -p "${INSTALL}/usr/bin" "${INSTALL}/usr/config/retrorun"
  cp "${PKG_BUILD}/retrorun-sdl2" "${INSTALL}/usr/bin/"
  cp "${PKG_DIR}/scripts/start_retrorun.sh" "${INSTALL}/usr/bin/"
  chmod 0755 "${INSTALL}/usr/bin/start_retrorun.sh"
  cp "${PKG_DIR}/config/"* "${INSTALL}/usr/config/retrorun/"
}
