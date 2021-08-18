;
;	s m s _ s e v t
;
;	Routines to send an event to a job
;
;	Equivalent to C routine:
;
;		int sms_sevt( jobid_t, event_t )
;
;	Notes:
;	~~~~~
;	1.	The sms_sevt() call is only relevant on systems running SMSQ or
;		SMSQ-E.   On all other systems it will always have no effect.
;
; AMENDMENT HISTORY:
; ~~~~~~~~~~~~~~~~~
;	03 Apr 96	DJW   - First version.
;						Have not bothered with name hiding of this routine as
;						it is not called by any other library module.

	.text
	.even

	.globl _sms_sevt


_sms_sevt:						; SMS name
	moveq	#$3a,d0
	move.l	0+4(a7),d1			; get job id
	move.w	0+6(a7),d2			; events to notify
	trap	#1
	rts
