;
;   s m s _ l t h g
;
;   Link in a thing
;
; Equal to C routine:
;
;   int  sms_lthg( THING_LINKAGE *thing_linkage)                                           char * a1, char ** a2 )
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   24 Jul 93   DJW   - First version
;
;   06 Nov 93   DJW   - Added underscore to entry point name
;
;   23 Jan 94   DJW   - Changed to call an external routine rather than
;                       trap #1 to allow for systems where the trap is not
;                       available and a vector has to be called instead.
;
;   14 Apr 94   DJW   - Added underscore to entry point for name hiding
;
;   16 Dec 95   DJW   - Fixed offset for picking up parameter
;                       Problem report and fix provided by Jonathan Hudson

    .text
    .even
    .globl _sms_lthg			; SMS name for call

SMS.LTHG equ	$26

_sms_lthg:
	move.l	4(sp),a1		; Thing linkage block address
	moveq	#SMS.LTHG,d0		; byte code for trap
	jmp	ThingTrap		; ... do it
