#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

set_kill set "-9 pcsx2-qt"

if [ ! -d "/storage/.config/PCSX2" ]
then
  cp -rf /usr/config/PCSX2 /storage/.config
fi

#Create PS2 bios folder
if [ ! -d "/storage/roms/bios/pcsx2/bios" ]
then
  mkdir -p "/storage/roms/bios/pcsx2/bios"
fi

#Create PS2 saves & savestates folders
if [ ! -d "/storage/roms/saves/ps2" ]
then
  mkdir -p "/storage/roms/saves/ps2"
fi
if [ ! -d "/storage/roms/savestates/ps2" ]
then
  mkdir -p "/storage/roms/savestates/ps2"
fi

#Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
ASPECT=$(get_setting aspect_ratio ps2 "${GAME}")
FILTER=$(get_setting bilinear_filtering ps2 "${GAME}")
FPS=$(get_setting show_fps ps2 "${GAME}")
RATE=$(get_setting ee_cycle_rate ps2 "${GAME}")
SKIP=$(get_setting ee_cycle_skip ps2 "${GAME}")
HWDOWNLOAD=$(get_setting hw_download_mode ps2 "${GAME}")
GRENDERER=$(get_setting graphics_backend ps2 "${GAME}")
IRES=$(get_setting internal_resolution ps2 "${GAME}")
VSYNC=$(get_setting vsync ps2 "${GAME}")
ENABLE_WIDESCREEN_PATCHES=$(get_setting enable_widescreen_patches ps2 "${GAME}")

#Aspect Ratio
if [ "$ASPECT" = "0" ]
then
  sed -i '/^AspectRatio =/c\AspectRatio = Auto 4:3/3:2' /storage/.config/PCSX2/inis/PCSX2.ini
fi
if [ "$ASPECT" = "1" ]
then
  sed -i '/^AspectRatio =/c\AspectRatio = 4:3' /storage/.config/PCSX2/inis/PCSX2.ini
fi
if [ "$ASPECT" = "2" ]
then
  sed -i '/^AspectRatio =/c\AspectRatio = 16:9' /storage/.config/PCSX2/inis/PCSX2.ini
fi
if [ "$ASPECT" = "3" ]
then
  sed -i '/^AspectRatio =/c\AspectRatio = Stretch' /storage/.config/PCSX2/inis/PCSX2.ini
fi

#Bilinear Filtering
if [ "$FILTER" = "0" ]
then
  sed -i '/^filter =/c\filter = 0' /storage/.config/PCSX2/inis/PCSX2.ini
fi
if [ "$FILTER" = "1" ]
then
  sed -i '/^filter =/c\filter = 1' /storage/.config/PCSX2/inis/PCSX2.ini
fi
if [ "$FILTER" = "2" ]
then
  sed -i '/^filter =/c\filter = 2' /storage/.config/PCSX2/inis/PCSX2.ini
fi
if [ "$FILTER" = "3" ]
then
  sed -i '/^filter =/c\filter = 3' /storage/.config/PCSX2/inis/PCSX2.ini
fi

#Graphics Backend
if [ "$GRENDERER" = "0" ]
then
  sed -i '/^Renderer =/c\Renderer = -1' /storage/.config/PCSX2/inis/PCSX2.ini
fi
if [ "$GRENDERER" = "1" ]
then
  sed -i '/^Renderer =/c\Renderer = 12' /storage/.config/PCSX2/inis/PCSX2.ini
fi
if [ "$GRENDERER" = "2" ]
then
  sed -i '/^Renderer =/c\Renderer = 14' /storage/.config/PCSX2/inis/PCSX2.ini
fi
if [ "$GRENDERER" = "3" ]
then
  sed -i '/^Renderer =/c\Renderer = 13' /storage/.config/PCSX2/inis/PCSX2.ini
fi

#Internal Resolution
if [ "$IRES" > "0" ]
then
  sed -i "/^upscale_multiplier =/c\upscale_multiplier = $IRES" /storage/.config/PCSX2/inis/PCSX2.ini
else
  sed -i '/^upscale_multiplier =/c\upscale_multiplier = 1' /storage/.config/PCSX2/inis/PCSX2.ini
fi

#Show FPS
for OSDPROPERTY in OsdShowMessages OsdShowSpeed OsdShowFPS OsdShowCPU OsdShowGPU OsdShowResolution OsdShowGSStats OsdShowIndicators
do
  case ${FPS} in
    true)
      sed -i '/^'${OSDPROPERTY}' =/c\'${OSDPROPERTY}' = true' /storage/.config/PCSX2/inis/PCSX2.ini
    ;;
    *)
      sed -i '/^'${OSDPROPERTY}' =/c\'${OSDPROPERTY}' = false' /storage/.config/PCSX2/inis/PCSX2.ini
    ;;
  esac
done

#EE Cycle Rate
sed -i '/^EECycleRate =/c\EECycleRate = 0' /storage/.config/PCSX2/inis/PCSX2.ini
if [ "$RATE" = "0" ]
then
  sed -i '/^EECycleRate =/c\EECycleRate = -3' /storage/.config/PCSX2/inis/PCSX2.ini
fi
if [ "$RATE" = "1" ]
then
  sed -i '/^EECycleRate =/c\EECycleRate = -2' /storage/.config/PCSX2/inis/PCSX2.ini
fi
if [ "$RATE" = "2" ]
then
  sed -i '/^EECycleRate =/c\EECycleRate = -1' /storage/.config/PCSX2/inis/PCSX2.ini
fi
if [ "$RATE" = "3" ]
then
  sed -i '/^EECycleRate =/c\EECycleRate = 0' /storage/.config/PCSX2/inis/PCSX2.ini
fi
if [ "$RATE" = "4" ]
then
  sed -i '/^EECycleRate =/c\EECycleRate = 1' /storage/.config/PCSX2/inis/PCSX2.ini
fi
if [ "$RATE" = "5" ]
then
  sed -i '/^EECycleRate =/c\EECycleRate = 2' /storage/.config/PCSX2/inis/PCSX2.ini
fi
if [ "$RATE" = "6" ]
then
  sed -i '/^EECycleRate =/c\EECycleRate = 3' /storage/.config/PCSX2/inis/PCSX2.ini
fi

#EE Cycle Skip
sed -i '/^EECycleSkip =/c\EECycleSkip = 0' /storage/.config/PCSX2/inis/PCSX2.ini
if [ "$SKIP" = "0" ]
then
  sed -i '/^EECycleSkip =/c\EECycleSkip = 0' /storage/.config/PCSX2/inis/PCSX2.ini
fi
if [ "$SKIP" = "1" ]
then
  sed -i '/^EECycleSkip =/c\EECycleSkip = 1' /storage/.config/PCSX2/inis/PCSX2.ini
fi
if [ "$SKIP" = "2" ]
then
  sed -i '/^EECycleSkip =/c\EECycleSkip = 2' /storage/.config/PCSX2/inis/PCSX2.ini
fi
if [ "$SKIP" = "3" ]
then
  sed -i '/^EECycleSkip =/c\EECycleSkip = 3' /storage/.config/PCSX2/inis/PCSX2.ini
fi

#HW Download Mode
sed -i '/^HWDownloadMode =/c\HWDownloadMode = 0' /storage/.config/PCSX2/inis/PCSX2.ini
if [ "$HWDOWNLOAD" = "0" ]
then
  sed -i '/^HWDownloadMode =/c\HWDownloadMode = 0' /storage/.config/PCSX2/inis/PCSX2.ini
fi
if [ "$HWDOWNLOAD" = "1" ]
then
  sed -i '/^HWDownloadMode =/c\HWDownloadMode = 1' /storage/.config/PCSX2/inis/PCSX2.ini
fi
if [ "$HWDOWNLOAD" = "2" ]
then
  sed -i '/^HWDownloadMode =/c\HWDownloadMode = 2' /storage/.config/PCSX2/inis/PCSX2.ini
fi
if [ "$HWDOWNLOAD" = "3" ]
then
  sed -i '/^HWDownloadMode =/c\HWDownloadMode = 3' /storage/.config/PCSX2/inis/PCSX2.ini
fi

#Widescreen Patches
if [ "$ENABLE_WIDESCREEN_PATCHES" = "true" ]
then
  sed -i '/^EnableWideScreenPatches =/c\EnableWideScreenPatches = true' /storage/.config/PCSX2/inis/PCSX2.ini
else
  sed -i '/^EnableWideScreenPatches =/c\EnableWideScreenPatches = false' /storage/.config/PCSX2/inis/PCSX2.ini
fi

#VSync
if [ "$VSYNC" = "true" ]
then
  sed -i '/^VsyncEnable =/c\VsyncEnable = true' /storage/.config/PCSX2/inis/PCSX2.ini
else
  sed -i '/^VsyncEnable =/c\VsyncEnable = false' /storage/.config/PCSX2/inis/PCSX2.ini
fi

@APPIMAGE@ -fastboot -bigpicture -fullscreen -- "${1}"

#Workaround until we can learn why it doesn't exit cleanly when asked.
killall -9 pcsx2-qt
