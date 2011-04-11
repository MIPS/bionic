# This function is to be called when the shared library
# is unloaded through dlclose()
_on_dlclose:
	.set noreorder
	.cpload $t9
	.set reorder
	lw	$a0, __dso_handle
	la	$t9, __cxa_finalize
	j	$t9

/* we put the _init() function here in case the user files for the shared
 * libs want to drop things into .init section.
 * We then will call our ctors from crtend_so.o */
	.section .init
	.type _init, @function
	.globl _init
_init:

	.section .init_array, "aw"
	.type __INIT_ARRAY__, @object
	.globl __INIT_ARRAY__
__INIT_ARRAY__:
	.long -1

	.section .fini_array, "aw"
	.type __FINI_ARRAY__, @object
	.globl __FINI_ARRAY__
__FINI_ARRAY__:
	.long -1
	.long _on_dlclose

	.section .ctors, "aw"
	.type __CTOR_LIST__, @object
	.globl __CTOR_LIST__
__CTOR_LIST__:
	.long -1

#include "__dso_handle.S"
