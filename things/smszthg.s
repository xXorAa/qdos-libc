;
;   s m s _ z t h g
;
; routine to zap a thing
; equal to C routine
;   int sms_zthg( char *name )
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   24 Jul 93   DJW   - First version
;
;   06 Nov 93   DJW   - Added underscore to entry point name
;
;   23 Jan 94   DJW   - Changed to call an exeternal routine rather than
;                       trap #1 to allow for systems where the trap is not
;                       available and a vector has to be called instead.
;
;   03 Sep 94   DJW   - Added underscore to _cstr_to_ql for name hiding reasons

    .text
    .even
    .globl _sms_zthg			; SMS name for call

WORKLEN	equ	64			; size of stack work area reserved for QL format name

SMS.ZTHG equ  $2a

_sms_zthg: 
	link	a5,#-WORKLEN		; create workspace on stack
	move.l	4+4(a5),-(sp)		; name
	pea	-WORKLEN(a5)		; qlstr location
	jsr	__cstr_to_ql		; convert to qlstr
	addq.l	#8,sp			; tidy up stack
	move.l	d0,a0			; qlstr
	moveq	#-1,d1			; job id
	moveq	#SMS.ZTHG,d0		; byte code for trap
	jsr	ThingTrap		; ... do it
	unlk	a5			; remove stack workspace
	rts
