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
LEAF(rint, 0)
#else
LEAF(rint)
#endif
#if __mips64 || __mips_isa_rev >= 6
    rint.d  $f0, $f12
    jr      $31
#elif __mips_isa_rev == 1
    .set    noreorder
    .set    nomacro

    addiu   sp,   sp,  -8
    sdc1    $f12, 0(sp)
    lw      $3,   4(sp)         /* move high part in G.P. register */
    srl     $8,   $3,  20       /* extract 11 bits exponent field */
    andi    $8,   0x7ff
    addiu   $2,   $8,  -1023    /* subtract exponent bias */
    slt     $4,   $2,  52
    beq     $4,   $0,  l_block_52
    li      $7,   1024

    srl     $3,  $3, 31
    sll     $5,  $3, 31
    lui     $6,  0x4330
    or      $6,  $5
    sw      $0,  0(sp)
    sw      $6,  4(sp)
    ldc1    $f2, 0(sp)
    add.d   $f0, $f2, $f12
    bltz    $2,  l_block_less52
    sub.d   $f0, $f0, $f2
l_exit:
    addiu   sp, sp, 8
    jr      $31
    nop

l_block_52:
    bne     $2,  $7,  l_exit
    mov.d   $f0, $f12           /* x is integral */

    addiu   sp,  sp,  8
    jr      $31
    add.d   $f0, $f0, $f0       /* inf or NaN */

l_block_less52:
    sdc1    $f0, 0(sp)
    lw      $3,  4(sp)
    sll     $4,  $3, 1
    srl     $4,  1
    or      $3,  $5, $4
    sw      $3,  4(sp)
    ldc1    $f0, 0(sp)
    addiu   sp,  sp, 8
    jr      $31
    nop

    .set    macro
    .set    reorder
#else
    .set    noreorder
    .set    nomacro

    mfhc1   $3, $f12            /* move high part in G.P. register */
    ext     $2, $3, 20, 11      /* extract 11 bits exponent field */
    addiu   $2, $2, -1023       /* subtract exponent bias */
    slt     $4, $2, 52
    beq     $4, $0, l_block_52
    li      $7, 1024

    srl     $3,  $3, 31
    sll     $5,  $3, 31
    lui     $6,  0x4330         /* exp = 52(number of mantissa bits) */
    or      $6,  $5
    sub.d   $f2, $f12, $f12
    mthc1   $6,  $f2
    add.d   $f0, $f2,  $f12
    bltz    $2,  l_block_less52
    sub.d   $f0, $f0,  $f2
l_exit:
    jr      $31
    nop

l_block_52:
    bne     $2,  $7,  l_exit
    mov.d   $f0, $f12           /* x is integral */

    jr      $31
    add.d   $f0, $f0, $f0       /* inf or NaN */

l_block_less52:
    mfhc1   $3, $f0
    ext     $4, $3, 0, 31
    or      $3, $5, $4
    jr      $31
    mthc1   $3, $f0

    .set    macro
    .set    reorder
#endif

END(rint)

#if (LDBL_MANT_DIG == 53)
ALIAS_SYMBOL(rintl, rint);
#endif
