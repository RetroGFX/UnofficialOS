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

# Audio and display environment
export SDL_AUDIODRIVER=pipewire
export PIPEWIRE_RUNTIME_DIR=/run/pipewire
export WAYLAND_DISPLAY=wayland-1
export XDG_RUNTIME_DIR=/var/run/0-runtime-dir

CONFIG="/storage/.config/xemu/xemu.toml"

/usr/bin/xemu-sa -full-screen -config_path "$CONFIG"
