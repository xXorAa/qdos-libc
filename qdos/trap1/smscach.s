;
;	s m s _ c a c h
;
;	Routines to change cache state
;
;	Equivalent to C routines:
;
;		void sms_cach( int flag)
;
;	Notes:
;	~~~~~
;	1.	The sms_cach() call is only relevant on systems running SMSQ or
;		SMSQ-E.   On all other systems it will always have no effect.
;
; AMENDMENT HISTORY:
; ~~~~~~~~~~~~~~~~~
;	25 Mar 95	DJW   - First version.
;						Have not bothered with name hiding of this routine as
;						it is not called by any other library module.

	.text
	.even

	.globl _sms_cach


_sms_cach:						 ; SMS name
	moveq	#$2f,d0
	move.l	4(a7),d1
	trap	#1
	rts
