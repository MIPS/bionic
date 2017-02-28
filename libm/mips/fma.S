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
LEAF(fma, 0)
#else
LEAF(fma)
#endif
#if __mips_isa_rev >= 6
#if __mips64 || (_MIPS_SIM != _ABIO32)
    mov.d   $f0, $f14
    maddf.d $f0, $f12, $f13
    jrc     $31
#else
    ldc1    $f0, 16(sp)
    maddf.d $f0, $f12, $f14
    jrc     $31
#endif
#elif __mips_isa_rev <= 1
    addiu   sp,   sp,   -136
    sw      $0,   40(sp)
    sw      $0,   44(sp)
    sdc1    $f22, 104(sp)
    sw      $31,  92(sp)
    sdc1    $f20, 96(sp)
    ldc1    $f0,  40(sp)
    ldc1    $f22, 152(sp)
    sw      $18,  88(sp)
    sdc1    $f28, 128(sp)
    sw      $16,  80(sp)
    sdc1    $f26, 120(sp)
    sdc1    $f24, 112(sp)
    sdc1    $f12, 48(sp)
    sdc1    $f14, 56(sp)

    .set    noreorder
    .set    nomacro
    /* inputs in f12, f14 and f22 */

    /* handle if inputs are 0.0 */
    c.eq.d  $fcc0, $f12,    $f0
    bc1t    $fcc0, l_madd_exit
    mov.d   $f20,  $f12
    c.eq.d  $fcc1, $f14,    $f0
    bc1t    $fcc1, l_madd_exit
    c.eq.d  $fcc2, $f22,    $f0
    bc1t    $fcc2, l_mul_exit

    /* handle if inputs not finite */
    lw      $2, 52(sp)
    srl     $2, 20
    andi    $2, 0x7ff               /* extract 11 bit exponent */
    subu    $2, 0x7ff               /* subtract exponent bias */
    beq     $2, $0, l_madd_exit

    lw      $3, 60(sp)
    srl     $3, 20
    andi    $3, 0x7ff               /* extract 11 bit exponent */
    subu    $3, 0x7ff               /* subtract exponent bias */
    beq     $3, $0, l_madd_exit

    lw      $2, 156(sp)
    srl     $2, 20
    andi    $2, 0x7ff               /* extract 11 bit exponent */
    subu    $2, 0x7ff               /* subtract exponent bias */
    bne     $2, $0, l_finite
    nop

l_exit1:
    b       l_exit
    mov.d   $f0, $f22

l_madd_exit:
    mul.d   $f0, $f20, $f14
    add.d   $f0, $f22
l_exit:
    lw      $31,  92(sp)
    lw      $18,  88(sp)
    ldc1    $f28, 128(sp)
    ldc1    $f26, 120(sp)
    lw      $16,  80(sp)
    ldc1    $f24, 112(sp)
    ldc1    $f22, 104(sp)
    ldc1    $f20, 96(sp)
    jr      $31
    addiu   sp,   sp,   136

l_mul_exit:
    lw      $31,  92(sp)
    lw      $18,  88(sp)
    ldc1    $f28, 128(sp)
    ldc1    $f26, 120(sp)
    lw      $16,  80(sp)
    ldc1    $f24, 112(sp)
    ldc1    $f22, 104(sp)
    ldc1    $f20, 96(sp)
    addiu   sp,   sp,   136
    jr      $31
    mul.d   $f0,  $f12, $f14

l_finite:
    lui     $14,  0x4350
    sw      $14,  44(sp)
    ldc1    $f16, 40(sp)

    lui     $15, 0x0010
    lui     $12, 0x800f
    lui     $14, 0x3fe0
    ori     $12, 0xffff

    lw      $13, 52(sp)             /* high word */
    move    $7,  $0
    sll     $24, $13, 1
    srl     $24, 1
    slt     $25, $24, $15
    beq     $25, $0,  l_skip0
    nop
    mul.d   $f26, $f20, $f16
    sdc1    $f26, 48(sp)
    lw      $13,  52(sp)            /* high word */
    li      $7,   -54
l_skip0:
    srl     $18,  $13,  20
    andi    $18,  0x7ff
    subu    $18,  1022
    add     $18,  $7
    and     $13,  $12
    or      $13,  $14
    sw      $13,  52(sp)
    ldc1    $f26, 48(sp)

    lw      $13, 60(sp)             /* high word */
    move    $7,  $0
    sll     $24, $13, 1
    srl     $24, 1
    slt     $25, $24, $15
    beq     $25, $0,  l_skip1
    nop
    mul.d   $f24, $f14, $f16
    sdc1    $f24, 56(sp)
    lw      $13,  60(sp)            /* high word */
    li      $7,   -54
l_skip1:
    srl     $3,   $13,  20
    andi    $3,   0x7ff
    subu    $3,   1022
    add     $3,   $7
    and     $13,  $12
    or      $13,  $14
    sw      $13,  60(sp)
    ldc1    $f24, 56(sp)

    lw      $13, 156(sp)            /* high word */
    move    $7,  $0
    sll     $24, $13, 1
    srl     $24, 1
    slt     $25, $24, $15
    beq     $25, $0,  l_skip2
    nop
    mul.d   $f0, $f22,  $f16
    sdc1    $f0, 152(sp)
    lw      $13, 156(sp)            /* high word */
    li      $7,  -54
l_skip2:
    srl     $6,  $13,   20
    andi    $6,  0x7ff
    subu    $6,  1022
    add     $6,  $7
    and     $13, $12
    or      $13, $14
    sw      $13, 156(sp)
    ldc1    $f0, 152(sp)

    cfc1    $2, $31                 /* get control register */

    addu    $18, $18, $3
    subu    $6,  $18, $6
    slt     $3,  $6,  -53           /* -DBL_MANT_DIG */
    bne     $3,  $0,  l_except
    andi    $16, $2,  0x3           /* rounding mode */

    slt     $2, $6, 107             /* DBL_MANT_DIG * 2 + 1 */
    bne     $2, $0, l_jump4

    lui     $2,   0x0010
    sw      $2,   44(sp)
    ldc1    $f20, 40(sp)
    lw      $2,   156(sp)
    bgez    $2,   l_mul_add
    lui     $2,   0x8010
    sw      $2,   44(sp)
    ldc1    $f20, 40(sp)

l_mul_add:
    lui     $24,  0x0200
    ctc1    $0,   $31               /* Set rounding mode to 0 (FE_TONEAREST) */
    sw      $24,  72(sp)
    lui     $25,  0x41a0
    sw      $25,  76(sp)
    sw      $0,   44(sp)
    ldc1    $f2,  72(sp)
    mov.d   $f8,  $f26
    ldc1    $f16, 40(sp)            /* zero */

    mul.d   $f6,   $f8,  $f2
    mul.d   $f2,   $f24, $f2
    sub.d   $f10,  $f8,  $f6
    sub.d   $f4,   $f24, $f2
    add.d   $f6,   $f6,  $f10
    add.d   $f2,   $f2,  $f4
    sub.d   $f8,   $f8,  $f6
    mul.d   $f4,   $f6,  $f2
    sub.d   $f24,  $f24, $f2
    mul.d   $f2,   $f8,  $f2
    mul.d   $f6,   $f6,  $f24
    add.d   $f6,   $f2
    add.d   $f28,  $f4,  $f6
    add.d   $f26,  $f20, $f28
    sub.d   $f4,   $f4,  $f28
    sub.d   $f22,  $f26, $f28
    add.d   $f6,   $f6,  $f4
    c.eq.d  $fcc2, $f26, $f16
    sub.d   $f2,   $f26, $f22
    mul.d   $f24,  $f8,  $f24
    add.d   $f24,  $f6
    sub.d   $f22,  $f20, $f22
    sub.d   $f6,   $f28, $f2
    bc1t    $fcc2, l_jump5
    add.d   $f22,  $f6,  $f22

    bne     $16, $0, l_jump7
    nop

    add.d   $f6,   $f22, $f24
    sdc1    $f6,   72(sp)
    lw      $16,   72(sp)
    lw      $7,    76(sp)
    mov.d   $f2,   $f6
    sub.d   $f6,   $f6,  $f22
    sub.d   $f2,   $f2,  $f6
    sub.d   $f6,   $f24, $f6
    sub.d   $f22,  $f22, $f2
    add.d   $f6,   $f22, $f6
    sdc1    $f6,   72(sp)
    c.eq.d  $fcc3, $f6,  $f16
    bc1t    $fcc3, l_add_denormalize
    lw      $3,    76(sp)

    andi    $5,  $16, 0x1
    bne     $5,  $0,  l_add_denormalize
    xor     $3,  $7,  $3

    addiu   $2,  $16, 1
    srl     $3,  $3,  30
    sltu    $4,  $2,  $16
    subu    $16, $2,  $3
    addu    $7,  $4,  $7
    sltu    $2,  $2,  $16
    subu    $7,  $7,  $2
l_add_denormalize:
    lw      $25,  %call16(ilogb)($28)
    jalr    $25
    mov.d   $f12, $f26

    sw      $16,   72(sp)
    sw      $7,    76(sp)
    addu    $2,    $18,  $2
    slt     $2,    $2,   -1022
    beq     $2,    $0,   l_jump6
    ldc1    $f0,   72(sp)
    mov.d   $f2,   $f0
    add.d   $f0,   $f26, $f0
    sdc1    $f0,   64(sp)
    mov.d   $f6,   $f0
    sub.d   $f0,   $f0,  $f26
    sub.d   $f6,   $f6,  $f0
    sub.d   $f0,   $f2,  $f0
    sub.d   $f26,  $f26, $f6
    add.d   $f0,   $f26, $f0
    sdc1    $f0,   72(sp)
    lw      $2,    72(sp)
    lw      $3,    76(sp)
    c.eq.d  $fcc4, $f0,  $f16
    bc1t    $fcc4, l_ldexp_exit
    ldc1    $f12,  64(sp)

    lw      $8, 68(sp)
    lw      $5, 64(sp)
    srl     $4, $8, 20
    andi    $4, 0x7ff
    andi    $6, $5,  0x1
    subu    $4, $0,  $4
    xor     $4, $18, $4
    sltu    $4, $0,  $4
    beq     $4, $6,  l_ldexp_exit
    xor     $6, $8,  $3

    addiu   $4,   $5,   1
    srl     $6,   $6,   30
    sltu    $5,   $4,   $5
    andi    $6,   $6,   0x2
    addu    $3,   $5,   $8
    subu    $2,   $4,   $6
    sltu    $4,   $4,   $2
    subu    $3,   $3,   $4
    sw      $2,   64(sp)
    sw      $3,   68(sp)
    ldc1    $f12, 64(sp)
l_ldexp_exit:
    lw      $25, %call16(ldexp)($28)
    jalr    $25
    move    $6,  $18

    b       l_exit
    nop

l_except:
    sdc1    $f22, 72(sp)
    cfc1    $4,   $31
    ori     $4,   (0x4 | 0x1000)
    ctc1    $4,   $31                   /* raise FE_INEXACT eception */

    lw      $24, 76(sp)
    srl     $25, $24,20
    andi    $25, 0x7ff
    subu    $24, $25, 0x7ff
    and     $24, $25

    bne     $24,  $0, l_jump0
    ldc1    $f14, 64(sp)

    cfc1    $4, $31
    ori     $4, (0x8 | 0x2000)
    ctc1    $4, $31                     /* raise FE_UNDERFLOW eception */

    ldc1    $f14, 64(sp)
l_jump0:
    li      $2,  1
    beq     $16, $2, l_jump10
    li      $2,  3

    beq     $16, $2, l_jump11
    nop

    beq     $16, $0, l_exit
    mov.d   $f0, $f22

    sw      $0,    44(sp)
    ldc1    $f0,   40(sp)
    c.lt.d  $fcc0, $f0,  $f20
    bc1t    $fcc0, l_jump1
    li      $3,    1

    move    $3,    $0
l_jump1:
    c.lt.d  $fcc1, $f14, $f0
    bc1t    $fcc1, l_jump2
    li      $2,    1

    move    $2, $0
l_jump2:
    beq     $3, $2, l_exit1

    lui     $2,   0x7ff0
    sw      $2,   44(sp)
    ldc1    $f14, 40(sp)
l_jump3:
    lw      $25,  %call16(nextafter)($28)
    jalr    $25
    mov.d   $f12, $f22
    b       l_exit
    nop

l_jump4:
    ldc1    $f12, 152(sp)
    lw      $25,  %call16(ldexp)($28)
    jalr    $25
    subu    $6,   $0, $6

    b       l_mul_add
    mov.d   $f20, $f0

l_jump6:
    lw      $25,  %call16(ldexp)($28)
    add.d   $f12, $f26, $f0
    jalr    $25
    move    $6,   $18

    b       l_exit
    nop

l_jump5:
    ctc1    $16, $31                /* Set rounding mode to original */

    move    $6,   $18
    sdc1    $f20, 32(sp)
    lw      $25,  %call16(ldexp)($28)
    jalr    $25
    mov.d   $f12, $f24

    add.d   $f20, $f20, $f28
    b       l_exit
    add.d   $f0,  $f20, $f0

l_jump7:
    ctc1    $16,  $31               /* Set rounding mode to original */

    move    $6,   $18
    add.d   $f12, $f22, $f24
    lw      $25,  %call16(ldexp)($28)
    jalr    $25
    add.d   $f12, $f12, $f26

    b       l_exit
    nop

l_jump11:
    sw      $0,    44(sp)
    ldc1    $f0,   40(sp)
    c.lt.d  $fcc6, $f0,  $f20
    bc1t    $fcc6, l_jump8
    li      $3,    1

    move    $3, $0
l_jump8:
    c.lt.d  $fcc7, $f14, $f0
    bc1t    $fcc7, l_jump9
    li      $2,    1

    move    $2,  $0
l_jump9:
    bne     $3,  $2, l_exit
    mov.d   $f0, $f22

    lui     $2,   0xfff0
    sw      $2,   44(sp)
    b       l_jump3
    ldc1    $f14, 40(sp)

l_jump10:
    sw      $0,    44(sp)
    ldc1    $f0,   40(sp)
    c.lt.d  $fcc3, $f22, $f0
    bc1t    $fcc3, l_jump12
    li      $3,    1

    move    $3,    $0
l_jump12:
    c.lt.d  $fcc4, $f0,  $f20
    bc1t    $fcc4, l_jump13
    li      $2,    1

    move    $2,    $0
l_jump13:
    c.lt.d  $fcc5, $f14, $f0
    bc1t    $fcc5, l_jump14
    li      $4,    1

    move    $4,  $0
l_jump14:
    xor     $2,  $2, $4
    bne     $3,  $2, l_exit
    mov.d   $f0, $f22

    b       l_jump3
    ldc1    $f14, 40(sp)

    .set    macro
    .set    reorder
#else
    mtc1    $0,   $f0
    addiu   sp,   sp,  -136
    sdc1    $f22, 104(sp)
    sw      $31,  92(sp)
    sdc1    $f20, 96(sp)
    mthc1   $0,   $f0
    ldc1    $f22, 152(sp)
    sw      $18,  88(sp)
    sdc1    $f28, 128(sp)
    sw      $16,  80(sp)
    sdc1    $f26, 120(sp)
    sdc1    $f24, 112(sp)

    .set    noreorder
    .set    nomacro
    /* inputs in f12, f14 and f22 */

    /* handle if inputs are 0.0 */
    c.eq.d  $fcc0, $f12, $f0
    bc1t    $fcc0, l_madd_exit
    mov.d   $f20,  $f12
    c.eq.d  $fcc1, $f14, $f0
    bc1t    $fcc1, l_madd_exit
    c.eq.d  $fcc2, $f22, $f0
    bc1t    $fcc2, l_mul_exit

    /* handle if inputs not finite */
    mfhc1   $2, $f12
    ext     $2, $2, 20, 11          /* extract 11 bit exponent */
    subu    $2, 0x7ff               /* subtract exponent bias */
    beq     $2, $0, l_madd_exit

    mfhc1   $3, $f14
    ext     $3, $3, 20, 11          /* extract 11 bit exponent */
    subu    $3, 0x7ff               /* subtract exponent bias */
    beq     $3, $0, l_madd_exit

    mfhc1   $2, $f22
    ext     $2, $2, 20, 11          /* extract 11 bit exponent */
    subu    $2, 0x7ff               /* subtract exponent bias */
    bne     $2, $0, l_finite
    nop

l_exit1:
    b       l_exit
    mov.d   $f0, $f22

l_madd_exit:
    madd.d  $f0, $f22, $f20, $f14
l_exit:
    lw      $31,  92(sp)
    lw      $18,  88(sp)
    ldc1    $f28, 128(sp)
    ldc1    $f26, 120(sp)
    lw      $16,  80(sp)
    ldc1    $f24, 112(sp)
    ldc1    $f22, 104(sp)
    ldc1    $f20, 96(sp)
    jr      $31
    addiu   sp,   sp, 136

l_mul_exit:
    lw      $31,  92(sp)
    lw      $18,  88(sp)
    ldc1    $f28, 128(sp)
    ldc1    $f26, 120(sp)
    lw      $16,  80(sp)
    ldc1    $f24, 112(sp)
    ldc1    $f22, 104(sp)
    ldc1    $f20, 96(sp)
    addiu   sp,   sp,   136
    jr      $31
    mul.d   $f0,  $f12, $f14

l_finite:
    mov.d   $f16, $f0
    lui     $14,  0x4350
    mthc1   $14,  $f16

    lui     $15, 0x0010
    lui     $12, 0x800f
    lui     $14, 0x3fe0
    ori     $12, 0xffff

    mov.d   $f26, $f20
    mfhc1   $13,  $f20              /* high word */
    move    $7,   $0
    ext     $24,  $13, 0, 31        /* abs */
    slt     $25,  $24, $15
    beq     $25,  $0,  l_skip0
    nop
    mul.d   $f26, $f20, $f16
    mfhc1   $13,  $f26
    li      $7,   -54
l_skip0:
    ext     $18, $13, 20, 11
    subu    $18, 1022
    add     $18, $7
    and     $13, $12
    or      $13, $14
    mthc1   $13, $f26

    mov.d   $f24, $f14
    mfhc1   $13,  $f14              /* high word */
    move    $7,   $0
    ext     $24,  $13, 0, 31        /* abs */
    slt     $25,  $24, $15
    beq     $25,  $0,  l_skip1
    nop
    mul.d   $f24, $f14, $f16
    mfhc1   $13,  $f24
    li      $7,   -54
l_skip1:
    ext     $3,  $13, 20, 11
    subu    $3,  1022
    add     $3,  $7
    and     $13, $12
    or      $13, $14
    mthc1   $13, $f24

    mov.d   $f0, $f22
    mfhc1   $13, $f22               /* high word */
    move    $7,  $0
    ext     $24, $13, 0, 31         /* abs */
    slt     $25, $24, $15
    beq     $25, $0,  l_skip2
    nop
    mul.d   $f0, $f22, $f16
    mfhc1   $13, $f0
    li      $7,  -54
l_skip2:
    ext     $6,  $13, 20, 11
    subu    $6,  1022
    add     $6,  $7
    and     $13, $12
    or      $13, $14
    mthc1   $13, $f0
    sdc1    $f0, 72(sp)

    cfc1    $2, $31                 /* get control register */

    addu    $18, $18, $3
    subu    $6,  $18, $6
    slt     $3,  $6,  -53           /* -DBL_MANT_DIG */
    bne     $3,  $0,  l_except
    andi    $16, $2,  0x3           /* rounding mode */

    slt     $2, $6, 107             /* DBL_MANT_DIG * 2 + 1 */
    bne     $2, $0, l_jump4

    mov.d   $f20, $f16
    lui     $2,   0x0010
    mthc1   $2,   $f20
    lw      $2,   76(sp)
    bgez    $2,   l_mul_add
    lui     $2,   0x8010
    mthc1   $2,   $f20

l_mul_add:
    lui     $2,  0x0200
    ctc1    $0,  $31                /* Set rounding mode to 0 (FE_TONEAREST) */
    mtc1    $2,  $f2
    lui     $2,  0x41a0
    mov.d   $f8, $f26
    mthc1   $2,  $f2
    mthc1   $0,  $f16

    mul.d   $f6,   $f8,  $f2
    mul.d   $f2,   $f24, $f2
    sub.d   $f10,  $f8,  $f6
    sub.d   $f4,   $f24, $f2
    add.d   $f6,   $f6,  $f10
    add.d   $f2,   $f2,  $f4
    sub.d   $f8,   $f8,  $f6
    mul.d   $f4,   $f6,  $f2
    sub.d   $f24,  $f24, $f2
    mul.d   $f2,   $f8,  $f2
    madd.d  $f6,   $f2,  $f6, $f24
    add.d   $f28,  $f4,  $f6
    add.d   $f26,  $f20, $f28
    sub.d   $f4,   $f4,  $f28
    sub.d   $f22,  $f26, $f28
    add.d   $f6,   $f6,  $f4
    c.eq.d  $fcc2, $f26, $f16
    sub.d   $f2,   $f26, $f22
    madd.d  $f24,  $f6,  $f8, $f24
    sub.d   $f22,  $f20, $f22
    sub.d   $f6,   $f28, $f2
    bc1t    $fcc2, l_jump5
    add.d   $f22,  $f6,  $f22

    bne     $16,   $0,   l_jump7
    nop

    add.d   $f6,   $f22, $f24
    mfc1    $16,   $f6
    mfhc1   $7,    $f6
    mov.d   $f2,   $f6
    sub.d   $f6,   $f6,  $f22
    sub.d   $f2,   $f2,  $f6
    sub.d   $f6,   $f24, $f6
    sub.d   $f22,  $f22, $f2
    add.d   $f6,   $f22, $f6
    c.eq.d  $fcc3, $f6,  $f16
    bc1t    $fcc3, l_add_denormalize
    mfhc1   $3,    $f6

    andi    $5,  $16, 0x1
    bne     $5,  $0,  l_add_denormalize
    xor     $3,  $7,  $3

    addiu   $2,  $16, 1
    srl     $3,  $3,  30
    sltu    $4,  $2,  $16
    subu    $16, $2,  $3
    addu    $7,  $4,  $7
    sltu    $2,  $2,  $16
    subu    $7,  $7,  $2
l_add_denormalize:
    lw      $25,   %call16(ilogb)($28)
    jalr    $25
    mov.d   $f12,  $f26

    mtc1    $16,   $f0
    addu    $2,    $18,  $2
    slt     $2,    $2,   -1022
    beq     $2,    $0,   l_jump6
    mthc1   $7,    $f0
    mov.d   $f2,   $f0
    add.d   $f0,   $f26, $f0
    mov.d   $f12,  $f0
    mov.d   $f6,   $f0
    sub.d   $f0,   $f0,  $f26
    sub.d   $f6,   $f6,  $f0
    sub.d   $f0,   $f2,  $f0
    sub.d   $f26,  $f26, $f6
    add.d   $f0,   $f26, $f0
    mfc1    $2,    $f0
    mfhc1   $3,    $f0
    mov.d   $f6,   $f0
    c.eq.d  $fcc4, $f0,  $f16
    bc1t    $fcc4, l_ldexp_exit
    nop

    mfhc1   $8, $f12
    mfc1    $5, $f12
    ext     $4, $8,  20, 11
    andi    $6, $5,  0x1
    subu    $4, $0,  $4
    xor     $4, $18, $4
    sltu    $4, $0,  $4
    beq     $4, $6,  l_ldexp_exit
    xor     $6, $8,  $3

    addiu   $4, $5,  1
    srl     $6, $6,  30
    sltu    $5, $4,  $5
    andi    $6, $6,  0x2
    addu    $3, $5,  $8
    subu    $2, $4,  $6
    sltu    $4, $4,  $2
    subu    $3, $3,  $4
    mtc1    $2, $f12
    mthc1   $3, $f12
l_ldexp_exit:
    lw      $25, %call16(ldexp)($28)
    jalr    $25
    move    $6,  $18

    b       l_exit
    nop

l_except:
    cfc1    $4, $31
    ori     $4, (0x4 | 0x1000)
    ctc1    $4, $31                     /* raise FE_INEXACT eception */

    mfhc1   $24, $f22
    ext     $25, $24, 20, 11
    subu    $24, $25, 0x7ff
    and     $24, $25

    bne     $24,  $0,  l_jump0
    ldc1    $f14, 64(sp)

    cfc1    $4, $31
    ori     $4, (0x8 | 0x2000)
    ctc1    $4, $31                     /* raise FE_UNDERFLOW eception */

    ldc1    $f14, 64(sp)
l_jump0:
    li      $2,  1
    beq     $16, $2, l_jump10
    li      $2,  3

    beq     $16, $2, l_jump11
    nop

    beq     $16, $0, l_exit
    mov.d   $f0, $f22

    mov.d   $f0,   $f16
    mthc1   $0,    $f0
    c.lt.d  $fcc0, $f0, $f20
    bc1t    $fcc0, l_jump1
    li      $3,    1

    move    $3,    $0
l_jump1:
    c.lt.d  $fcc1, $f14, $f0
    bc1t    $fcc1, l_jump2
    li      $2,    1

    move    $2,    $0
l_jump2:
    beq     $3, $2, l_exit1

    lui     $2, 0x7ff0
    mtc1    $0, $f14
    mthc1   $2, $f14
l_jump3:
    lw      $25,  %call16(nextafter)($28)
    jalr    $25
    mov.d   $f12, $f22
    b       l_exit
    nop
l_jump4:
    ldc1    $f12, 72(sp)
    lw      $25,  %call16(ldexp)($28)
    jalr    $25
    subu    $6,   $0, $6

    b       l_mul_add
    mov.d   $f20, $f0

l_jump6:
    lw      $25,  %call16(ldexp)($28)
    add.d   $f12, $f26, $f0
    jalr    $25
    move    $6,   $18

    b       l_exit
    nop

l_jump5:
    ctc1    $16,  $31               /* Set rounding mode to original */

    move    $6,   $18
    lw      $25,  %call16(ldexp)($28)
    sdc1    $f20, 32(sp)
    jalr    $25
    mov.d   $f12, $f24

    add.d   $f20, $f20, $f28
    b       l_exit
    add.d   $f0,  $f20, $f0

l_jump7:
    ctc1    $16,  $31               /* Set rounding mode to original */

    move    $6,   $18
    add.d   $f12, $f22, $f24
    lw      $25,  %call16(ldexp)($28)
    jalr    $25
    add.d   $f12, $f12, $f26

    b       l_exit
    nop

l_jump11:
    mov.d   $f0,   $f16
    mthc1   $0,    $f0
    c.lt.d  $fcc6, $f0, $f20
    bc1t    $fcc6, l_jump8
    li      $3,    1

    move    $3,    $0
l_jump8:
    c.lt.d  $fcc7, $f14, $f0
    bc1t    $fcc7, l_jump9
    li      $2,    1

    move    $2,    $0
l_jump9:
    bne     $3,    $2,   l_exit
    mov.d   $f0,   $f22

    lui     $2,    0xfff0
    mtc1    $0,    $f14
    b       l_jump3
    mfhc1   $2,    $f14

l_jump10:
    mov.d   $f0,   $f16
    mthc1   $0,    $f0
    c.lt.d  $fcc3, $f22, $f0
    bc1t    $fcc3, l_jump12
    li      $3,    1

    move    $3,    $0
l_jump12:
    c.lt.d  $fcc4, $f0, $f20
    bc1t    $fcc4, l_jump13
    li      $2,    1

    move    $2,    $0
l_jump13:
    c.lt.d  $fcc5, $f14, $f0
    bc1t    $fcc5, l_jump14
    li      $4,    1

    move    $4,  $0
l_jump14:
    xor     $2,  $2, $4
    bne     $3,  $2, l_exit
    mov.d   $f0, $f22

    mtc1    $0,  $f14
    b       l_jump3
    mthc1   $0,  $f14

    .set    macro
    .set    reorder
#endif

END(fma)

#if (LDBL_MANT_DIG == 53)
ALIAS_SYMBOL(fmal, fma);
#endif
