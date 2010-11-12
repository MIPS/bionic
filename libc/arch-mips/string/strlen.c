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
#include <stdint.h>

size_t strlen(const char *s)
{
    __builtin_prefetch(s);
    __builtin_prefetch(s+32);
    
    union {
        const char      *b;
        const uint32_t  *w;
        uintptr_t       i;
    } u;
    
    // these are some scratch variables for the asm code below
    uint32_t v, t;
    
    // initialize the string length to zero
    size_t l = 0;

    // align the pointer to a 32-bit word boundary
    u.b = s;
    while (u.i & 0x3)  {
        if (__builtin_expect(*u.b++ == 0, 0)) {
            goto done;
        }
        l++;
    }

    // loop for each word, testing if it contains a zero byte
    // if so, exit the loop and update the length.
    asm(
       ".set	push\n"
       ".set	noreorder\n"
"	subu	%[l],%[s]\n"
"0:\n"
"	lw      %[v],(%[s])\n"
"	subu    %[t],%[v],%[masklo]\n"
"	and     %[t],%[maskhi]\n"
"	not	%[v]\n"
"	and	%[t],%[v]\n"
"	beqz	%[t],0b\n"
"	 addu	%[s],4\n"

"1:\n"
"	not	%[v]\n"
"	subu	%[s],4\n"
"	addu	%[l],%[s]\n"
#if defined(__MIPSEB__)
"	li      $t3,0xff000000\n"
"	and	%[t],%[v],$t3\n"
#endif
#if defined(__MIPSEL__)
"	andi    %[t],%[v],0xff\n"
#endif
"	beqz	%[t],2f\n"
#if defined(__MIPSEB__)
"	 sll    %[v],8\n"
#endif
#if defined(__MIPSEL__)
"	 srl    %[v],8\n"
#endif
"	addu	%[l],1\n"
#if defined(__MIPSEB__)
"       and	%[t],%[v],$t3\n"
#endif
#if defined(__MIPSEL__)
"       andi   %[t],%[v],0xff\n"
#endif
"	beqz	%[t],2f\n"
#if defined(__MIPSEB__)
"	 sll    %[v],8\n"
#endif
#if defined(__MIPSEL__)
"	 srl    %[v],8\n"
#endif
"	addu	%[l],1\n"
#if defined(__MIPSEB__)
"	and     %[t],%[v],$t3\n"
#endif
#if defined(__MIPSEL__)
"	andi   %[t],%[v],0xff\n"
#endif
"	beqz	%[t],2f\n"
"	 nop\n"
"	addu	%[l],1\n"
"2:\n"
       ".set	pop\n"
       : [l]"=&r"(l), [v]"=&r"(v), [t]"=&r"(t), [s]"=&r"(u.b)
       : "%[l]"(l), "%[s]"(u.b), [maskhi]"r"(0x80808080UL), [masklo]"r"(0x01010101UL)
    );
    
done:
    return l;
}
