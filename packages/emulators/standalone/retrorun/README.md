# Retrorun

- Retrorun 3.2.3 SDL2 libretro frontend for Dreamcast.
- Images: RK3326, RK3566, RK3566-BSP and RK3399.
- Cores: Flycast, Flycast2021 and flycast2021le. Existing defaults are retained.
- Video: automatic SDL driver selection. Audio: PulseAudio/PipeWire.
- Configuration: `/storage/.config/retrorun/retrorun.cfg`.
- EmulationStation options override this configuration for the current launch.
- Saves: `/storage/roms/savestates/retrorun/dreamcast`.
- Tested on RG353M with UnofficialOS: ChuChu Rocket, controls, audio and exit.
- Other devices and a complete firmware build are untested.

Build in a configured UnofficialOS environment:

```sh
./scripts/build retrorun
```
