#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

source /etc/profile

set_kill set "xemu-sa"

# Ensure config exists
if [ ! -d "/storage/.config/xemu" ]; then
    mkdir -p "/storage/.config/xemu"
    cp -r "/usr/config/xemu" "/storage/.config/"
fi

if [ ! -f "/storage/.config/xemu/xemu.toml" ]; then
    cp "/usr/config/xemu/xemu.toml" "/storage/.config/xemu/xemu.toml"
fi

# Ensure AppImage is extracted
if [ ! -f "/storage/xemu/usr/bin/xemu" ]; then
    mkdir -p /storage/xemu
    cd /storage/xemu && /usr/bin/xemu-sa --appimage-extract
    mv /storage/xemu/squashfs-root/* /storage/xemu/
    rm -rf /storage/xemu/squashfs-root
fi

# Set environment
export LD_LIBRARY_PATH=/storage/xemu/usr/lib:$LD_LIBRARY_PATH
export SDL_AUDIODRIVER=pipewire
export PIPEWIRE_RUNTIME_DIR=/run/pipewire
export WAYLAND_DISPLAY=wayland-1
export XDG_RUNTIME_DIR=/var/run/0-runtime-dir

CONFIG="/storage/.config/xemu/xemu.toml"

# Launch GUI (no -dvd_path, no -full-screen so the window is usable)
/storage/xemu/usr/bin/xemu -full-screen -config_path "$CONFIG"
