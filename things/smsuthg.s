;
;   s m s _ u t h g
;
; routine to use a thing
; equal to C routine
;   char * sms_uthg( char *name, timeout_t timeout, jobidd_t job_id,
;                     long * d2, void * a2, long * version, void ** a2 )
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   24 Jul 93   DJW   - First version
;
;   06 Nov 93   DJW   - Added underscore to entry point name
;
;   23 Jan 94   DJW   - Changed to call an exeternal rputine rather than
;                       trap #1 to allow for systems where the trap is not
;                       available and a vector has to be called instead.
;
;   03 Sep 94   DJW   - Added underscore to _cstr_to_ql for name hiding reasons
;
;   13 Jan 95   DJW   - Incorrect stack offsets were being used for parameters.
;                       (Problem reported by David Gilham).
;
;   18 Dec 95   DJW   - Changed to allow for 'a2' parameter to be NULL.
;                       Removed double remove of registers!
;                       Problem and fixes provided by Jonathan Hudson
;
;   25 Sep 00   TG    - Optimized code.
;                     - When an error occures, does not try to set the return
;                       parameters from random values... just exit !

    .text
    .even
    .globl _sms_uthg        ; SMS name for call

SAVEREG equ 16				; size of saved registers
WORKLEN equ 64				; size of stack work area reserved for QL format name
SMS.UTHG equ $28

_sms_uthg:
	link	a5,#-WORKLEN		; create workspace on stack
	movem.l	d3/d4/a2/a3,-(sp)	; save registers that get corrupted
	lea	8(a5),a3		; point on first parameter
	move.l	(a3)+,-(sp)		; LONG: name address
	pea.l	-WORKLEN(a5)		; qlstr location
	jsr	__cstr_to_ql		; convert to qlstr
	addq.l	#8,sp			; tidy up stack
	move.l	d0,a0			; qlstr
	move.l	(a3)+,d1		; LONG: job id
	move.w	(a3)+,d3		; WORD: timeout
	moveq	#0,d2			; default to no user parameter
	move.l	(a3)+,d4		; LONG: user d2 parameter address
	beq	uthg01			; if NULL, jump over.
	move.l	d4,a2			; parameter address.
	move.l	(a2),d2			; ... else get user value
uthg01:
	move.l	(a3)+,a2		; LONG: user a2 parameter
	moveq	#SMS.UTHG,d0		; byte code for trap
	jsr	ThingTrap		; ... do it
	bne	fin			; not OK, exit with error code
	tst.l	d4			; is the user parameter address NULL ?
	beq	uthg02			; if yes, jump over.
	move.l	d4,a0			; LONG:  user d2 parameter address
	move.l	d2,(a0)			; ... store returned d2 value
uthg02:
	move.l	(a3)+,a0		; LONG:  User d3 parameter address
	move.l	d3,(a0)			; ... store version
	move.l	(a3),a0			; LONG: User a2 parameter address
	move.l	a2,(a0)			; ... store linkage block
	move.l	a1,d0			; set Thing address as reply
fin:
	movem.l	(sp)+,d3/d4/a2/a3	; restore saved registers
	unlk	a5			; remove stack workspace
	rts

