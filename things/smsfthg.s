;
;	s m s _ f t h g
;
; routine to free a thing
; equal to C routine
;	char * sms_fthg( char *name, jobid_t jobid, long * d2, long d3, 
;			 char * a1, char ** a2 )
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;	24 Jul 93	DJW   - First version
;
;	06 Nov 93	DJW   - Added underscore to entry point name
;
;	23 Jan 94	DJW   - Changed to call an exeternal routine rather than
;				trap #1 to allow for systems where the trap is not
;				available and a vector has to be called instead.
;
;	14 Apr 94	DJW   - Added underscore to entry point for name hiding
;
;	03 Sep 94	DJW   - Added underscore to _cstr_to_ql for name hiding reasons
;
;	16 Dec 95	DJW   - Additional test to allow NULL parameters
;				Fixes based on those provided by Jonathan Hudson
;
;	04 May 96	DJW   - Fixed problem with corrupting name register.
;				(Problem found investigating report from David Gilham)

	.text
	.even
	.globl _sms_fthg

SMS.FTHG equ $29

SAVEREG equ 12				; size of saved registers
WORKLEN equ 64				; size of stack work area reserved for QL format name

_sms_fthg:				; SMS entry point
	link	a5,#-WORKLEN		; create workspace on stack
	movem.l	d2/d3/a2/a3,-(a7)	; save register variables
	move.l	4+4(a5),-(a7)		; name
	pea	-WORKLEN(a5)		; qlstr location
	jsr	__cstr_to_ql		; convert to qlstr
	addq.l	#8,a7			; tidy up stack
	move.l	d0,a0			; move result to correct register for trap
	move.l	16+4(a5),d3 		; user value for d3
	move.l	12+4(a5),a3 		; address of d2 value
	moveq	#0,d2			; clear d2
	move.l	a3,d0			; check for NULL parameter
	beq	fthg01			; ... and if so jump (and d2=0)
	move.l	(a3),d2 		; set user value for d2
fthg01:
	move.l	8+4(a5),d1		; user job id
	move.l	24+4(a5),a3 		; pointer to a2 value
	sub.l	a2,a2			; clear a2
	move.l	a3,d0			; test a0
	beq	fthg02			; ... jump if zero
	move.l	(a3),a2 		; user value for a2
fthg02:
	move.l	20+4(a5),a1 		; user value for a1
	moveq	#SMS.FTHG,d0		; byte code for trap
	jsr	ThingTrap		; ... do it
	move.l	12+4(a5),a3 		; address for d2 result
	move.l	a3,d1			; test a3
	beq	fthg03			; ... jump if zero
	move.l	d2,(a3) 		; set returned d2 value
fthg03:
	move.l	24+4(a2),a3 		; address for a2 result
	move.l	a3,d1			; test a0
	beq	fthg04			; ... jump if zero
	move.l	a2,(a3) 		; set returned a2 value
fthg04:
	movem.l	(a7)+,d2/d3/a2/a3	; restore saved registers
	unlk	a5			; remove stack workspace
	rts
