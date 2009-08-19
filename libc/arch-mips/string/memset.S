/*
 * Copyright (c) 2009
 *      MIPS Technologies, Inc., California.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the MIPS Technologies, Inc., nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE MIPS TECHNOLOGIES, INC. ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE MIPS TECHNOLOGIES, INC. BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/************************************************************************
 *
 *  memset.S, version "64h" with 1 cache line horizon for "pref 30" and 14 nops
 *  Version: "043009"
 *
 ************************************************************************/


/************************************************************************
 *  Include files
 ************************************************************************/

#include "machine/asm.h"

/* 
 * This routine could be optimized for MIPS64. The current code only
 * uses MIPS32 instructions.
 */	

#ifdef EB
#  define SWHI	swl		/* high part is left in big-endian	*/
#else
#  define SWHI	swr		/* high part is right in little-endian	*/
#endif

LEAF(memset,0)

	.set	noreorder
	.set	noat

	andi	a1, 0xff		# To avoid problems when extending
	addu	t0,a0,a2		# t0 is the "past the end" address
	slti	AT,a2,4			# is a2 less than 4?
	bne	AT,zero,last4		# if yes, go to last4
	move	v0,a0			# memset returns the dst pointer

	beq	a1,zero,set0
	subu	v1,zero,a0

	# smear byte into 32 bit word
#if (__mips==32) && (__mips_isa_rev==2)
	ins     a1, a1, 8, 8        # Replicate fill byte into half-word.
	ins     a1, a1, 16, 16      # Replicate fill byte into word.
#else
	and	a1,0xff
	sll	AT,a1,8
	or	a1,AT
	sll	AT,a1,16
	or	a1,AT
#endif

set0:	andi	v1,v1,0x3		# word-unaligned address?
	beq	v1,zero,aligned		# v1 is the unalignment count
	subu	a2,a2,v1
	SWHI	a1,0(a0)
	addu	a0,a0,v1

# Here we have the "word-aligned" a0 (until the "last4")
aligned:
	andi	t8,a2,0x3f	# any 64-byte chunks?
				# t8 is the byte count past 64-byte chunks
	beq	a2,t8,chk8w	# when a2==t8, no 64-byte chunks
				# There will be at most 1 32-byte chunk then
	subu	a3,a2,t8	# subtract from a2 the reminder
				# Here a3 counts bytes in 16w chunks
	addu	a3,a0,a3	# Now a3 is the final dst after 64-byte chunks

# Find out, if there are any 64-byte chunks after which will be still at least
# 96 bytes left. The value "96" is calculated as needed buffer for
# "pref 30,64(a0)" prefetch, which can be used as "pref 30,0(a0)" after
# incrementing "a0" by 64.
# For "a2" below 160 there will be no such "pref 30 safe" 64-byte chunk.
#
	sltiu	v1,a2,160
	bgtz	v1,loop16w_nopref30	# skip "pref 30,0(a0)"
	subu	t7,a2,96	# subtract "pref 30 unsafe" region
		# below we have at least 1 64-byte chunk which is "pref 30 safe"
	andi	t6,t7,0x3f	# t6 is past "64-byte safe chunks" reminder
	subu	t5,t7,t6	# subtract from t7 the reminder
				# Here t5 counts bytes in 16w "safe" chunks
	addu	t4,a0,t5	# Now t4 is the dst after 64-byte "safe" chunks

# Don't use "pref 30,0(a0)" for a0 in a "middle" of a cache line
#	pref	30,0(a0)
# Here we are in the region, where it is safe to use "pref 30,64(a0)"
loop16w:
	addiu	a0,a0,64
	pref	30,-32(a0)	# continue setting up the dest, addr 64-32
	sw	a1,-64(a0)
	sw	a1,-60(a0)
	sw	a1,-56(a0)
	sw	a1,-52(a0)
	sw	a1,-48(a0)
	sw	a1,-44(a0)
	sw	a1,-40(a0)
	sw	a1,-36(a0)
	nop
	nop			# the extra nop instructions help to balance
	nop			# cycles needed for "store" + "fill" + "evict" 
	nop			# For 64byte store there are needed 8 fill
	nop			# and 8 evict cycles, i.e. at least 32 instr.
	nop
	nop
	pref	30,0(a0)	# continue setting up the dest, addr 64-0
	sw	a1,-32(a0)
	sw	a1,-28(a0)
	sw	a1,-24(a0)
	sw	a1,-20(a0)
	sw	a1,-16(a0)
	sw	a1,-12(a0)
	sw	a1,-8(a0)
	sw	a1,-4(a0)
	nop
	nop
	nop
	nop			# NOTE: adding 14 nop-s instead of 12 nop-s
	nop			# gives better results for "fast" memory
	nop
	bne	a0,t4,loop16w
	nop

	beq	a0,a3,chk8w	# maybe no more 64-byte chunks?
	nop			# this "delayed slot" is useless ...

loop16w_nopref30:	# there could be up to 3 "64-byte nopref30" chunks
	addiu	a0,a0,64
	sw	a1,-64(a0)
	sw	a1,-60(a0)
	sw	a1,-56(a0)
	sw	a1,-52(a0)
	sw	a1,-48(a0)
	sw	a1,-44(a0)
	sw	a1,-40(a0)
	sw	a1,-36(a0)
	sw	a1,-32(a0)
	sw	a1,-28(a0)
	sw	a1,-24(a0)
	sw	a1,-20(a0)
	sw	a1,-16(a0)
	sw	a1,-12(a0)
	sw	a1,-8(a0)
	bne	a0,a3,loop16w_nopref30
	sw	a1,-4(a0)

chk8w:		# t8 here is the byte count past 64-byte chunks

	andi	t7,t8,0x1f	# is there a 32-byte chunk?
				# the t7 is the reminder count past 32-bytes
	beq	t8,t7,chk1w	# when t8==t7, no 32-byte chunk
	move	a2,t7

	sw	a1,0(a0)
	sw	a1,4(a0)
	sw	a1,8(a0)
	sw	a1,12(a0)
	sw	a1,16(a0)
	sw	a1,20(a0)
	sw	a1,24(a0)
	sw	a1,28(a0)
	addiu	a0,a0,32

chk1w:
	andi	t8,a2,0x3	# now t8 is the reminder past 1w chunks
	beq	a2,t8,last4
	subu	a3,a2,t8	# a3 is the count of bytes in 1w chunks
	addu	a3,a0,a3	# now a3 is the dst address past the 1w chunks

# copying in words (4-byte chunks)
wordCopy_loop:
	addiu	a0,a0,4
	bne	a0,a3,wordCopy_loop
	sw	a1,-4(a0)

last4:	beq	a0,t0,last4e
last4l:	addiu	a0,a0,1
	bne	a0,t0,last4l
	sb	a1,-1(a0)

last4e:	j	ra
	nop

	.set	at
	.set	reorder

END(memset)


/************************************************************************
 *  Implementation : Static functions
 ************************************************************************/

