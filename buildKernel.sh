#!/bin/bash

echo "this where is am : $PWD"
echo "this list file "
ls toolchain/gcc

# add SukiSU Ultra
curl -LSs "https://raw.githubusercontent.com/SukiSU-Ultra/SukiSU-Ultra/main/kernel/setup.sh" | bash -s nongki

KPM_FILE="$(pwd)/drivers/kernelsu/kpm/kpm.c"
if [ -f "$KPM_FILE" ] && ! grep -q "KSU_ACCESS_OK" "$KPM_FILE"; then
    sed -i 's/access_ok(/KSU_ACCESS_OK(/g' "$KPM_FILE"
    sed -i '/#include "compact.h"/a\
\
#if LINUX_VERSION_CODE < KERNEL_VERSION(5, 0, 0)\
#define KSU_ACCESS_OK(addr, size) access_ok(VERIFY_READ, (void __user *)(addr), (size))\
#else\
#define KSU_ACCESS_OK(addr, size) access_ok((void __user *)(addr), (size))\
#endif\
' "$KPM_FILE"
fi

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
