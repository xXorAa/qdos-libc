;
;	s m s _ w e v t
;
;	Routines to send an event to a job
;
;	Equivalent to C routine:
;
;		void sms_wevt( event_t *, timeout_t )
;
;	Notes:
;	~~~~~
;	1.	The sms_wevt() call is only relevant on systems running SMSQ or
;		SMSQ-E.   On all other systems it will always have no effect.
;
; AMENDMENT HISTORY:
; ~~~~~~~~~~~~~~~~~
;	03 Apr 96	DJW   - First version.
;						Have not bothered with name hiding of this routine as
;						it is not called by any other library module.

	.text
	.even

	.globl _sms_wevt


_sms_wevt:						; SMS name
	moveq	#$3b,d0
	move.l	0+4(a7),a1			; get event pointer
	move.b	(a1),d2 			; and set events to wait for
	move.w	0+6(a7),d3			; set timeout
	trap	#1
	move.l	0+4(a7),a1			; reload event pointer
	move.b	d2,(a1) 			; save new result
	rts
