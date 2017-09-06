/*
 * Copyright (c) 2017 Imagination Technologies.
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *      * Redistributions of source code must retain the above copyright
 *        notice, this list of conditions and the following disclaimer.
 *      * Redistributions in binary form must reproduce the above copyright
 *        notice, this list of conditions and the following disclaimer
 *        in the documentation and/or other materials provided with
 *        the distribution.
 *      * Neither the name of Imagination Technologies nor the names of its
 *        contributors may be used to endorse or promote products derived
 *        from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <private/bionic_asm.h>

#ifdef __ANDROID__
LEAF(fmaf, 0)
#else
LEAF(fmaf)
#endif
#if __mips_isa_rev >= 6
#if __mips64
    mov.s   $f0, $f14
    maddf.s $f0, $f12, $f13
    jrc     $31
#else
    mtc1    $6,  $f0
    maddf.s $f0, $f12, $f14
    jrc     $31
#endif
#elif __mips_isa_rev <= 1
    addiu   sp,   sp,   -8
    mtc1    $6,   $f0
    cvt.d.s $f12, $f12          /* convert to double float */
    li      $3,   0x10000000    /* const to check halfway case */
    cvt.d.s $f14, $f14          /* convert to double float */
    mul.d   $f6,  $f12, $f14
    cvt.d.s $f4,  $f0           /* convert to double float */
    add.d   $f0,  $f4,  $f6
    sdc1    $f0,  0(sp)
    lw      $8,   0(sp)
    sll     $4,   $8,   3
    srl     $8,   $8,   3

    .set    noreorder
    .set    nomacro
    beq     $4, $3, l_inexact
    li      $3, 0x7ff00000      /* const to check NaN */
l_return:
    addiu   sp,  sp, 8
    jr      $31
    cvt.s.d $f0, $f0            /* convert back to single float */

l_inexact:
    lw      $9, 4(sp)
    and     $2, $9,  $3
    beq     $2, $3,  l_return
    nop

    sub.d   $f8,   $f0, $f6
    c.eq.d  $fcc0, $f4, $f8
    bc1t    $fcc0, l_return
    nop

    cfc1    $2, $31             /* Get rounding mode */
    bne     $2, $0, l_return

    li      $4,  1
    ctc1    $4,  $31            /* Set rounding mode to 1 (FE_TOWARDZERO) */
    add.d   $f6, $f4, $f6
    ctc1    $0,  $31            /* Set rounding mode to 0 (FE_TONEAREST) */

    c.eq.d  $fcc1, $f6, $f0
    bc1f    $fcc1, l_return1
    nop

    mfc1    $2, $f6
    addiu   $2, $8, 1
    mtc1    $2, $f6
l_return1:
    addiu   sp,  sp,  8
    jr      $31
    cvt.s.d $f0, $f6            /* convert back to single float */
#else
    mtc1    $6,   $f0
    cvt.d.s $f12, $f12          /* convert to double float */
    li      $3,   0x10000000    /* const to check halfway case */
    cvt.d.s $f14, $f14          /* convert to double float */
    mul.d   $f6,  $f12, $f14
    cvt.d.s $f4,  $f0           /* convert to double float */
    add.d   $f0,  $f4,  $f6
    mfc1    $8,   $f0
    ext     $4,   $8,   0,  29

    .set    noreorder
    .set    nomacro
    beq     $4, $3, l_inexact
    mfhc1   $9, $f0
l_return:
    jr      $31
    cvt.s.d $f0, $f0

l_inexact:
    li      $3, 0x7ff00000      /* const to check NaN */
    and     $2, $9, $3
    beq     $2, $3, l_return
    nop

    sub.d   $f8,   $f0, $f6
    c.eq.d  $fcc0, $f4, $f8
    bc1t    $fcc0, l_return
    nop

    cfc1    $2, $31             /* Get rounding mode */
    bne     $2, $0, l_return

    li      $4,  1
    ctc1    $4,  $31            /* Set rounding mode to 1 (FE_TOWARDZERO) */
    add.d   $f6, $f4, $f6
    ctc1    $0,  $31            /* Set rounding mode to 0 (FE_TONEAREST) */

    c.eq.d  $fcc1, $f6, $f0
    bc1f    $fcc1, l_return1
    nop

    mfc1    $2, $f6
    addiu   $2, $8, 1
    mtc1    $2, $f6
l_return1:
    jr      $31
    cvt.s.d $f0, $f6            /* convert back to single float */
#endif
    .set    macro
    .set    reorder
END(fmaf)
