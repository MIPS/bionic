# 32-bit mips.

libc_bionic_src_files_mips += \
    arch-mips/string/memcmp.c \
    arch-mips/string/memcpy.c \
    arch-mips/string/memset.S \
    arch-mips/string/memmove.c \
    arch-mips/string/memchr.c \
    arch-mips/string/strchr.c \
    arch-mips/string/strcmp.S \
    arch-mips/string/strcpy.c \
    arch-mips/string/strncmp.S \
    arch-mips/string/strlen.c \
    arch-mips/string/strnlen.c \

libc_bionic_src_files_exclude_mips += \
    bionic/strchr.cpp \
    bionic/strnlen.c \

libc_openbsd_src_files_exclude_mips += \
    upstream-openbsd/lib/libc/string/memchr.c \
    upstream-openbsd/lib/libc/string/memmove.c \
    upstream-openbsd/lib/libc/string/strcpy.c \
    upstream-openbsd/lib/libc/string/strncmp.c \

#
# Inherently architecture-specific code.
#

libc_bionic_src_files_mips += \
    arch-mips/bionic/__bionic_clone.S \
    arch-mips/bionic/bzero.S \
    arch-mips/bionic/cacheflush.cpp \
    arch-mips/bionic/_exit_with_stack_teardown.S \
    arch-mips/bionic/setjmp.S \
    arch-mips/bionic/syscall.S \
    arch-mips/bionic/vfork.S \
    arch-mips/bionic/libgcc_compat.c \

libc_crt_target_cflags_mips := \
    $($(my_2nd_arch_prefix)TARGET_GLOBAL_CFLAGS) \
    -I$(LOCAL_PATH)/arch-mips/include

libc_crt_target_crtbegin_file_mips := \
    $(LOCAL_PATH)/arch-mips/bionic/crtbegin.c

libc_crt_target_crtbegin_so_file_mips := \
    $(LOCAL_PATH)/arch-common/bionic/crtbegin_so.c

libc_crt_target_so_cflags_mips := \
    -fPIC

libc_crt_target_ldflags_mips := \
    -melf32ltsmip
