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

ENTRY(floorf)
    li         t1,  0x4d800000  /* const to check inf, NaN or integer */
    floor.w.s  $f2, $f12
    mtc1       t1,  $f0         /* move const to FP reg 0 */
    abs.s      $f4, $f12        /* Absolute value */
    .set    noreorder
    .set    nomacro
#if __mips_isa_rev >= 6
    cmp.lt.s   $f6, $f4, $f0    /* Check if input > const */
    bc1eqz     $f6, 1f          /* if input > const, return input as it is */
    sub.s      $f4, $f4
    cmp.eq.s   $f6, $f4, $f2
    bc1nez     $f6, 2f          /* Handles +/-0 case */
    nop
#else
    c.olt.s    $f4, $f0         /* Check if input > const */
    bc1f       1f               /* if input > const, return input as it is */
    sub.s      $f4, $f4
    c.eq.s     $f4, $f2
    bc1t       2f               /* Handles +/-0 case */
    nop
#endif
    jr         ra
    cvt.s.w    $f0, $f2         /* Convert to double in $f0 */
1:
    jr         ra
    mov.s      $f0, $f12        /* Return input as is */
2:
    jr         ra
    mul.s      $f0, $f2, $f12   /* +/-0 */
    .set    macro
    .set    reorder
END(floorf)
