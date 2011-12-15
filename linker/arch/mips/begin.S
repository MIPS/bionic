	.text
	.align	4
	.type	__start,@function
	
	.ent	__start
	.globl	__start
__start:
	.set	noreorder
	bal	1f
	 nop
1:	.cpload	$31
	move	$a0, $sp
	jal	__linker_init
	 subu	$sp,4*4		/* a0-a3 register saves in linker_init */


	/* linker init returns the _entry address in the main image */
	move	$t9,$v0
	j	$t9
	 addu	$sp,4*4		/* restore sp */
	.end	__start

	.section .ctors, "wa"
	.globl __CTOR_LIST__
__CTOR_LIST__:
	.long -1
