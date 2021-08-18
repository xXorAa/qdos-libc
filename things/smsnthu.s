;
;	s m s _ n t h u
;
; routine to find next Thing user
; equal to C routine
;	int sms_nthg( char *name, THING_LINKAGE ** thing_linkage, jobid_t * owner)
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
;	03 Sep 94	DJW   - Added underscore to _cstr_to_ql for name hiding reasons
;
;	16 Dec 95	DJW   - Added save/restore of smashed registers
;						problem report and fix by Jonathan Hudson
;
;	03 May 96	DJW   - Corrected problem with not supplying name parameter
;						correctly for conversion to QDOS string.
;						(problem found as result of report from David Gilham)

	.text
	.even
	.globl _sms_nthu		; SMS name for call

WORKLEN	equ	64			; size of stack work area reserved for QL format name
SMS.NTHU equ	0x2c

_sms_nthu:
	link	a5,#-WORKLEN		; create workspace on stack
	movem.l	d2-d3/a2-a3,-(sp)	; save registers that get smashed
	lea	8(a5),a3		; point on first parameter
	move.l	(a3)+,-(sp)		; set name as parameter
	pea	-WORKLEN(a5)		; qlstr location
	jsr	__cstr_to_ql		; convert to qlstr
	addq.l	#8,sp			; tidy up stack
	move.l	d0,a0			; move result to correct register for trap call
	move.l	(a3),a1
	move.l	(a1),a1 		; usage block or 0
	moveq	#SMS.NTHU,d0		; byte code for trap
	jsr	ThingTrap		; ... do it
	move.l	(a3)+,a0
	move.l	a1,(a0)			; next useage block
	move.l	(a3),a0
	move.l	d1,(a0)			; owner job id
	movem.l	(sp)+,d2-d3/a2-a3	; restore saved registers
	unlk	a5				; remove stack workspace
	rts
