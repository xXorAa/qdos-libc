;
;	s m s _ p s e t
;
;	Routines to set printer translate
;
;	Equivalent to C routines:
;
;		void sms_pset( long printer_translate_code)
;
;	Notes:
;	~~~~~
;	1.	The sms_pset() call is only relevant on systems running SMSQ or
;		SMSQ-E.   On all other systems it will always have no effect.
;
; AMENDMENT HISTORY:
; ~~~~~~~~~~~~~~~~~
;	25 Mar 95	DJW   - First version.
;						Have not bothered with name hiding of this routine as
;						it is not called by any other library module.

	.text
	.even

	.globl _sms_pset


_sms_pset:						; SMS name
	moveq	#$33,d0
	move.l	0+4(a7),d1			; get printer translate code parameter
	trap	#1
	rts
