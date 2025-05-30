# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="unofficialos-joypad"
PKG_VERSION="ceaf19c99be24194f5341d47b614625435f84b4a"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/RetroGFX/unofficialos-joypad"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="unofficialos-joypad: UnofficialOS joypad driver"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  kernel_make -C $(kernel_path) M=${PKG_BUILD}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    cp *.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
}