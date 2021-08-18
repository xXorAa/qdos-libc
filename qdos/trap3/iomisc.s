;
;	FILE:	 i o m i s c
;
;	f s _ h e a d r / i o f _ r h d r
;	f s _ h e a d s / i o f _ s h d r
;	i o _ f l i n e / i o b _ f l i n
;	i o _ f s t r g / i o b _ f m u l
;	i o _ s s t r g / i o b _ s m u l
;					  i o b _ s u m l
;
; QDOS routines to read/write a string of bytes.
;
; Equivalent to C routines
;
;	int fs_headr( chanid_t chan, timeout_t timeout, void *buf, short len )
;	int fs_heads( chanid_t chan, timeout_t timeout, void *buf, short len)
;	int io_fline( chanid_t chan, timeout_t timeout, void *buf, short len)
;	int io_fstrg( chanid_t chan, timeout_t timeout, void *buf, short len)
;	int io_sstrg( chanid_t chan, timeout_t timeout, void *buf, short len)
;
; returns:
;		success 	length written/read
;		failure 	QDOS error code (which is negative)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;	11 Jul 93	DJW   - Removed setting of _oserr.	Now returns the QDOS
;						error code (which is negative) on failure.
;					  - Removed link/ulnk instructions by making parameter
;						access relative to a7.
;
;	24 Jul 93	DJW   - Added SMS entry point
;
;	27 Jul 93	DJW   - Merged code used for fs_fline(), fs_fstrg() and
;						fs_sstrg() library calls into a single source file.
;
;	06 Nov 93	DJW   - Added underscore to entry point name
;					  - Allowed for fact that parameters of type 'short' are
;						now passed as 2 bytes and not 4 bytes as previously.
;					  - fs_headr() and fs_heads() routine merged into this
;						source file as they have the same parameter pattern
;						and usage.
;
;	20 Jan 94	DJW   - Added (yet another) underscore to entry point names
;						for name hiding purposes
;
;	03 May 96	DJW   - Added the SMSQ/E specific iob_suml() routine

	.text
	.even

ERR_NC	equ -1					; Not Complete error code
ERR_EF	equ -10 				; End-of-File error code

IOB.FLIN	equ  $02
IOB.FMUL	equ  $03
IOB.SUML	equ  $06
IOB.SMUL	equ  $07
IOF.SHDR	equ  $46
IOF.RHDR	equ  $47

SAVEREG equ 16+4				 ; size of saved registers + return address

	.globl __fs_heads		  ; QDOS name for call
	.globl __iof_shdr		  ; SMS name for call

__fs_heads:
__iof_shdr:
	moveq.l #IOF.SHDR,d0
	bra 	iordwr


	.globl __fs_headr		  ; QDOS name for call
	.globl __iof_rhdr		  ; SMS name for call

__fs_headr:
__iof_rhdr:
	moveq.l #IOF.RHDR,d0
	bra 	iordwr


	.globl __io_fline		  ; QDOS name for call
	.globl __iob_flin		  ; SMS name for call

__io_fline:
__iob_flin:
	moveq	#IOB.FLIN,d0
	bra 	iordwr


	.globl __io_fstrg		  ; QDOS name for call
	.globl __iob_fmul		  ; SMS name for call

__io_fstrg:
__iob_fmul:
	moveq	#IOB.FMUL,d0
	bra 	iordwr


	.globl	__io_sstrg		  ; QDOS name for call
	.globl	__iob_smul		  ; SMS name for call

__io_sstrg:
__iob_smul:
	moveq.l #IOB.SMUL,d0
	bra 	iordwr

	.globl	__iob_suml		  ; SMS name for call

__iob_suml:
	moveq.l #IOB.SUML,d0


;	Common code from here on

iordwr:
	movem.l d2/d3/a2/a3,-(a7)	; save regs
	move.l	0+SAVEREG(a7),a0	; channel id
	move.w	4+SAVEREG(a7),d3	; timeout
	move.l	6+SAVEREG(a7),a1	; buffer
	move.w	10+SAVEREG(a7),d2	; length
	trap	#3
	tst.l	d0					; OK ?
	beq 	ok					; ... YES, continue
	cmp.w	#ERR_EF,d0			; "End of File" error ?
	beq 	check				; ... go see if any data read
	cmp.w	#ERR_NC,d0			; "Not Complete" error ?
	bne 	fin 				; ... NO, exit with error code
check:
	tst.w	d1					; any data I/O done ?
	beq 	fin 				; ... NO, exit with error code anyway
ok:
	moveq	#0,d0				; clear d0
	move.w	d1,d0				; set length as returned value
fin:
	movem.l (a7)+,d2/d3/a2/a3
	rts
