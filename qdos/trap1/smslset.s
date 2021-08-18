;
;	s m s _ l s e t  / s m s _ l e n q
;
;	Routines to set or enquire on language
;
;	Equivalent to C routines:
;
;		void sms_lenq( long * language_code, char * car_registration)
;		void sms_lset( long * language_code, char * car_registration)
;
;	Notes:
;	~~~~~
;	1.	The sms_lenq() and sms_lset() calls are only relevant on systems
;		running SMSQ(E).  On all other systems they will always have no effect.
;
; AMENDMENT HISTORY:
; ~~~~~~~~~~~~~~~~~
;	25 Mar 95	DJW   - First version.

	.text
	.even

	.globl __sms_lenq
	.globl __sms_lset


__sms_lenq:
	moveq	#$31,d0
	bra 	common
__sms_lset:
	moveq	#$32,d0
common:
	sub.l	a0,a0			; clear a0
	move.l	0+4(a7),d1
	beq 	no_code 		; if NULL, then jump
	move.l	0(a0,d1.l),d1	; get language code parameter
no_code:
	move.l	4+4(a7),d2
	beq 	no_car			; if NULL, then jump
	move.l	0(a0,d2.l),d2
no_car:

	trap	#1

	sub.l	a0,a0			; clear a0
	move.l	0+4(a7),d0
	beq 	no_code_reply
	move.l	d1,0(a0,d0.l)
no_code_reply:
	move.l	4+4(a7),d0
	beq 	no_car_reply
	move.l	d2,0(a0,d0.l)
no_car_reply:
	rts
