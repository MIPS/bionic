/*
 * Copyright (c) 2016 Imagination Technologies.
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

#include "math.h"

double floor(double x)
{
  double res;
  int x_int, tmp;

  __asm__ (
    "mfhc1 %[x_int], %[x]     \n\t"
    "floor.l.d %[res], %[x]   \n\t"
    "li %[tmp], 1076          \n\t"
    "ext %[x_int], 20, 11     \n\t"
    "sub %[x_int], %[tmp]     \n\t"
    "cvt.d.l %[res], %[res]   \n\t"
    "bltz %[x_int], l_return  \n\t" /* Integer or NaN or Infinity */
    "mov.d  %[res], %[x]      \n"
    "l_return:"
    : [res] "=f" (res), [tmp] "=r" (tmp), [x_int] "=r" (x_int)
    : [x] "f" (x)
  );

  return res;
}

float floorf(float x)
{
  float res;
  int x_int, tmp;

  __asm__ (
    "mfc1 %[x_int], %[x]       \n\t"
    "floor.w.s %[res], %[x]    \n\t"
    "li %[tmp], 151            \n\t"
    "ext %[x_int], 23, 8       \n\t"
    "sub %[x_int], %[tmp]      \n\t"
    "cvt.s.w %[res], %[res]    \n\t"
    "bltz %[x_int], l_returnf  \n\t" /* Integer or NaN or Infinity */
    "mov.s  %[res], %[x]       \n"
    "l_returnf:"
    : [res] "=f" (res), [tmp] "=r" (tmp), [x_int] "=r" (x_int)
    : [x] "f" (x)
  );

  return res;
}

#if (LDBL_MANT_DIG == 53)
__weak_reference(floor, floorl);
#endif
