#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present UnofficialOS (https://github.com/RetroGFX/UnofficialOS)

. /etc/profile
set_kill set "-9 Vita3K"

CONFIG_FILE="/storage/.config/Vita3K/config.yml"

#Check if vita3k folder exists in /storage/.config/Vita3K
if [ ! -d "/storage/.config/Vita3K" ]; then
    mkdir -p "/storage/.config/Vita3K"
fi

# Make vita3k bios folders
if [ ! -d "/storage/roms/bios/vita3k/bios" ]; then
    mkdir -p "/storage/roms/bios/vita3k/bios"
fi

#Make sure we sync any changes from /storage/.config so new features will be enabled
#without overwriting existing settings.
rsync -ah --update /usr/config/vita3k/* /storage/.config/Vita3K 2>/dev/null

#Check if vita3k folder exists in /storage/roms/psvita
if [ ! -d "/storage/roms/psvita/vita3k" ]; then
    mkdir -p "/storage/roms/psvita/vita3k"
fi

#Check if vita3k Default data folder exists, else link it to /storage/roms/psvita
if [ ! -d "/storage/.local/share/Vita3K/Vita3K" ]; then
    mkdir -p "/storage/.local/share/Vita3K/"
    ln -s /storage/roms/psvita/vita3k /storage/.local/share/Vita3K/Vita3K
fi

#Start Vita3K
/usr/bin/vita3k-sa -F -f $CONFIG_FILE
