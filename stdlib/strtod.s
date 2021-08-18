;
;	 s t r t o d
;
;	Dummy wrapper as part of implementing name hiding
;	within the C68 libraries.
;
	.text
	.globl	_strtod

_strtod:
	jmp 	__Strtod
