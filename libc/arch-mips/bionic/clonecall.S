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
#include <linux/sched.h>
#include <sys/linux-syscalls.h>
#include <linux/errno.h>
        
	.text
        
/*
 * int clone(int (*fn)(void*), void *child_stack,
 *			 int flags, void *arg
 *			[int *parent_tidptr, struct user_desc*newtls, int *child_tidptr]
 * );
 */

	.type	clone, @function
	.global	clone
	.align	4
        .ent clone
clone:
        .set	noreorder
        .cpload $t9
        .set	reorder

	subu	$sp,32
	sw	$gp,28($sp)

	li      $v0,EINVAL
	beqz	$a0,error
	beqz    $a1,error

	/* set up child stack */
	subu	$a1,32
	sw      $a0,0($a1)	# fn
	sw	$a3,4($a1)	# arg

	/*
	 * int sys_clone(int flags, void *child_stack, int *parent_tidptr,
	 *	 struct user_desc *newtls, int *child_tidptr);
	 */
	lw	$t0,32+24($sp)
	move	$a0,$a2		# flags
/*	move	$a1,$a1		# child_stack */
	lw	$a2,32+16($sp)	# parent_tidptr
	lw	$a3,32+20($sp)	# newtls
	sw	$t0,16($sp)	# child_tidptr

        li	$v0,__NR_clone
        syscall

        bnez	$a3,error
        beqz	$v0,__clone_thread_start

	addiu	$sp,32
        j	$ra

error:
	move	$a0,$v0
	la	$t9,__set_errno
	addu	$sp,32
	j	$t9
	.end	clone

	.type	__clone_thread_start, @function
	.global	__clone_thread_start
	.ent	__clone_thread_start
__clone_thread_start:
	sw	$gp,28($sp)

	lw	$t9,0($sp)	# fn
	lw	$a0,4($sp)	# arg

	jalr	$t9

	move	$a0,$v0
	la	$t9,_exit
	jalr	$t9

        .end	__clone_thread_start
