/*
 * Copyright (C) 2012 The Android Open Source Project
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *  * Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include "../../bionic/libc_init_common.h"
#include <stddef.h>
#include <stdint.h>

#define SECTION(name) __attribute__((__section__(name)))
SECTION(".preinit_array") void (*__PREINIT_ARRAY__)(void) = (void (*)(void)) -1;
SECTION(".init_array") void (*__INIT_ARRAY__)(void) = (void (*)(void)) -1;
SECTION(".fini_array") void (*__FINI_ARRAY__)(void) = (void (*)(void)) -1;
#undef SECTION

#if defined(__mips__)
__LIBC_HIDDEN__
#else
__used static
#endif
void _start_main(void* raw_args) {
  structors_array_t array;
  array.preinit_array = &__PREINIT_ARRAY__;
  array.init_array = &__INIT_ARRAY__;
  array.fini_array = &__FINI_ARRAY__;

  __libc_init(raw_args, NULL, &main, &array);
}

#define PRE ".text; .global _start; .type _start,%function; _start:"
#define POST "; .size _start, .-_start"

#if defined(__aarch64__)
__asm__(PRE "mov x0,sp; b _start_main" POST);
#elif defined(__arm__)
__asm__(PRE "mov r0,sp; b _start_main" POST);
#elif defined(__i386__)
__asm__(PRE "movl %esp,%eax; andl $~0xf,%esp; subl $12,%esp; pushl %eax; calll _start_main" POST);
#elif defined(__x86_64__)
__asm__(PRE "movq %rsp,%rdi; andq $~0xf,%rsp; callq _start_main" POST);
#elif defined(__mips__) && !defined(__LP64__)
__asm__ (
"       .set push                   \n"
"                                   \n"
"       .text                       \n"
"       .align  4                   \n"
"       .type __start,@function     \n"
"       .type _start,@function      \n"
"       .globl __start              \n"
"       .globl  _start              \n"
"                                   \n"
"       .ent    __start             \n"
"__start:                           \n"
"       .set noreorder              \n"
"       nop                         \n"
"       .set reorder                \n"
"                                   \n"
" _start:                           \n"
"       .frame   $sp,32,$ra         \n"
"       .mask   0x80000000,-4       \n"
"                                   \n"
"       .set noreorder              \n"
"       bal     1f                  \n"
"       nop                         \n"
"1:                                 \n"
"       .cpload $ra                 \n"
"       .set reorder                \n"
"                                   \n"
"       move    $a0, $sp            \n"
"       addiu   $sp, $sp, (-32)     \n"
"       sw      $0, 28($sp)         \n"
"       la      $t9, _start_main    \n"
"       jalr    $t9                 \n"
"                                   \n"
"2:     b       2b                  \n"
"       .end    __start             \n"
"                                   \n"
"       .set pop                    \n"
);
#elif defined(__mips__) && defined(__LP64__)
__asm__ (
"       .set push                   \n"
"                                   \n"
"       .text                       \n"
"       .align  4                   \n"
"       .type __start,@function     \n"
"       .type _start,@function      \n"
"       .globl __start              \n"
"       .globl  _start              \n"
"                                   \n"
"       .ent    __start             \n"
"__start:                           \n"
"       .set noreorder              \n"
"       nop                         \n"
"       .set reorder                \n"
"                                   \n"
" _start:                           \n"
"       .frame   $sp,32,$0          \n"
"       .mask   0x80000000,-8       \n"
"                                   \n"
"       move    $a0, $sp            \n"
"       daddiu  $sp, $sp, -32       \n"
"                                   \n"
"       .set noreorder              \n"
"       bal     1f                  \n"
"       nop                         \n"
"1:                                 \n"
"       .cpsetup $ra,16,1b          \n"
"       .set reorder                \n"
"                                   \n"
"       sd      $0, 24($sp)         \n"
"       jal     _start_main         \n"
"                                   \n"
"2:     b       2b                  \n"
"       .end    __start             \n"
"                                   \n"
"       .set pop                    \n"
);
#else
#error unsupported architecture
#endif

#undef PRE
#undef POST

#include "__dso_handle.h"
#include "atexit.h"
#include "pthread_atfork.h"
#ifdef __i386__
# include "../../arch-x86/bionic/__stack_chk_fail_local.h"
#endif
