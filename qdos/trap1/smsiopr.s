;
;	s m s _ i o p r
;
;	Routines to set I/O priority
;
;	Equivalent to C routines:
;
;		void sms_iopr( short priority)
;
;	Notes:
;	~~~~~
;	1.	The sms_iopr() call is only relevant on systems running SMSQ or
;		SMSQ-E.   On all other systems it will always have no effect.
;
; AMENDMENT HISTORY:
; ~~~~~~~~~~~~~~~~~
;	25 Mar 95	DJW   - First version.
;						Have not bothered with name hiding of this routine as
;						it is not called by any other library module.

	.text
	.even

	.globl _sms_iopr


_sms_iopr:						 ; SMS name
	moveq	#$2e,d0
	move.w	4(a7),d2
	trap	#1
	rts
