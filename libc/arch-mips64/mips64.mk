# 64-bit mips.

libc_bionic_src_files_mips64 += \
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

libc_bionic_src_files_exclude_mips64 += \
    bionic/strchr.cpp \
    bionic/strnlen.c \

libc_openbsd_src_files_exclude_mips64 += \
    upstream-openbsd/lib/libc/string/memchr.c \
    upstream-openbsd/lib/libc/string/memmove.c \
    upstream-openbsd/lib/libc/string/strcpy.c \
    upstream-openbsd/lib/libc/string/strncmp.c \

#
# Inherently architecture-specific code.
#

libc_bionic_src_files_mips64 += \
    arch-mips64/bionic/__bionic_clone.S \
    arch-mips64/bionic/_exit_with_stack_teardown.S \
    arch-mips64/bionic/setjmp.S \
    arch-mips64/bionic/syscall.S \
    arch-mips64/bionic/vfork.S \
    arch-mips64/bionic/stat.cpp \

libc_crt_target_cflags_mips64 := \
    $($(my_2nd_arch_prefix)TARGET_GLOBAL_CFLAGS) \
    -I$(LOCAL_PATH)/arch-mips64/include \

libc_crt_target_crtbegin_file_mips64 := \
    $(LOCAL_PATH)/arch-mips64/bionic/crtbegin.c \

libc_crt_target_crtbegin_so_file_mips64 := \
    $(LOCAL_PATH)/arch-common/bionic/crtbegin_so.c \

libc_crt_target_so_cflags_mips64 := \
    -fPIC \

libc_crt_target_ldflags_mips64 := \
    -melf64ltsmip \
