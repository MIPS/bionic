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

#include <float.h>
#include <private/bionic_asm.h>

#ifdef __ANDROID__
LEAF(trunc, 0)
#else
LEAF(trunc)
#endif
#if __mips64 || __mips_isa_rev >= 6
    li         t1,  0x43400000  /* const to check inf, NaN or integer */
    trunc.l.d  $f2, $f12        /* Calculate trunc without bothering exceptions */
    mthc1      t1,  $f0         /* move const to FP reg 0 */
    abs.d      $f4, $f12        /* Absolute value */
    cmp.lt.d   $f6, $f4, $f0    /* Check if input > const */
    .set    noreorder
    .set    nomacro
    bc1eqz     $f6, 1f          /* if input > const, return input as it is */
    sub.d      $f4, $f4
    cmp.eq.d   $f6, $f4, $f2
    bc1nez     $f6, 2f          /* Handles +/-0 case */
    nop
    jr         ra
    cvt.d.l    $f0, $f2         /* Convert to double in $f0 */
1:
    jr         ra
    mov.d      $f0, $f12        /* Return input as is */
2:
    jr         ra
    mul.d      $f0, $f2, $f12   /* +/-0 */
    .set    macro
    .set    reorder
#elif __mips_isa_rev == 1
    addiu   sp,   sp, -8
    sdc1    $f12, 0(sp)
    lw      $4,   4(sp)
    lw      $5,   0(sp)
    srl     $8,   $4, 20
    andi    $8,   0x7ff
    addiu   $6,   $8, -1023     /* subtract exponent bias */
    slt     $3,   $6, 20

    .set    noreorder
    .set    nomacro
    beq     $3, $0, l_block_52
    slt     $2, $6, 52

    /* start: block for exponent < 20 */
    bltz    $6, l_exit_20
    li      $2, 0x80000000
    .set    macro
    .set    reorder

    li      $3, 0xf0000
    ori     $3, $3, 0xffff      /* set 20 bits */
    sra     $3, $3, $6          /* right shift by exponent */
    and     $2, $3, $4
    or      $5, $2, $5
    .set    noreorder
    .set    nomacro
    beq     $5,  $0,  l_exit
    mov.d   $f0, $f12
    .set    macro
    .set    reorder

    nor     $3,  $0,   $3
    sw      $0,  0(sp)
    and     $4,  $4,   $3
    sw      $4,  4(sp)
    ldc1    $f0, 0(sp)
l_exit:
    addiu   sp,  sp,   8
    jr      $31
    /* end: block for exponent < 20 */


    /* start: l_block_52; Handles NaN, Infinity and integral */
l_block_52:
    .set    noreorder
    .set    nomacro
    bne     $2,  $0,  l_exit_block_52
    addiu   $7,  $8,  -1043
    li      $2,  1024           /* const to check inf or NaN */
    bne     $6,  $2,  l_exit
    mov.d   $f0, $f12           /* integral */
    addiu   sp,  sp,  8
    jr      $31
    add.d   $f0, $f12, $f12     /* inf or NaN */
    .set    macro
    .set    reorder
    /* end: l_block_52 */

l_exit_block_52:
    li      $3, -1              /* 0xffffffff */
    srl     $7, $3, $7
    and     $3, $7, $5

    .set    noreorder
    .set    nomacro
    beq     $3,  $0,  l_exit
    mov.d   $f0, $f12           /* integral */
    .set    macro
    .set    reorder

    nor     $7,  $0,  $7
    and     $7,  $5,  $7
    sw      $7,  0(sp)
    sw      $4,  4(sp)
    ldc1    $f0, 0(sp)
    addiu   sp,  sp,  8
    jr $31

l_exit_20:
    and     $2,  $4
    sw      $0,  0(sp)
    sw      $2,  4(sp)
    ldc1    $f0, 0(sp)
    addiu   sp,  sp,  8
    jr      $31
    .set    macro
    .set    reorder
#else
    /* mips32 isa_rev > 1 && isa_rev < 6 */
    mfhc1   $4, $f12            /* move high part in G.P. register */
    mfc1    $5, $f12            /* move low part in G.P. register */
    ext     $8, $4,  20,  11    /* extract 11 bits exponent field */
    addiu   $6, $8,  -1023      /* subtract exponent bias */

    slt     $3, $6, 20
    .set    noreorder
    .set    nomacro
    beq     $3, $0, l_block_52
    slt     $2, $6, 52

    /* start: block for exponent < 20 */
    bltz    $6,  l_exit_20
    sub.d   $f0, $f12, $f12
    .set    macro
    .set    reorder

    li      $3, 0xf0000
    ori     $3, $3, 0xffff      /* set 20 bits */
    sra     $3, $3, $6          /* right shift by exponent */
    and     $2, $3, $4
    or      $5, $2, $5
    .set    noreorder
    .set    nomacro
    beq     $5,  $0,  l_exit
    mov.d   $f0, $f12
    .set    macro
    .set    reorder

    nor     $3, $0, $3
    mtc1    $0, $f0
    and     $4, $4, $3
    .set    noreorder
    .set    nomacro
    jr      $31
    mthc1   $4, $f0
    .set    macro
    .set    reorder
l_exit:
    jr      $31
    /* end: block for exponent < 20 */

    /* start: l_block_52; Handles NaN, Infinity and integral */
l_block_52:
    .set    noreorder
    .set    nomacro
    bne     $2,  $0,   l_exit_block_52
    addiu   $7,  $8,   -1043
    li      $2,  1024           /* const to check inf or NaN */
    bne     $6,  $2,   l_exit
    mov.d   $f0, $f12           /* integral */
    jr      $31
    add.d   $f0, $f12, $f12     /* inf or NaN */
    .set    macro
    .set    reorder
    /* end: l_block_52 */

l_exit_block_52:
    li      $3, -1              /* 0xffffffff */
    srl     $7, $3, $7
    and     $3, $7, $5

    .set    noreorder
    .set    nomacro
    beq     $3,  $0,  l_exit
    mov.d   $f0, $f12           /* integral */
    .set    macro
    .set    reorder

    nor     $7, $0, $7
    and     $7, $5, $7
    mtc1    $7, $f0
    .set    noreorder
    .set    nomacro
    jr      $31
    mthc1   $4, $f0
    .set    macro
    .set    reorder

l_exit_20:
    li      $3, 0x80000000      /* sign bit constant */
    and     $4, $3
    .set    noreorder
    .set    nomacro
    jr      $31
    mthc1   $4, $f0
    .set    macro
    .set    reorder

#endif

END(trunc)

#if (LDBL_MANT_DIG == 53)
ALIAS_SYMBOL(truncl, trunc);
#endif
