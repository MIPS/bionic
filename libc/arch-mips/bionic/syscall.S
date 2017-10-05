/*
 * Copyright (C) 2013 The Android Open Source Project
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

#include <private/bionic_asm.h>

/*
 * The caller is only required to allocate 16 bytes of stack for a0-a3.
 * syscall has up to 7 arguments, so we need space for the extra three arguments.
 * This equals to 12 additional bytes, but set 16 for proper stack alignment.
 */
#define STACKSIZE 4*4

ENTRY(syscall)
    .set noreorder
    .cpload t9
    move    v0, a0
    move    a0, a1
    move    a1, a2
    move    a2, a3
    lw      a3, 16(sp)
    lw      t0, 20(sp)
    lw      t1, 24(sp)
    lw      t2, 28(sp)
    subu    sp, STACKSIZE
    sw      t0, 16(sp)
    sw      t1, 20(sp)
    sw      t2, 24(sp)
    syscall
    addu    sp, STACKSIZE
    bnez    a3, 1f
    move    a0, v0
    j       ra
    nop
1:
    la      t9,__set_errno_internal
    j       t9
    nop
    .set reorder
END(syscall)
