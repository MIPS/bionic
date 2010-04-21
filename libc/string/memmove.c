/*
 * Copyright (C) 2008 The Android Open Source Project
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
#include <string.h>

void *memmove(void *dst, const void *src, size_t n)
{
  const char *p = src;
  char *q = dst;
  size_t c0, c1, i;
#define PRELOAD_DISTANCE 64
    /* a semi-optimized memmove(). we're preloading the src and dst buffers
     * as we go */
  if (__builtin_expect(q < p, 1)) {
    __builtin_prefetch(p);
    __builtin_prefetch(q);
    if (PRELOAD_DISTANCE > 32) {
      __builtin_prefetch(p + 32);
      __builtin_prefetch(q + 32);
    }
    asm volatile("":::"memory");
    if ((~((unsigned int)p ^ (unsigned int)q) & 3) == 3) {
      /* src and dst are aligned */
      while (n && ((unsigned int)p & 3) != 0) {
        n--;
        *q++ = *p++;
      }
      c0 = n & 0x1f;
      c1 = n >> 5;
      while ( c1-- ) {
        /* note: we preload the destination as well, because the 1-byte at a time
         * copy below doesn't take advantage of the write-buffer, we need
         * to use the cache instead as a poor man's write-combiner */
        __builtin_prefetch(p + PRELOAD_DISTANCE);
        __builtin_prefetch(q + PRELOAD_DISTANCE);
        /* do the prefetech as soon as possible, prevent the compiler to
         * reorder the instructions above the prefetch */
        asm volatile("":::"memory");
        ((unsigned int *)q)[0] = ((unsigned int *)p)[0];
        ((unsigned int *)q)[1] = ((unsigned int *)p)[1];
        ((unsigned int *)q)[2] = ((unsigned int *)p)[2];
        ((unsigned int *)q)[3] = ((unsigned int *)p)[3];
        ((unsigned int *)q)[4] = ((unsigned int *)p)[4];
        ((unsigned int *)q)[5] = ((unsigned int *)p)[5];
        ((unsigned int *)q)[6] = ((unsigned int *)p)[6];
        ((unsigned int *)q)[7] = ((unsigned int *)p)[7];
        p += 32;
        q += 32;
      }
      while ( c0-- ) {
        *q++ = *p++;
      }
    } else {
      c0 = n & 0x1f;
      c1 = n >> 5;
      while ( c1-- ) {
        __builtin_prefetch(p - (PRELOAD_DISTANCE));
        __builtin_prefetch(q - (PRELOAD_DISTANCE));
        asm volatile("":::"memory");
        for (i=0 ; i<32 ; i++) {
          *q++ = *p++;
        }
      }
      while ( c0--) {
        *q++ = *p++;
      }
    }
  } else {
    p += n;
    q += n;
    __builtin_prefetch(p - 1);
    __builtin_prefetch(q - 1);
    if (PRELOAD_DISTANCE > 32) {
        __builtin_prefetch(p - (32 + 1));
        __builtin_prefetch(q - (32 + 1));
    }
    asm volatile("":::"memory");
    if ((~((unsigned int)p ^ (unsigned int)q) & 3) == 3) {
      while (n && ((unsigned int)p & 3) != 0) {
        n--;
        *--q = *--p;
      }
      c0 = n & 0x1f; /* cache-line is 32 bytes */
      c1 = n >> 5;
      while ( c1-- ) {
        __builtin_prefetch(p - (PRELOAD_DISTANCE + 1));
        __builtin_prefetch(q - (PRELOAD_DISTANCE + 1));
        asm volatile("":::"memory");
          q-=32; p-=32;
          ((unsigned int *)q)[7] = ((unsigned int *)p)[7];
          ((unsigned int *)q)[6] = ((unsigned int *)p)[6];
          ((unsigned int *)q)[5] = ((unsigned int *)p)[5];
          ((unsigned int *)q)[4] = ((unsigned int *)p)[4];
          ((unsigned int *)q)[3] = ((unsigned int *)p)[3];
          ((unsigned int *)q)[2] = ((unsigned int *)p)[2];
          ((unsigned int *)q)[1] = ((unsigned int *)p)[1];
          ((unsigned int *)q)[0] = ((unsigned int *)p)[0];
      }
      while ( c0-- ) {
        *--q = *--p;
      }
    } else {
      c0 = n & 0x1f;
      c1 = n >> 5;
      while (c1--) {
        __builtin_prefetch(p - (PRELOAD_DISTANCE + 1));
        __builtin_prefetch(q - (PRELOAD_DISTANCE + 1));
        asm volatile("":::"memory");
        for (i=0 ; i<32 ; i++) {
          *--q = *--p;
        }
      }
      while ( c0-- ) {
        *--q = *--p;
      }
    }
  }
  return dst;
}
