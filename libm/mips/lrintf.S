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
LEAF(lrintf, 0)
#else
LEAF(lrintf)
#endif
#if __mips_isa_rev >= 6
    .set    noreorder
    .set    nomacro
    rint.s      $f0, $f12
    trunc.l.s   $f0, $f0
    jr          $31
#if __mips64
    dmfc1       $2, $f0
#else
    mfc1        $2, $f0
#endif
    .set    macro
    .set    reorder

#else

    .set    noreorder
    .set    nomacro

    mfc1    $3, $f12            /* move high part in G.P. register */
#if __mips_isa_rev <= 1
    srl     $2, $3, 23
    andi    $2, 0xff
#else
    ext     $2, $3, 23, 8       /* extract 8 bits exponent field */
#endif
    addiu   $2, $2, -127        /* subtract exponent bias */
    slt     $4, $2, 23
    beq     $4, $0, l_block_23
    nop

    srl     $3,  $3,  31
    sll     $5,  $3,  31
    lui     $6,  0x4b00
    or      $6,  $5
    sub.s   $f2, $f12,$f12
    mtc1    $6,  $f2
    add.s   $f0, $f2, $f12
    bltz    $2,  l_block_less23
    sub.s   $f0, $f0, $f2
    trunc.w.s    $f0, $f0
    jr           $31
    mfc1         $2,  $f0

l_block_23:                     /* inf or NaN or integral*/
    trunc.w.s   $f0, $f12
    jr          $31
    mfc1        $2,  $f0

l_block_less23:
    mfc1    $3, $f0
#if __mips_isa_rev <= 1
    sll     $4, $3,  1
    srl     $4, 1
#else
    ext     $4, $3,  0, 31
#endif
    or      $3, $5,  $4
    mtc1    $3, $f0
    trunc.w.s   $f0, $f0
    jr          $31
    mfc1        $2,  $f0

    .set    macro
    .set    reorder
#endif
END(lrintf)
