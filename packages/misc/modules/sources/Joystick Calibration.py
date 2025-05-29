#!/usr/bin/env python3
"""
Joystick calibration script for device tree overlay management.

This script calibrates gamepad axes by detecting movement direction
and automatically updates a compiled device tree overlay (.dtbo) file
with appropriate inversion flags.

Features:
- Press any joystick button to abort calibration
- Creates timestamped backups in /flash/overlays
- Automatically creates overlay directory if missing
- Shows calibration plan with countdown (cancelable)
- Skips overlay update if joystick is already calibrated
"""

import os
import sys
import time
import subprocess
import logging
from pathlib import Path
from collections import defaultdict
from dataclasses import dataclass
from typing import Dict, List, Tuple, Optional
from contextlib import contextmanager
from enum import Enum
from datetime import datetime
import fdt

# logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# paths
OVERLAY_PATH = Path("/flash/overlays/mipi-panel.dtbo")
PLAN_PATH    = Path("/tmp/plan")
SAMPLES_PATH = Path("/tmp/joypad-samples.txt")
BACKUP_SUFFIX = datetime.now().strftime(".backup_%Y%m%d_%H%M%S")

# settings
JOYSTICK_ID          = 0
MAX_SAMPLE_DURATION  = 8.0
AXIS_THRESHOLD       = 200
MIN_SAMPLES_REQUIRED = 5

class CalibrationError(Exception): pass

class Direction(Enum):
    POSITIVE = "pos"
    NEGATIVE = "neg"

@dataclass
class AxisConfig:
    axis_id: int
    expected_direction: Direction
    human_prompt: str

AXES_CONFIG: Dict[str, AxisConfig] = {
    "invert_absx": AxisConfig(3, Direction.NEGATIVE,
        "Push the left stick left, let go, repeat."),
    "invert_absy": AxisConfig(2, Direction.NEGATIVE,
        "Push the left stick up, let go, repeat."),
    "invert_absrx": AxisConfig(0, Direction.NEGATIVE,
        "Push the right stick left, let go, repeat."),
    "invert_absry": AxisConfig(1, Direction.NEGATIVE,
        "Push the right stick up, let go, repeat."),
}

AXIS_DESCRIPTIONS = {
    "invert_absx": "Left stick horizontal",
    "invert_absy": "Left stick vertical",
    "invert_absrx": "Right stick horizontal",
    "invert_absry": "Right stick vertical",
}

@contextmanager
def remount_flash_rw():
    subprocess.run(["mount","-o","remount,rw","/flash"], check=True)
    yield
    subprocess.run(["mount","-o","remount,ro","/flash"], check=True)



def show_dialog(msg:str,width:int=60,height:int=7):
    try:
        subprocess.run(["dialog","--infobox",msg,str(height),str(width)])
    except:
        logger.info(msg)


def ensure_directories():
    OVERLAY_PATH.parent.mkdir(parents=True, exist_ok=True)


def check_joystick_compatibility() -> bool:
    """Check if a compatible joystick is connected"""
    compatible_joysticks = [
        'r36s_Gamepad'
    ]

    try:
        process = subprocess.Popen([
            "jstest-sdl", "-l"
        ], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)

        output, _ = process.communicate(timeout=5)

        for line in output.split('\n'):
            if "Joystick Name:" in line:
                joystick_name = line.split("'")[1] if "'" in line else ""
                if joystick_name in compatible_joysticks:
                    return True

        return False

    except (subprocess.TimeoutExpired, subprocess.CalledProcessError, IndexError):
        return False


def collect_axis_samples(axis_id: int, duration: float = MAX_SAMPLE_DURATION) -> List[int]:
    """Read axis values and abort on button press"""
    values = []
    start_time = time.time()
    process = subprocess.Popen([
        "stdbuf", "-oL", "jstest-sdl", "-e", str(JOYSTICK_ID)
    ], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)

    while time.time() - start_time < duration:
        line = process.stdout.readline()
        if not line:
            continue

        if "button:" in line.lower():
            process.terminate()
            raise CalibrationError("Joystick button pressed. Aborting.")

        if f"axis: {axis_id}" in line and "value:" in line:
            try:
                value = int(line.split("value:")[-1].strip())
                if abs(value) >= AXIS_THRESHOLD:
                    values.append(value)
            except:
                pass

    process.terminate()

    if len(values) < MIN_SAMPLES_REQUIRED:
        raise CalibrationError(
            f"Insufficient samples for axis {axis_id}. Got {len(values)}."
        )
    return values


def determine_inversion_needed(values: List[int], expected_direction: Direction) -> bool:
    positive_sum = sum(value for value in values if value > AXIS_THRESHOLD)
    negative_sum = sum(-value for value in values if value < -AXIS_THRESHOLD)
    return (negative_sum > positive_sum) != (expected_direction == Direction.NEGATIVE)


def create_backup(path: Path) -> Optional[Path]:
    if path.exists():
        import shutil
        backup_path = path.parent / f"{path.name}{BACKUP_SUFFIX}"
        shutil.copy2(path, backup_path)
        return backup_path
    return None


def modify_overlay(overlay_path: Path, flags: Dict[str, int]):
    """Load or create overlay, update or add joypad fragment, and fixups."""
    # Load existing DTB or initialize new tree
    if overlay_path.exists():
        tree = fdt.parse_dtb(overlay_path.read_bytes())
    else:
        tree = fdt.FDT()
        tree.get_root()

    # Ensure __fixups__ node exists
    if tree.exist_node("/__fixups__"):
        fx = tree.get_node("/__fixups__")
    else:
        fx = fdt.Node("__fixups__")
        tree.add_item(fx)

    # Check if joypad already exists in fixups
    joypad_prop = fx.get_property("joypad")
    if joypad_prop is not None:
        raw = joypad_prop.value
        entries = raw.copy() if isinstance(raw, list) else [raw]
        # Extract fragment index from first joypad entry
        first_entry = entries[0] if entries else None
        if first_entry and first_entry.startswith("/fragment@"):
            frag_idx = int(first_entry.split("@")[1].split(":")[0])
            frag_node = tree.get_node(f"/fragment@{frag_idx}")
        else:
            frag_node = None
            frag_idx = None
    else:
        entries = []
        frag_node = None
        frag_idx = None

    # Update or create fragment
    if frag_node:
        # Update existing joypad fragment
        ov = frag_node.get_subnode("__overlay__")
        # Only modify flags that need inverting (val == 1)
        for key, val in flags.items():
            if val == 1:  # Only update properties that need inverting
                prop = key.replace("_", "-")
                ov.set_property(prop, val)
        new_idx = frag_idx
    else:
        # Create new fragment since none existed
        new_idx = 0
        while tree.exist_node(f"/fragment@{new_idx}"):
            new_idx += 1
        frag = fdt.Node(f"fragment@{new_idx}")
        frag.append(fdt.PropWords("target", 0xFFFFFFFF))
        ov = fdt.Node("__overlay__")
        for key, val in flags.items():
            prop = key.replace("_", "-")
            # Set all flags in new fragment
            ov.append(fdt.PropWords(prop, val))
        frag.append(ov)
        tree.add_item(frag)

        # Add to fixups
        entry_str = f"/fragment@{new_idx}:target:0"
        entries.append(entry_str)

    # Write back fixups
    if joypad_prop is not None:
        fx.set_property("joypad", entries)
    else:
        fx.append(fdt.PropStrings("joypad", *entries))

    # Write modified DTB overlay
    overlay_path.write_bytes(tree.to_dtb())


def display_plan_with_countdown(results: Dict[str, int], countdown_seconds: int = 10) -> Tuple[bool, bool]:
    lines = ["Calibration Results:"]
    for axis_key, inversion_flag in results.items():
        description = AXIS_DESCRIPTIONS.get(axis_key, axis_key)
        status = 'will be inverted' if inversion_flag else 'is already correct'
        lines.append(f"{description}: {status}.")

    base_message = "\n".join(lines)

    for seconds in range(countdown_seconds, 0, -1):
        if any(results.values()):
            message = f"{base_message}\nUpdating overlay in {seconds}s..."
        else:
            message = f"{base_message}\nFinishing up in {seconds}s..."
        show_dialog(message, 70, 15)
        time.sleep(1)

    return True, any(results.values())


def save_results(results: Dict[str, int], samples: Dict[str, List[int]]):
    try:
        with open(PLAN_PATH, 'w') as file:
            for axis_key, inversion_flag in results.items():
                file.write(f"{axis_key}:{inversion_flag}\n")

        with open(SAMPLES_PATH, 'w') as file:
            for axis_key, sample_values in samples.items():
                values_str = ','.join(map(str, sample_values))
                file.write(f"{axis_key}:{values_str}\n")
    except:
        pass


def main():
    if os.geteuid() != 0:
        sys.exit("Run as root.")

    # Check for compatible joystick
    if not check_joystick_compatibility():
        show_dialog("No compatible joystick found.\nPress any button to exit.", 60, 7)
        input()  # Wait for any key press
        sys.exit(1)

    ensure_directories()
    show_dialog("Starting calibration...\nPress any joystick button to abort.", 60, 7)
    time.sleep(2)

    results = {}
    samples = defaultdict(list)

    for axis_key, axis_config in AXES_CONFIG.items():
        show_dialog(axis_config.human_prompt, 60, 7)
        try:
            values = collect_axis_samples(axis_config.axis_id)
            needs_inversion = determine_inversion_needed(values, axis_config.expected_direction)
            results[axis_key] = int(needs_inversion)
            samples[axis_key] = values
            time.sleep(0.5)
        except CalibrationError as e:
            show_dialog(f"Calibration failed:\n{e}", 60, 7)
            sys.exit(1)

    save_results(results, samples)
    user_confirmed, has_changes = display_plan_with_countdown(results)

    if not user_confirmed:
        sys.exit(0)

    if not has_changes:
        for seconds in range(5, 0, -1):
            show_dialog(f"No changes needed. Finishing up in {seconds}s...", 60, 7)
            time.sleep(1)
        sys.exit(0)

    with remount_flash_rw():
        create_backup(OVERLAY_PATH)
        modify_overlay(OVERLAY_PATH, results)

    for seconds in range(10, 0, -1):
        show_dialog(f"Overlay updated successfully!\nRestart device to apply changes.\nClosing in {seconds}s...", 60, 7)
        time.sleep(1)

if __name__=="__main__": main()
