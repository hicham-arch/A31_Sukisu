#!/bin/bash

echo "this where is am : $PWD"
echo "this list file "
ls toolchain/gcc

# add SukiSU Ultra
#curl -LSs "https://raw.githubusercontent.com/SukiSU-Ultra/SukiSU-Ultra/main/kernel/setup.sh" | bash -s main
curl -LSs "https://raw.githubusercontent.com/ReSukiSU/ReSukiSU/main/kernel/setup.sh" | bash

<< 'COMMENT'
SYSCALL_HOOK_FILE="$(pwd)/drivers/kernelsu/hook/syscall_hook.h"
if [ -f "$SYSCALL_HOOK_FILE" ] && ! grep -q "__aarch64__" "$SYSCALL_HOOK_FILE"; then
    grep -q '^#if defined(__x86_64__)' "$SYSCALL_HOOK_FILE" || {
        echo "Failed to patch $SYSCALL_HOOK_FILE: expected x86_64 conditional block was not found"
        exit 1
    }
    grep -Eq 'sys_call_ptr_t[[:space:]]+syscall_fn_t[[:space:]]*;' "$SYSCALL_HOOK_FILE" || {
        echo "Failed to patch $SYSCALL_HOOK_FILE: expected syscall_fn_t typedef anchor was not found (KernelSU layout may have changed)"
        exit 1
    }
    sed -i '/sys_call_ptr_t[[:space:]]\+syscall_fn_t[[:space:]]*;/a\
#elif defined(__aarch64__)\
typedef long (*syscall_fn_t)(const struct pt_regs *);\
' "$SYSCALL_HOOK_FILE"
    grep -q '#elif defined(__aarch64__)' "$SYSCALL_HOOK_FILE" || { echo "Failed to patch $SYSCALL_HOOK_FILE: arm64 conditional branch was not inserted"; exit 1; }
    grep -Fq 'typedef long (*syscall_fn_t)(const struct pt_regs *);' "$SYSCALL_HOOK_FILE" || { echo "Failed to patch $SYSCALL_HOOK_FILE: arm64 syscall_fn_t typedef was not inserted"; exit 1; }
fi


KSU_INIT_FILE="$(pwd)/drivers/kernelsu/core/init.c"
if [ -f "$KSU_INIT_FILE" ]; then
    if grep -q 'MODULE_IMPORT_NS(VFS_internal_I_am_really_a_filesystem_and_am_NOT_a_driver);' "$KSU_INIT_FILE"; then
        sed -i 's/MODULE_IMPORT_NS(VFS_internal_I_am_really_a_filesystem_and_am_NOT_a_driver);/MODULE_IMPORT_NS("VFS_internal_I_am_really_a_filesystem_and_am_NOT_a_driver");/' "$KSU_INIT_FILE"
    fi
    grep -q 'MODULE_IMPORT_NS("VFS_internal_I_am_really_a_filesystem_and_am_NOT_a_driver");' "$KSU_INIT_FILE" || {
        echo "Failed to patch $KSU_INIT_FILE: quoted MODULE_IMPORT_NS namespace was not found (KernelSU init.c may have changed)"
        exit 1
    }
fi

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
COMMENT

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
