;
;	m m _ a l c h p / m e m _ a c h p
;
; routine to allocate area in common heap.
; equal to C routine.
;
;	char *mm_alchp( long size, long *sizegot)
;
; N.B.	Size must allow for heap header, and address returned
;		points at start of header - not start of useable area
;
; returns:
;		success 	address of memory on success
;		failure 	(negative) error code
;
; AMENDMENT HISTORY:
; ~~~~~~~~~~~~~~~~~
;	24 Jul 93	DJW   - First version (based on mt_alchp() code)
;
;	06 Nov 93	DJW   - Added underscore to entry point names
;
;	24 Jan 94	DJW   - Added (yet another) underscore to entry point names
;						for name hiding purposes
;
;	09 May 96	DJW   - Allowed for 'sizegot' parameter to be NULL if not
;						interested in the true size obtained.

	.text
	.even

	.globl __mm_alchp			  ; QDOS name for call
	.globl __mem_achp			  ; SMS name for call

SAVEREG equ 16					; size of saved registers

__mm_alchp:
__mem_achp:
	movem.l d2/d3/a2/a3,-(a7)
	moveq.l #$18,d0 			; byte code
	move.l	4+SAVEREG(a7),d1	; size
	move.w	$c0,a2				; vector required
	jsr 	(a2)
	tst.l	d0
	bne 	fin
	move.l	a0,d0				; address of area as reply
	move.l	8+SAVEREG(a7),d2	; get address of sizegot
	beq 	fin 				; if NULL, not interested in result
	move.l	d2,a1				; else set up index register
	move.l	d1,(a1) 			; save sizegot
fin:
	movem.l (a7)+,d2/d3/a2/a3
	rts
