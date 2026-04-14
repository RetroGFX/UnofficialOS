#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present UnofficialOS (https://github.com/RetroGFX/UnofficialOS)

. /etc/profile

set_kill set "-9 duckstation-nogui"

/usr/bin/duckstation-nogui -fullscreen -settings "/storage/.config/duckstation/settings.ini"
