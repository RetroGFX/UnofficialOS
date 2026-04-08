#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present UnofficialOS (https://github.com/RetroGFX/UnofficialOS)

. /etc/profile
BIOS_PATH="/storage/roms/bios/vita3k/bios"
CONFIG_FILE="/storage/.config/Vita3K/config.yml"

#Iterate on the PUP Files and install them
cd $BIOS_PATH
for FW in *.PUP
do
/usr/bin/vita3k-sa -f $CONFIG_FILE --firmware $FW
done
