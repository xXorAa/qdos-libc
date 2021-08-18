;
;	m t _ a l c h p / s m s _ a c h p / s m s _ s c h p
;
;	Routines to allocate area in common heap.
;
;	Equivalent to C routines:
;
;		void * mt_alchp (long size, long *sizegot, jobid_t jobid)
;		void * sms_achp (long size, long *sizegot, jobid_t jobid)
;
;		void * sms_achp_acsi (long size, long *sizegot, jobid_t jobid)
;
;		void * sms_schp (long newsize, long * sizegot, char * base_address);
;
; returns:
;		success 	address of memory on success
;		failure 	(negative) error code
;
;	Notes:
;	~~~~~
;	1.	The sms_achp_acsi() call is only relevant on Atari-TT (or similar)
;		based systems.	On other systems it is functionally identical to
;		the sms_achp() call.
;
; AMENDMENT HISTORY:
; ~~~~~~~~~~~~~~~~~
;	10 Jul 93	DJW   - Removed setting of _oserr on failure
;
;	20 Jul 93	DJW   - Removed link/ulnk instructions by making all
;						parameter access relative to a7
;					  - Added SMS name as additional entry point
;
;	06 Nov 93	DJW   - Added underscore to entry point names
;
;	24 Jan 94	DJW   - Added (yet another) underscore to entry point names
;						for name hiding purposes
;
;	25 Mar 95	DJW   - Added support for the Atari TT version of sms_achp().
;						Added support for the sms_schp() call.
;
;	17 Mar 96	DJW   - Added support for the 'sizegot' parameter to be NULL
;						to say user not interested in reply.
;
;	09 May 96	DJW   - The check for 'sizegot' being NULL was not working as
;						an earlier check for 0 caused ERR_BP!
;						(problem reported by Phil Borman)
;					  - Corrected D0 value for sms_schp() - added $ to make hex

	.text
	.even
	.globl __mt_alchp
	.globl __sms_achp
	.globl __sms_achp_acsi
	.globl __sms_schp

ERR.BP	equ -15

SAVEREG equ 16+4				; size of saved registers + return address

;	Shrink an area.
;	Some validity checks are done on the
;	parameter passed as the consequences
;	of silly values are so severe

__sms_schp:
	moveq.l #$38,d0
	move.l	8+4(a7),d0			; base address of area to shrink
	move.l	a0,d1				; Check address not zero
	bne 	common				; ... NO, then continue
err_bp:
	moveq	#ERR.BP,d0
	bra 	fin

__sms_achp_acsi:
	move.l	#$414C5349,d1		   ; set up special string 'ACSI'

__mt_alchp: 					; QDOS name
__sms_achp: 					; SMS name
	moveq.l #$18,d0 			; byte code
	move.l	8+4(a7),d2			; job id

common:
	movem.l d2/d3/a2/a3,-(a7)
	move.l	d1,d3				; just in case came via the TT ACSI variant
	move.l	0+SAVEREG(a7),d1	; size wanted
	trap	#1
	tst.l	d0
	bne 	fin
	move.l	4+SAVEREG(a7),d0	; get address of sizegot
	beq 	nosize				; ... if NULL, assume user not interested
	move.l	d0,a1				; ... otherwise set up address register
	move.l	d1,(a1) 			; ... and set sizegot reply
nosize:
	move.l	a0,d0				; address of area
fin:
	movem.l (a7)+,d2/d3/a2/a3
	rts
