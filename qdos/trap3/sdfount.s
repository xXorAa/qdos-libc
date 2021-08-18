;
;	s d _ f o u n t / i o w _ f o n t
;
; routine to set fonts for a channel
; equivalent to c routine
;	int sd_fount( long chan, int timeout, char *font1, char *font2)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;	11 Jul 93	DJW   - Removed setting of _oserr.
;					  - Removed link/ulnk instructions by making parameter
;						access relative toa 7
;	24 Jul 93	DJW   - Added SMS entry point
;
;	06 Nov 93	DJW   - Added underscore to entry point name
;					  - Allowed for fact that parameters of type 'short' are
;						now passed as 2 bytes and not 4 bytes as previously.
;
;	20 Jan 94	DJW   - Added (yet another) underscore to entry point names
;						for name hiding purposes
;
;	25 Mar 95	DJW   - Added new entry point iow_font_def() for use by SMSQ
;						and SMSQ-E based systems.

	.text
	.even

	.globl	__sd_fount		  ; QDOS name for call
	.globl	__iow_font		  ; SMS name for call
	.globl	__iow_font_def	  ; SMSQ routine to set default font

SAVEREG equ 12+4		 ; size of saved registers + return address


__iow_font_def:
	move.l	#$4d454646,d2			; String 'DEFF'

__sd_fount:
__iow_font:
	movem.l d3/a2/a3,-(a7)
	moveq.l #$25,d0
	move.l	0+SAVEREG(a7),a0	; chan
	move.w	4+SAVEREG(a7),d3	; timeout
	move.l	6+SAVEREG(a7),a1	; font 1
	move.l	10+SAVEREG(a7),a2	; font 2
	trap	#3
	movem.l (a7)+,d3/a2/a3
	rts
