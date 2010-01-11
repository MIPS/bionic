/****************************************************************************
 ****************************************************************************
 ***
 ***   This header was automatically generated from a Linux kernel header
 ***   of the same name, to make information necessary for userspace to
 ***   call into the kernel available to libc.  It contains only constants,
 ***   structures, and macros generated from the original header, and thus,
 ***   contains no copyrightable information.
 ***
 ****************************************************************************
 ****************************************************************************/
#ifndef _ASM_PAGE_H
#define _ASM_PAGE_H

#ifdef PAGE_SHIFT
#define PAGE_SIZE (1UL << PAGE_SHIFT)
#define PAGE_MASK (~((1 << PAGE_SHIFT) - 1))
#else
/*
 * Determine page size parameters at runtime
 * Use getpagesize() in preference to sysconf() because
 * it's implemented as an inline variable read
 */
#include <unistd.h>
#include <string.h>
#define PAGE_SIZE_DYNAMIC
#define PAGE_SIZE getpagesize()
#define PAGE_SHIFT (ffs(getpagesize())-1)
#define PAGE_MASK (~(PAGE_SIZE - 1))
#endif

#endif
