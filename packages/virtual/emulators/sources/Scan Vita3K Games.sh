#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present UnofficialOS (https://github.com/RetroGFX/UnofficialOS)

. /etc/profile

/usr/bin/scan_vita3k.sh

systemctl restart ${UI_SERVICE}
