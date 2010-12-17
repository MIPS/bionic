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

#include <asm/unistd.h>

/*
 * In general the ll/sc pair will normally succeed. Processors with branch
 * predictors will normally predict backward branches as taken and forward
 * branches as not. To avoid a possibly large branch mispredict penalty,
 * the test for sc failure should go forward. This means no mispredict penalty
 * in the common case but a slightly longer execution path in the uncommon
 * failure case
 */
	.text

/*
 * int __atomic_dec(volatile int *addr)
 */
	.type	__atomic_dec, @function
	.global	__atomic_dec
	.align	4
	.ent	__atomic_dec
__atomic_dec:
0:	ll	$v0,($a0)
	subu	$t0,$v0,1
	sc	$t0,($a0)
	beqz	$t0,1f		/* branch on sc failure */
	j	$ra		/* return old */
1:	b	0b		/* retry */
	.end	__atomic_dec

/*
 * int __atomic_inc(volatile int *addr)
 */
	.type	__atomic_inc, @function
	.global	__atomic_inc
	.align	4
	.ent	__atomic_inc
__atomic_inc:
0:	ll	$v0,($a0)
	addu	$t0,$v0,1
	sc	$t0,($a0)
	beqz	$t0,1f		/* branch on sc failure */
	j	$ra		/* return old */
1:	b	0b		/* retry */
	.end	__atomic_inc

/*
 *  int __atomic_cmpxchg(int old, int new, volatile int *addr)
 */
	.type	__atomic_cmpxchg, @function
	.global	__atomic_cmpxchg
	.align	4
	.ent	__atomic_cmpxchg
__atomic_cmpxchg:
0:	ll	$t0,($a2)
	move	$t1,$a1
	bne	$t0,$a0,1f	/* fail if *addr != old */
	sc	$t1,($a2)
	beqz	$t1,2f		/* branch on sc failure */

	li	$v0,0		/* return success */
	j	$ra

2:	b	0b		/* retry */

1:
	li	$v0,1		/* return failure */
	j	$ra
	.end __atomic_cmpxchg

/*
 * int __atomic_swap(int new, volatile int* addr)
 */
	.type	__atomic_swap, @function
	.global	__atomic_swap
	.align	4
	.ent	__atomic_swap
__atomic_swap:
0:	move	$t0,$a0
	ll	$v0,($a1)
	sc	$t0,($a1)
	beqz	$t0,1f		/* branch on sc failure */
	j	$ra		/* return old */
1:	b	0b		/* retry */
	.end	__atomic_swap


#define FUTEX_WAIT 0
#define FUTEX_WAKE 1

/*
 * __futex_wait(*ftx, val, *timespec)
 * futex_syscall(*ftx, op, val, *timespec, *addr2, val3)
 */
	.type	__futex_wait, @function
	.global	__futex_wait
	.align	4
	.ent	__futex_wait
__futex_wait:
	subu	$sp,4*6
	sw	$0,20($sp)	/* val3 */
	sw	$0,16($sp)	/* addr2 */
	move	$a3,$a2		/* timespec */
	move	$a2,$a1		/* val */
	li	$a1,FUTEX_WAIT	/* op */
#	move	$a0,$a0		/* ftx */
	li	$v0,__NR_futex
	syscall
	.set noreorder
	bnez	$a3, 1f		/* Check for error */
         neg	$v0		/* Negate error number if it's valid */
	move	$v0,$0		/* Otherwise return 0 */
1:
	.set reorder
	addu	$sp,4*6
	j	$ra
	.end	__futex_wait

/*
 * int __futex_wake(volatile void *ftx, int count)
 * int futex_syscall(*ftx, op, val, *timespec, *addr2, val3)
 */
	.type	__futex_wake, @function
	.globl	__futex_wake
	.align	4
	.ent	__futex_wake
__futex_wake:
	subu	$sp,4*6
	sw	$0,20($sp)	/* val3 */
	sw	$0,16($sp)	/* addr2 */
	move	$a3,$0		/* timespec */
	move	$a2,$a1		/* val */
	li	$a1,FUTEX_WAKE	/* op */
#	move	$a0,$a0		/* ftx */
	li	$v0,__NR_futex
	syscall
	.set noreorder
	bnez	$a3, 1f		/* Check for error */
         neg	$v0		/* Negate error number if it's valid */
	move	$v0,$0		/* Otherwise return 0 */
1:
	.set reorder
	addu	$sp,4*6
	j	$ra
	.end	__futex_wake

/* __futex_syscall3(*ftx, op, val)
 * futex_syscall(*ftx, op, val, *timespec, *addr2, val3)
 */
	.type	__futex_syscall3, @function
	.global	__futex_syscall3
	.align	4
	.ent	__futex_syscall3
__futex_syscall3:
	subu	$sp,4*6
	sw	$0,20($sp)	/* val3 */
	sw	$0,16($sp)	/* addr2 */
	move	$a3,$0		/* timespec */
#	move	$a2,$a2		/* val */
#	li	$a1,$a1		/* op */
#	move	$a0,$a0		/* ftx */
	li	$v0,__NR_futex
	syscall
	.set noreorder
	bnez	$a3, 1f		/* Check for error */
         neg	$v0		/* Negate error number if it's valid */
	move	$v0,$0		/* Otherwise return 0 */
1:
	.set reorder
	addu	$sp,4*6
	j	$ra
	.end	__futex_syscall3

/* __futex_syscall4(*ftx, op, val)
 * futex_syscall(*ftx, op, val, *timespec, *addr2, val3)
 */
	.type	__futex_syscall4, @function
	.global	__futex_syscall4
	.align	4
	.ent	__futex_syscall4
__futex_syscall4:
	subu	$sp,4*6
	sw	$0,20($sp)	/* val3 */
	sw	$0,16($sp)	/* addr2 */
#	move	$a3,$a3		/* timespec */
#	move	$a2,$a2		/* val */
#	li	$a1,$a1		/* op */
#	move	$a0,$a0		/* ftx */
	li	$v0,__NR_futex
	syscall
	.set noreorder
	bnez	$a3, 1f		/* Check for error */
         neg	$v0		/* Negate error number if it's valid */
	move	$v0,$0		/* Otherwise return 0 */
1:
	.set reorder
	addu	$sp,4*6
	j	$ra
	.end	__futex_syscall4
