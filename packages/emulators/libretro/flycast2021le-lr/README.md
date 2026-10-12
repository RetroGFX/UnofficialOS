# flycast2021le

- Additional AArch64/GLES libretro core; existing Flycast cores are retained.
- Source URL: https://github.com/navy1978/flycast2022-lowend.
- Library: `Flycast 2021 LE`.
- Binary: `flycast2021le_libretro.so`; options: `flycast2021le_*`.
- Handheld defaults: 320x240, experimental options disabled.
- Retrorun can apply its existing per-game catalog overrides.
- Available for Dreamcast with Retrorun and RetroArch.
- Cortex-A35/A55 builds passed; ChuChu Rocket tested on RG353M/UnofficialOS.
- Other devices and a complete firmware build are untested.

Build in a configured UnofficialOS environment:

```sh
./scripts/build flycast2021le-lr
```
