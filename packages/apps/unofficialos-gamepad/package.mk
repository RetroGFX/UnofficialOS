PKG_NAME="unofficialos-gamepad"
PKG_VERSION="b1fc0fb69047011d99b54029be500280d33a8027"
PKG_ARCH="aarch64"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/R-ARM/rinputer2"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_TOOLCHAIN="make"
GET_HANDLER_SUPPORT="git"
PKG_PATCH_DIRS+=" common"

makeinstall_target() {
  mkdir -p $INSTALL/usr/bin
  cp rinputer2 ${INSTALL}/usr/bin/unofficialos_gamepad
  chmod 0755 ${INSTALL}/usr/bin/unofficialos_gamepad
}

post_install() {
  enable_service unofficialos_gamepad.service
}
