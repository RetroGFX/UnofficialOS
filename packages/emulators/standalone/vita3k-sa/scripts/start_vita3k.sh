#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile
set_kill set "-9 Vita3K"

GAME="${1}"

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

ROMNAME=$(echo "${1}" | sed "s#^/.*/##")
PLATFORM="${2}"
RENDERER=$(get_setting graphics_backend "${PLATFORM}" "${ROMNAME}")
IRES=$(get_setting internal_resolution "${PLATFORM}" "${ROMNAME}")
FILTER=$(get_setting bilinear_filtering "${PLATFORM}" "${ROMNAME}")
ACCURACY=$(get_setting high_accuracy "${PLATFORM}" "${ROMNAME}")
VSYNC=$(get_setting vsync "${PLATFORM}" "${ROMNAME}")

#Graphics Backend
if [ "${RENDERER}" = "opengl" ]; then
  sed -i "/^backend-renderer:/c\backend-renderer: OpenGL" /storage/.config/Vita3K/config.yml
else
  sed -i "/^backend-renderer:/c\backend-renderer: Vulkan" /storage/.config/Vita3K/config.yml
fi

#Internal Resolution
if [ "$IRES" = "0.5" ]; then
  sed -i "/^resolution-multiplier:/c\resolution-multiplier: 0.5" /storage/.config/Vita3K/config.yml
elif [ "$IRES" = "0.75" ]; then
  sed -i "/^resolution-multiplier:/c\resolution-multiplier: 0.75" /storage/.config/Vita3K/config.yml
elif [ "$IRES" = "1.25" ]; then
  sed -i "/^resolution-multiplier:/c\resolution-multiplier: 1.25" /storage/.config/Vita3K/config.yml
elif [ "$IRES" = "1.5" ]; then
  sed -i "/^resolution-multiplier:/c\resolution-multiplier: 1.5" /storage/.config/Vita3K/config.yml
elif [ "$IRES" = "1.75" ]; then
  sed -i "/^resolution-multiplier:/c\resolution-multiplier: 1.75" /storage/.config/Vita3K/config.yml
elif [ "$IRES" = "2" ]; then
  sed -i "/^resolution-multiplier:/c\resolution-multiplier: 2" /storage/.config/Vita3K/config.yml
else
  sed -i "/^resolution-multiplier:/c\resolution-multiplier: 1" /storage/.config/Vita3K/config.yml
fi

# Bilinear Filtering
if [ "${FILTER}" = "0" ]; then
  sed -i '/^screen-filter:/c\screen-filter: Nearest' /storage/.config/Vita3K/config.yml
elif [ "${FILTER}" = "2" ]; then
  sed -i '/^screen-filter:/c\screen-filter: Bicubic' /storage/.config/Vita3K/config.yml
elif [ "${FILTER}" = "3" ]; then
  sed -i '/^screen-filter:/c\screen-filter: FXAA' /storage/.config/Vita3K/config.yml
elif [ "${FILTER}" = "4" ]; then
  sed -i '/^screen-filter:/c\screen-filter: FSR' /storage/.config/Vita3K/config.yml
else
  sed -i '/^screen-filter:/c\screen-filter: Bilinear' /storage/.config/Vita3K/config.yml
fi

#Renderer Accuracy
if [ "${ACCURACY}" = "true" ]; then
  sed -i "/^high-accuracy:/c\high-accuracy: true" /storage/.config/Vita3K/config.yml
else
  sed -i "/^high-accuracy:/c\high-accuracy: false" /storage/.config/Vita3K/config.yml
fi

#Vsync
if [ "${VSYNC}" = "false" ]; then
  sed -i "/^v-sync:/c\v-sync: false" /storage/.config/Vita3K/config.yml
else
  sed -i "/^v-sync:/c\v-sync: true" /storage/.config/Vita3K/config.yml
fi

if [ -n "${GAME}" ]; then
  OPTIONS="-r $(cat "${GAME}")"
fi

#Start Vita3K
/usr/bin/vita3k-sa -F -f /storage/.config/Vita3K/config.yml ${OPTIONS}
