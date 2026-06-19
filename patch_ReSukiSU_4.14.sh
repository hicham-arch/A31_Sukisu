#!/bin/bash

echo "=== Applying ReSukiSU Manual Hooks for Kernel 4.14 (SED METHOD) ==="

# 1. fs/stat.c
sed -i '/SYSCALL_DEFINE4(newfstatat,/i \
#ifdef CONFIG_KSU_MANUAL_HOOK\
__attribute__((hot))\
extern int ksu_handle_stat(int *dfd, const char __user **filename_user, int *flags);\
extern void ksu_handle_newfstat_ret(unsigned int *fd, struct stat __user **statbuf_ptr);\
#if defined(__ARCH_WANT_STAT64) || defined(__ARCH_WANT_COMPAT_STAT64)\
extern void ksu_handle_fstat64_ret(unsigned long *fd, struct stat64 __user **statbuf_ptr);\
#endif\
#endif\
' fs/stat.c

sed -i '/error = vfs_fstatat(dfd, filename, &stat, flag);/i \
#ifdef CONFIG_KSU_MANUAL_HOOK\
\tksu_handle_stat(&dfd, &filename, &flag);\
#endif' fs/stat.c

sed -i '/error = cp_new_stat(&stat, statbuf);/a \
#ifdef CONFIG_KSU_MANUAL_HOOK\
\tksu_handle_newfstat_ret(&fd, &statbuf);\
#endif' fs/stat.c

sed -i '/error = cp_new_stat64(&stat, statbuf);/a \
#ifdef CONFIG_KSU_MANUAL_HOOK\
\tksu_handle_fstat64_ret(&fd, &statbuf);\
#endif' fs/stat.c


# 2. fs/exec.c
sed -i '/int do_execve(struct filename \*filename,/i \
#ifdef CONFIG_KSU_MANUAL_HOOK\
__attribute__((hot))\
extern int ksu_handle_execveat(int *fd, struct filename **filename_ptr, void *argv, void *envp, int *flags);\
#endif\
' fs/exec.c

sed -i '/return do_execveat_common(AT_FDCWD, filename, argv, envp, 0);/i \
#ifdef CONFIG_KSU_MANUAL_HOOK\
\tksu_handle_execveat((int *)AT_FDCWD, &filename, &argv, &envp, 0);\
#endif' fs/exec.c


# 3. fs/open.c
sed -i '/SYSCALL_DEFINE3(faccessat,/i \
#ifdef CONFIG_KSU_MANUAL_HOOK\
__attribute__((hot))\
extern int ksu_handle_faccessat(int *dfd, const char __user **filename_user, int *mode, int *flags);\
#endif\
' fs/open.c

sed -i '/if (mode & ~S_IRWXO)/i \
#ifdef CONFIG_KSU_MANUAL_HOOK\
\tksu_handle_faccessat(&dfd, &filename, &mode, NULL);\
#endif' fs/open.c


# 4. kernel/reboot.c
sed -i '/SYSCALL_DEFINE4(reboot,/i \
#ifdef CONFIG_KSU_MANUAL_HOOK\
extern int ksu_handle_sys_reboot(int magic1, int magic2, unsigned int cmd, void __user **arg);\
#endif\
' kernel/reboot.c

sed -i '/if (!ns_capable(pid_ns->user_ns, CAP_SYS_BOOT))/i \
#ifdef CONFIG_KSU_MANUAL_HOOK\
\tksu_handle_sys_reboot(magic1, magic2, cmd, &arg);\
#endif' kernel/reboot.c


# 5. drivers/input/input.c
sed -i '/void input_event(/i \
#ifdef CONFIG_KSU_MANUAL_HOOK\
extern bool ksu_input_hook __read_mostly;\
extern __attribute__((cold)) int ksu_handle_input_handle_event(unsigned int *type, unsigned int *code, int *value);\
#endif\
' drivers/input/input.c

sed -i '/if (is_event_supported(type, dev->evbit, EV_MAX))/i \
#ifdef CONFIG_KSU_MANUAL_HOOK\
\tif (unlikely(ksu_input_hook))\
\t\tksu_handle_input_handle_event(&type, &code, &value);\
#endif' drivers/input/input.c


# 6. kernel/sys.c
sed -i '/SYSCALL_DEFINE3(setresuid,/i \
#ifdef CONFIG_KSU_MANUAL_HOOK\
extern int ksu_handle_setresuid(uid_t ruid, uid_t euid, uid_t suid);\
#endif\
' kernel/sys.c

sed -i '/kruid = make_kuid(ns, ruid);/i \
#ifdef CONFIG_KSU_MANUAL_HOOK\
\t(void)ksu_handle_setresuid(ruid, euid, suid);\
#endif' kernel/sys.c


# 7. fs/read_write.c
sed -i '/SYSCALL_DEFINE3(read,/i \
#ifdef CONFIG_KSU_MANUAL_HOOK\
extern bool ksu_init_rc_hook __read_mostly;\
extern __attribute__((cold)) int ksu_handle_sys_read(unsigned int fd, char __user **buf_ptr, size_t *count_ptr);\
#endif\
' fs/read_write.c

sed -i '/if (f.file) {/i \
#ifdef CONFIG_KSU_MANUAL_HOOK\
\tif (unlikely(ksu_init_rc_hook))\
\t\tksu_handle_sys_read(fd, &buf, &count);\
#endif' fs/read_write.c


# 8. Exporting Static Symbols safely
echo "--> Exporting static symbols..."
sed -i 's/static ssize_t (\*write_op\[\])/ssize_t (\*write_op\[\])/g' security/selinux/selinuxfs.c || true
sed -i 's/static const struct file_operations sel_handle_status_ops/const struct file_operations sel_handle_status_ops/g' security/selinux/selinuxfs.c || true
sed -i 's/static struct page \*selinux_status_page;/struct page \*selinux_status_page;/g' security/selinux/ss/services.c || true
sed -i 's/static DEFINE_MUTEX(selinux_status_lock);/DEFINE_MUTEX(selinux_status_lock);/g' security/selinux/ss/services.c || true
sed -i 's/static DEFINE_RWLOCK(policy_rwlock);/DEFINE_RWLOCK(policy_rwlock);/g' security/selinux/ss/services.c || true
sed -i 's/static DEFINE_MUTEX(sel_mutex);/DEFINE_MUTEX(sel_mutex);/g' security/selinux/selinuxfs.c || true
sed -i 's/static struct security_operations selinux_ops/struct security_operations selinux_ops/g' security/selinux/hooks.c || true
sed -i 's/static void security_dump_masked_av/void security_dump_masked_av/g' security/selinux/ss/services.c || true
sed -i 's/static void context_struct_compute_av/void context_struct_compute_av/g' security/selinux/ss/services.c || true

echo "=== Patch Application Finished ==="
