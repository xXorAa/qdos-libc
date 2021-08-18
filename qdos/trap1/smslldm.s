;
;	s m s _ l l d m
;
;	Routines to link in language module
;
;	Equivalent to C routines:
;
;		void sms_lldm( struct SMS_LDM * )
;
;	Notes:
;	~~~~~
;	1.	The sms_lldm() call is only relevant on systems running SMSQ or
;		SMSQ-E.   On all other systems it will always have no effect.
;
; AMENDMENT HISTORY:
; ~~~~~~~~~~~~~~~~~
;	25 Mar 95	DJW   - First version.
;						Have not bothered with name hiding of this routine as
;						it is not called by any other library module.

	.text
	.even

	.globl _sms_lldm


_sms_lldm:						; SMS name
	moveq	#$30,d0
	move.l	0+4(a7),a1			; get message code parameter
	trap	#1
	rts
