;
;	s m s _ n t h g
;
; routine to find next Thing
;
; Equivalent to C routine:
;
;	int sms_nthg( char *name, THING_LINKAGE ** thing_linkage)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;	24 Jul 93	DJW   - First version
;
;	06 Nov 93	DJW   - Added underscore to entry point name
;
;	23 Jan 94	DJW   - Changed to call an exeternal routine rather than
;						trap #1 to allow for systems where the trap is not
;						available and a vector has to be called instead.
;
;	13 Apr 94	DJW   - There was no allowance made for the fact that the 
;						first parameter could be 0.
;
;	14 Apr 94	DJW   - Added underscore to entry point for name hiding
;
;	03 Sep 94	DJW   - Added underscore to _cstr_to_ql for name hiding reasons
;
;	14 Sep 94	DJW   - Made certain that a1 returned value is 0 if error.
;
;	16 Dec 95	DJW   - Reworked to be more compact
;						Fix provided by Jonathan Hudson

	.text
	.even
	.globl _sms_nthg	   ; SMS name for call


SMS.NTHG equ $2b

WORKLEN equ 64				; size of stack work area reserved for QL format name

_sms_nthg:
	link	a5,#-WORKLEN		; create workspace on stack
	move.l	4+4(a5),d0		; name
	beq	no_name			; ... if so convert not needed as want first one
	move.l	d0,-(sp)		; put name address on stack
	pea	-WORKLEN(a5)		; qlstr location
	jsr	__cstr_to_ql		; convert to qlstr
	addq.l	#8,sp			; tidy up stack
no_name:
	move.l	d0,a0			; qlstr result
	moveq.l	#SMS.NTHG,d0		; byte code for trap
	jsr	ThingTrap		; ... do it
	beq	ok			; if OK, then jump
	sub.l	a1,a1			; if KO, clear a1 to get published result
ok:
	move.l	8+4(a5),a0		; address to store thing linkage
	move.l	a1,(a0) 		; returned thing linkage
	unlk	a5			; remove stack workspace
	rts
