;
;	i o a _ s o w n
;
;	routine to change the owner of	a channel
;
;	Equivalent to C routine
;		int ioa_sown( chanid_t channel, jobid_t new_owner )
;
;	Notes
;	~~~~~
;	1.	Only supported on SMSQ and SMSQ-E based systems.
;		Early releases even of these may not support this call.
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;	25 Mar 95	DJW   - First version.
;						Have not bothered to name hide this routine as
;						free-standing file not used by any other library
;						module (yet at least!)

	.text
	.even
	.globl _ioa_sown

SMS.SOWN	equ $5

_ioa_sown:						; SMSQ entry point
	moveq.l #SMS.SOWN,d0
	move.l	4(a7),a0			; Channel Id to change
	move.l	8(a7),d1			; new owner job id
	trap	#2
	rts
