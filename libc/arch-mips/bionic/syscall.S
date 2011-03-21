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

	.text

/*
 * int syscall(int sysnr, int a0, int a1, int a2, int a3,
 *			  int a4, int a5, int a6, int a7)
 */
	.type	syscall,@function
	.global	syscall
	.align	4

        .ent syscall
syscall:
	.set noreorder
	.cpload  $t9

#define FRAMESIZE	(8*32)	/* keep stack 64bit aligned */

	move	$v0,$a0		/* syscall number in the first argument */
	move	$a0,$a1		/* shift the arguments up */
	move	$a1,$a2
	move	$a2,$a3
	lw	$a3,4*4($sp)
	lw	$t0,4*5($sp)
	lw	$t1,4*6($sp)
	lw	$t2,4*7($sp)
	addiu	$sp,$sp,-FRAMESIZE
	sw	$t0,4*4($sp)
	sw	$t1,4*5($sp)
	sw	$t2,4*6($sp)

	syscall

	bnez	$a3,1f
	 addiu	$sp,$sp,FRAMESIZE

	j	$ra
	 nop

1:
	la	$t9,__set_errno
	j	$t9
	 move	$a0,$v0
	.set reorder
	.end syscall
