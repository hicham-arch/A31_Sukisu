#!/bin/bash

echo "this where is am : $PWD"
echo "this list file "
ls toolchain/gcc

# add SukiSU Ultra
curl -LSs "https://raw.githubusercontent.com/SukiSU-Ultra/SukiSU-Ultra/main/kernel/setup.sh" | bash -s nongki

export CROSS_COMPILE=$GITHUB_WORKSPACE/toolchains/gcc/bin/aarch64-linux-android-
export CC=$GITHUB_WORKSPACE/toolchain/clang/host/linux-x86/clang-r383902/bin/clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export ARCH=arm64
export ANDROID_MAJOR_VERSION=r

export KCFLAGS=-w
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y

make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y a31_sukiSu_defconfig
make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y

#cp out/arch/arm64/boot/Image $(pwd)/arch/arm64/boot/Image
