# A31 Sukisu Kernel 📱
[![GitHub Release](https://img.shields.io/github/v/release/hicham-arch/A31_Sukisu?style=flat-square)](https://github.com/hicham-arch/A31_Sukisu/releases)
[![Language](https://img.shields.io/badge/Language-C%20%7C%20Makefile-blue?style=flat-square)](#)

> **KernelSU (ReSukiSU) integrated custom kernel for the Samsung Galaxy A31 series (A31X / SM-A315F).**
> 
This repository contains the Linux kernel source code for the Samsung Galaxy A31, pre-patched with KernelSU (specifically the ReSukiSU implementation for the 4.14 kernel). It provides a root solution operating directly in kernel space for maximum stealth, efficiency, and module support.
## ✨ Features
 * **KernelSU Integrated:** Root access managed safely and directly in kernel space.
 * **ReSukiSU Patches:** Tailored patches specifically for Linux Kernel 4.14 (patch_ReSukiSU_4.14.sh).
 * **Optimized Compilation:** Custom build scripts (buildKernel.sh) included for automated deployment.
 * **CI/CD Ready:** Integrated GitHub Actions workflow for building kernel releases automatically.
## ⚙️ Prerequisites
To build this kernel from source, you will need a Linux environment (Ubuntu 20.04 LTS or newer recommended) with standard kernel build dependencies installed:
```bash
sudo apt-get update
sudo apt-get install git ccache automake flex lzop bison gperf build-essential zip curl zlib1g-dev g++-multilib libxml2-utils bzip2 libbz2-dev libbz2-1.0 libghc-bzlib-dev squashfs-tools pngcrush schedtool dpkg-dev liblz4-tool make optipng maven libssl-dev pwgen libswitch-perl policycoreutils minicom libxml-sax-base-perl libxml-simple-perl bc libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev xsltproc unzip

```
## 🛠️ How to Build
 1. **Clone the repository:**
   ```bash
   git clone https://github.com/hicham-arch/A31_Sukisu.git
   cd A31_Sukisu
   
   ```
 2. **Configure your environment:**
   Review and modify config.env if you need to adjust toolchain paths, defconfig target, or build parameters.
 3. **Compile the kernel:**
   Run the included build script to begin compilation:
   ```bash
   bash buildKernel.sh
   
   ```
   *Alternatively, if you prefer to use pre-compiled binaries, download the latest tarball directly from the Releases section.*
## 📦 Installation via Odin
> ⚠️ **Warning:** Unlocking your bootloader and flashing custom binary images will void your warranty and trip Knox. Proceed at your own risk!
> 
### Step 1: Prepare the Tar Archive
Odin cannot flash a raw boot.img directly; it must be packaged inside a .tar archive.
 * If you downloaded a pre-made boot.img from Releases, pack it into boot.tar
 * If you built it yourself and have a raw boot.img, pack it into a tarball using Linux/WSL:
   ```bash
   tar -cvf boot.tar boot.img
   
   ```
### Step 2: Flash with Odin
 1. Download and launch **Odin** (v3.14.4 or newer recommended) on a Windows PC.
 2. Turn off your Samsung Galaxy A31 entirely.
 3. Boot into **Download Mode**: Hold down Volume Up + Volume Down and plug the device into your PC via a USB cable. Press Volume Up to bypass the warning screen.
 4. Ensure Odin detects your device (one of the ID:COM boxes should light up blue/cyan).
 5. Click on the **AP** slot button in Odin and select your boot.tar file.
 6. Navigate to the **Options** tab in Odin and uncheck **Auto Reboot** (recommended to avoid boot loops before handling the recovery transition).
 7. Click **Start** to initiate the flashing process.
### Step 3: Post-Flash Setup
 1. Once Odin displays a green PASS message, force reboot your phone manually by holding Volume Down + Power.
 2. Once the system finishes booting, download and install the official [ReSukiSU Manager App](https://github.com/ReSukiSU/ReSukiSU/actions/runs/28589959781/artifacts/8038830692) to configure your root access and manage modules.
## 🤝 Credits & Acknowledgements
 * Samsung Open Source for providing the base stock kernel source.
 * KernelSU by tiann.
 * ReSukiSU for the kernel 4.14 backport implementation.
 * The global Linux Kernel development community.
## 📝 License
This project is licensed under the GNU General Public License v2.0 (GPL-2.0), following the upstream licensing mandates of the Linux kernel.
