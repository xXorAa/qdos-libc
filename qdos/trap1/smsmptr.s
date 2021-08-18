;
;	s m s _ m p t r
;
;	Routines to find message pointer
;
;	Equivalent to C routines:
;
;		char * sms_mptr( long message_code)
;
;	Notes:
;	~~~~~
;	1.	The sms_mptr() call is only relevant on systems running SMSQ or
;		SMSQ-E.   On all other systems it will always have no effect.
;
; AMENDMENT HISTORY:
; ~~~~~~~~~~~~~~~~~
;	25 Mar 95	DJW   - First version.
;						Have not bothered with name hiding of this routine as
;						it is not called by any other library module.

	.text
	.even

	.globl _sms_mptr


_sms_mptr:						; SMS name
	moveq	#$34,d0
	move.l	0+4(a7),a1			; get message code parameter
	trap	#1
	move.l	a1,d0				; set address as reply
	rts
