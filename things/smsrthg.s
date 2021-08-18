;
;	s m s _ r t h g
;
; routine to remove a Thing if not in use
; equal to C routine
;	int sms_rthg( char *name)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;	24 Jul 93	DJW   - First version
;
;	06 Nov 93	DJW   - Added underscore to entry point names
;
;	23 Jan 94	DJW   - Changed to call an exeternal routine rather than
;						trap #1 to allow for systems where the trap is not
;						available and a vector has to be called instead.
;
;	03 Sep 94	DJW   - Added underscore to _cstr_to_ql for name hiding reasons

	.text
	.even
	.globl _sms_rthg		; SMS name for call

WORKLEN equ	64			; size of stack work area reserved for QL format name
SMS.RTHG equ	0x27

_sms_rthg:
	link	a5,#-WORKLEN		; create workspace on stack
	move.l	4+4(a5),-(sp)		; name
	pea	-WORKLEN(a5)		; qlstr location
	jsr	__cstr_to_ql		; convert to qlstr
	addq.l	#8,sp			; tidy up stack
	move.l	d0,a0			; move result to correct register for trap call
	moveq	#SMS.RTHG,d0		; byte code for trap
	jsr 	ThingTrap		; ... do it
	unlk	a5			; remove stack workspace
	rts
