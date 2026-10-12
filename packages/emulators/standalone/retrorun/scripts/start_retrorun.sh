#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later

. /etc/profile

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 ROM CORE PLATFORM" >&2
  exit 1
fi

ROMNAME="$1"
CORE="$2"
PLATFORM="$3"
CORE_PATH="/tmp/cores/${CORE}_libretro.so"
CONFIG_DIR="/storage/.config/retrorun"
SAVE_DIR="/storage/roms/savestates/retrorun/${PLATFORM}"

# ES supplies these names, but also reject malformed manual invocations.
case "${CORE}:${PLATFORM}" in
  *[!a-zA-Z0-9_:-]*|:*|*:)
    echo "Invalid Retrorun core or platform" >&2
    exit 1
  ;;
esac
if [ ! -r "${ROMNAME}" ] || [ ! -r "${CORE_PATH}" ]; then
  echo "Retrorun ROM or core is missing: ${ROMNAME}, ${CORE_PATH}" >&2
  exit 1
fi

mkdir -p "${CONFIG_DIR}" "${SAVE_DIR}" /storage/roms/bios
if [ ! -f "${CONFIG_DIR}/retrorun.cfg" ]; then
  cp /usr/config/retrorun/retrorun.cfg "${CONFIG_DIR}/retrorun.cfg"
fi

# Use the physical model for Retrorun's existing hardware profiles. uOS's
# HW_DEVICE identifies the image (RK3566-BSP), rather than the handheld.
if [ -z "${DEVICE_NAME:-}" ] && [ -r /proc/device-tree/model ]; then
  DEVICE_NAME=$(tr -d '\000' </proc/device-tree/model)
  export DEVICE_NAME="${DEVICE_NAME#Anbernic }"
fi

# Keep the global SDL database unchanged. This frontend expects Xbox positional
# SDL face buttons and then converts them to RetroPad's Nintendo layout.
export RETRORUN_SDL_CONTROLLER_DB="${RETRORUN_SDL_CONTROLLER_DB:-/usr/config/retrorun/gamecontrollerdb.txt}"
export SDL_AUDIODRIVER="${SDL_AUDIODRIVER:-pulseaudio}"

cd "${CONFIG_DIR}" || exit 1

# ES resolves game, system and global settings through the standard uOS helper.
# Keep overrides in a launch configuration so they do not leak to other games.
CONFIG_PATH="${CONFIG_DIR}/retrorun.cfg"
OVERRIDES=$(mktemp /tmp/retrorun-options.XXXXXX) || exit 1
LAUNCH_CONFIG=
trap 'rm -f "$OVERRIDES" ${LAUNCH_CONFIG:+"$LAUNCH_CONFIG"}' EXIT

apply_es_setting() {
  local setting="$1" key="$2" choices="$3" value
  value=$(get_setting "$setting" "$PLATFORM" "${ROMNAME##*/}")
  case "$value" in ''|default) return ;; esac
  case "|$choices|" in
    *"|$value|"*) printf '%s = %s\n' "$key" "$value" >>"$OVERRIDES" ;;
    *) if [ "$value" != auto ]; then
         echo "Ignoring invalid Retrorun setting $setting=$value" >&2
       fi ;;
  esac
}

apply_es_setting retrorun_aspect_ratio retrorun_aspect_ratio '2:1|16:9|16:10|3:2|4:3|5:4|1:1'
apply_es_setting retrorun_auto_save retrorun_auto_save 'true|false'
apply_es_setting retrorun_analog_to_digital retrorun_analog_to_digital 'none|left|right|left_forced|right_forced'
apply_es_setting retrorun_fps_counter retrorun_fps_counter 'enabled|disabled'
apply_es_setting retrorun_audio_buffer retrorun_audio_buffer '1|256|512|1024|2048|-1'
apply_es_setting retrorun_audio_stable_buffer retrorun_audio_stable_buffer 'true|false'
apply_es_setting retrorun_mouse_speed_factor retrorun_mouse_speed_factor '1|2|3|4|5|6|7|8|9|10'
apply_es_setting retrorun_swap_l1r1_with_l2r2 retrorun_swap_l1r1_with_l2r2 'true|false'
apply_es_setting retrorun_tate_mode retrorun_tate_mode 'enabled|reverted|disabled'
apply_es_setting retrorun_swap_sticks retrorun_swap_sticks 'true|false'
apply_es_setting retrorun_loop_declared_fps retrorun_loop_declared_fps 'true|false'
apply_es_setting retrorun_pixel_perfect retrorun_pixel_perfect 'true|false'

case "$CORE" in
  flycast|flycast2021|flycast2021le)
    apply_es_setting retrorun_internal_resolution "${CORE}_internal_resolution" '640x480|320x240'
    apply_es_setting retrorun_dsp "${CORE}_enable_dsp" 'enabled|disabled'
  ;;
esac
case "$CORE" in
  flycast2021|flycast2021le)
    apply_es_setting retrorun_synchronous_rendering "${CORE}_synchronous_rendering" 'enabled|disabled'
    apply_es_setting retrorun_div_matching "${CORE}_div_matching" 'auto|disabled'
  ;;
esac
if [ "$CORE" = flycast ]; then
  apply_es_setting retrorun_auto_frameskip flycast_auto_skip_frame 'disabled|some|more'
fi
if [ "$CORE" = flycast2021le ]; then
  apply_es_setting retrorun_flycast2021le_game_profile retrorun_flycast2021le_game_profile 'best_performance|best_validated|disabled'
  apply_es_setting retrorun_translucent_strip_merge flycast2021le_translucent_strip_merge 'menu_guarded|disabled|inaccurate'
  apply_es_setting retrorun_sh4clock flycast2021le_sh4clock '50|75|100|120|140|160|180|200|220|240|260|280|300|350|400'
fi

if [ ! -s "$OVERRIDES" ]; then
  rm -f "$OVERRIDES"
  trap - EXIT
  exec /usr/bin/retrorun-sdl2 -c "$CONFIG_PATH" \
    -d /storage/roms/bios -s "$SAVE_DIR" "$CORE_PATH" "$ROMNAME"
fi

LAUNCH_CONFIG=$(mktemp /tmp/retrorun-config.XXXXXX) || exit 1
awk -F= '
  NR == FNR { key=$1; gsub(/^[ \t]+|[ \t]+$/, "", key); override[key]=1; next }
  { key=$1; gsub(/^[ \t]+|[ \t]+$/, "", key); if (!(key in override)) print }
' "$OVERRIDES" "$CONFIG_PATH" >"$LAUNCH_CONFIG" || exit 1
cat "$OVERRIDES" >>"$LAUNCH_CONFIG"
/usr/bin/retrorun-sdl2 -c "$LAUNCH_CONFIG" \
  -d /storage/roms/bios -s "$SAVE_DIR" "$CORE_PATH" "$ROMNAME"
exit $?
