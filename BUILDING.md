# Developing and Building UnofficialOS

UnofficialOS is a fairly unique distribution as it is *built to order* and only enough of the operating system and applications are built for the purpose of booting and executing emulators and ports.  Developers and others who would like to contribute to our project should read and agree to the [Contributor Covenant Code of Conduct](https://github.com/RetroGFX/UnofficialOS/blob/main/CODE_OF_CONDUCT.md) and [Contributing to UnofficialOS](https://github.com/RetroGFX/UnofficialOS/blob/main/CONTRIBUTING.md) guides before submitting your first contribution.


## Filesystem Structure
We have a simple filesystem structure adopted from parent distributions JELOS, CoreELEC, LibreELEC, etc.

```
.
├── build.{DISTRO}-{DEVICE}.{ARCHITECTURE}
├── config
├── distributions
├── Dockerfile
├── licenses
├── Makefile
├── packages
├── post-update
├── projects
├── release
├── scripts
├── sources
└── tools
```

**build.{DISTRO}-{DEVICE}.{ARCHITECTURE}**

Build roots for each device and that devices architecture(s).  For ARM devices UnofficialOS builds and uses a 32bit root for several of the cores used in the 64bit distribution.

**config**

Contains functions utilized during the build process including architecture specific build flags, optimizations, and functions used throughout the build workflow.

**distributions**

Distributions contains distribution specific build flags and parameters and splash screens.

**Dockerfile**

Used to build the Ubuntu container used to build UnofficialOS.  The container is hosted at [https://hub.docker.com/u/unofficialos](https://hub.docker.com/u/unofficialos)

**licenses**

All of the licenses used throughout the distribution packages are hosted here.  If you're adding a package that contains a license, make sure it is available in this directory before submitting the PR.

**Makefile**

Used to build one or more UnofficialOS images, or to build and deploy the Ubuntu container.

**packages**

All of the package set that is used to develop and build UnofficialOS are hosted within the packages directory.  The package structure documentation is available in [PACKAGE.md](PACKAGE.md)

**post-update**

Anything that is necessary to be run on a device after an upgrade should be added here.  Be sure to apply a guard to test that the change needs to be executed before execution.

**projects**

Hardware specific parameters are stored in the projects folder, anything that should not be included on every device during a world build should be isolated to the specific project or device here.

**release**

The output directory for all of the build images.

**scripts**

This directory contains all of the scripts used to fetch, extract, build, and release the distribution.  Review Makefile for more details.

**sources**

As the distribution is being built, package source are fetched and hosted in this directory.  They will persist after a `make clean`.

**tools**

The tools directory contains utility scripts that can be used during the development process, including a simple tool to burn an image to a usb drive or sdcard.

## Building UnofficalOS
Building UnofficialOS requires an Ubuntu 22.04 host with approximately 200GB of free space for a single device, or 800GB of free space for a full world build.  Other Linux distributions may be used when building using Docker, however this is untested and unsupported.  We recommend building with no more than 8 cores.

### Cloning the UnofficialOS Sources
To build UnofficialOS, start by cloning the project git repository.

```
cd ~
git clone https://github.com/RetroGFX/UnofficialOS.git
```

### Selecting the Desired Branch
Once you have cloned the repo, you will want to determine if you want to build the main branch which is more stable, or the development branch which is unstable but hosts our newest features.

|Branch|Purpose|
|----|----|
|main|Stable UnofficialOS sources|
|uos-dev|Unstable UnofficialOS sources|

To check out our development branch, cd into the project directory and checkout `uos-dev`.

```
cd UnofficialOS
git checkout uos-dev
```

### Building with Docker
Building UnofficialOS is easy, the fastest and most recommended method is to instruct the build to use Docker, this is only known to work on a Linux system.  To build UnofficialOS with Docker use the table below.

|Device|Dependency|Docker Command|Manual Command|
|----|----|----|----|
|AMD64||`make docker-AMD64`|`make AMD64`|
|RK3566_BSP||`make docker-RK3566-BSP`|`make RK3566-BSP`|
|RK3566-BSP-X55||`make docker-RK3566-BSP-X55`|`make RK3566-BSP-X55`|
|RK3588||`make docker-RK3588`|`make RK3588`|
|RK3326||`make docker-RK3326`|`make RK3326`|
|RK3399||`make docker-RK3399`|`make RK3399`|
|S922X||`make docker-S922X`|`make S922X`|
|ALL DEVICES||`make docker-world`|`make world`|

> Devices that list a dependency require the dependency to be built first as that build will be used as the root of the device you are building.  This will be done automatically by the build tooling when you start a build for your device.

### Building Manually
To build UnofficialOS manually, you will need several prerequisite packages installed.

```
sudo apt install gcc make git unzip wget \
                xz-utils libsdl2-dev libsdl2-mixer-dev libfreeimage-dev libfreetype6-dev libcurl4-openssl-dev \
                rapidjson-dev libasound2-dev libgl1-mesa-dev build-essential libboost-all-dev cmake fonts-droid-fallback \
                libvlc-dev libvlccore-dev vlc-bin texinfo premake4 golang libssl-dev curl patchelf \
                xmlstarlet patchutils gawk gperf xfonts-utils default-jre python-is-python3 xsltproc libjson-perl \
                lzop libncurses5-dev device-tree-compiler u-boot-tools rsync p7zip libparse-yapp-perl \
                zip binutils-aarch64-linux-gnu dos2unix p7zip-full libvpx-dev bsdmainutils bc meson p7zip-full \
                qemu-user-binfmt zstd parted imagemagick docker.io
```

Next, build the version of UnofficialOS for your device.  See the table above for dependencies. To execute a build, run `make {device}`

```
make RK3326
```

### Building a single package
It is also possible to build individual packages.
```
PROJECT=Rockchip DEVICE=RK3326 ARCH=aarch64 ./scripts/clean busybox
PROJECT=Rockchip DEVICE=RK3326 ARCH=aarch64 ./scripts/build busybox
```

> Note: Emulation Station package build requires additional steps because its source code located in a separate repository, see instructions inside, [link](https://github.com/RetroGFX/UnofficialOS/blob/main/packages/ui/emulationstation/package.mk).

### Special env variables
For development build, you can use the following env variables to customize the image. Some of them can be included in your `.bashrc` startup shell script.

**SSH keys**
```
export LOCAL_SSH_KEYS_FILE=~/.ssh/unofficialos/authorized_keys
```
**WiFi SSID and password**
```
export LOCAL_WIFI_SSID=MYWIFI
export LOCAL_WIFI_KEY=secret
```

**Screenscraper, GamesDB, and RetroAchievements**

To enable Screenscraper, GamesDB, and RetroAchievements, register at each site and apply the api keys in `${HOME}/.UnofficialOS/options` or add them as environment variables. Unsetting one of the variables will disable it in EmulationStation. This configuration is picked up by EmulationStation during the build.

```
# Apply for a Screenscraper API Key here: https://www.screenscraper.fr/forumsujets.php?frub=12&numpage=0
export SCREENSCRAPER_DEV_LOGIN="devid=DEVID&devpassword=DEVPASSWORD"
# Apply for a GamesDB API Key here: https://forums.thegamesdb.net/viewforum.php?f=10
export GAMESDB_APIKEY="APIKEY"
# Find your Cheevos Web API key here: https://retroachievements.org/controlpanel.php
export CHEEVOS_DEV_LOGIN="z=RETROACHIEVEMENTSUSERNAME&y=APIKEYID"
```

### Creating a patch for a package
It is common to have imported package source code modifed to fit the use case. It's recommended to use a special shell script to built it in case you need to iterate over it. See below.

```
cd sources/wireguard-linux-compat
tar -xvJf wireguard-linux-compat-v1.0.20211208.tar.xz
mv wireguard-linux-compat-v1.0.20211208 wireguard-linux-compat
cp -rf wireguard-linux-compat wireguard-linux-compat.orig

# Make your changes to wireguard-linux-compat
mkdir -p ../../packages/network/wireguard-linux-compat/patches/RG503
# run from the sources dir
diff -rupN wireguard-linux-compat wireguard-linux-compat.orig >../../packages/network/wireguard-linux-compat/patches/RG503/mychanges.patch
```

### Creating a patch for a package using git
If you are working with a git repository, building a patch for the distribution is simple.  Rather than using `diff`, use `git diff`.
```
cd sources/emulationstation/emulationstation-098226b/
# Make your changes to EmulationStation
vim/emacs/vscode/notepad.exe
# Make the patch directory
mkdir -p ../../../packages/ui/emulationstation/patches
# Run from the sources dir
git diff >../../../packages/ui/emulationstation/patches/005-mypatch.patch
```

After patch is generated, one can rebuild an individual package, see section above. The build system will automatically pick up patch files from `patches` directory. For testing, one can either copy the built binary to the console or flash the whole image to the SD card.

### Building an image with your patch
If you already have a build for your device made using the above process, it's simple to shortcut the build process and create an image to test your changes quickly using the process below.
```
# Update the package version for a new package, or apply your patch as above.
vim/emacs/vscode/notepad.exe
# Export the variables needed to complete your build, we'll assume you are building for the RG552, update the device to match your configuration.
export DISTRO=UnofficialOS OS_VERSION=$(date +%Y%m%d) BUILD_DATE=$(date)
export PROJECT=Rockchip ARCH=aarch64 DEVICE=RK3399
# Clean the package you are building.
./scripts/clean emulationstation
# Build the package.
./scripts/build emulationstation
# Install the package into the build root.
./scripts/install emulationstation
# Generate an image with your new package.
./scripts/image mkimage
```