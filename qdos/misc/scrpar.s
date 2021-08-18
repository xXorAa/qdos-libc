; SCRPAR_S
; V1.02 24/01/98
; (c) 1998 Bruno Coativy
; This software is FREEWARE
; It MUST NOT be modified

sms.info	.equ	$00
ioa.open	.equ	$01
ioa.clos	.equ	$02
iow.xtop	.equ	$09
sd_scrb	.equ	$32
sd_linel	.equ	$64
err.orng	.equ	-4

x	.equ	6
y	.equ	11
maxsize	.equ	8192

	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss
	.sect	.text

	.even
WINDOW:
	.dc.w	17
	.dc.b	"scr_0002x0001a0x0"
	.even
GETBASE:
	move.l	sd_scrb(a0),d1
GETBASEEND:
	moveq	#0,d0
	rts
GETLINL:
	move.w	sd_linel(a0),d1
	bra	GETBASEEND
EXTOP:
	moveq	#0,d3
	moveq	#iow.xtop,d0
	trap	#3
	tst.l	d0
	bne	ERROR1
	move.l	d1,d7
	rts
FINDLINL:
	move.l	a0,d7
	moveq	#sms.info,d0
	trap	#1
	move.l	d7,a0
	swap	d2
	clr.b	d2
	swap	d2
	cmp.l	#$31003130,d2
	lea	GETLINL,a2
	bpl	EXTOP
	move.w	#128,d7
	rts
_scrb:
	link	a6,#0
	movem.l	d3-d7/a2-a5,-(a7)
	move.l	8(a6),d1
	cmp.l	#-1,d1
	lea	GETBASE,a2
	beq	DEFAULT
	move.l	d1,a0
	bsr	EXTOP
	bra	RETURN.L
DEFAULT:
	bsr	OPENWIN
	bsr	EXTOP
	bsr	CLOSEWIN
	bra	RETURN.L
OPENWIN:
	lea	WINDOW,a0
	moveq	#0,d3
	moveq	#-1,d1
	moveq	#ioa.open,d0
OPENWINEND:
	trap	#2
	tst.l	d0
	bne	ERROR1
	rts
CLOSEWIN:
	moveq	#ioa.clos,d0
	bra	OPENWINEND
_scrl:
	link	a6,#0
	movem.l	d3-d7/a2-a5,-(a7)
	bsr	OPENWIN
	bsr	FINDLINL
	bsr	CLOSEWIN
	bra	RETURN.W
_scrs:
	link	a6,#-20
	movem.l	d3-d7/a2-a5,-(a7)
	bsr	OPENWIN
	bsr	FINDLINL
	bsr	CLOSEWIN
	swap	d7
	moveq	#y,d4
	bsr	FINDSIZE
	move.w	d7,d6
	swap	d7
	mulu	d6,d7
	bra	RETURN.L
RETURN.W:
	ext.l	d7
RETURN.L:
	move.l	d7,d0
ERROR0:
	movem.l	(a7)+,d3-d7/a2-a5
	unlk	a6
	rts
ERROR1:
	add.w	#4,a7
	bra	ERROR0
_scrx:
	link	a6,#-20
	movem.l	d3-d7/a2-a5,-(a7)
	moveq	#x,d4
SCRXEND:
	bsr	FINDSIZE
	bra	RETURN.W
_scry:
	link	a6,#-20
	movem.l	d3-d7/a2-a5,-(a7)
	moveq	#y,d4
	bra	SCRXEND
FINDSIZE:
	lea	-20(a6),a5
	move.l	a5,a0
	lea	WINDOW,a1
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1),(a0)
	clr.w	d6
	move.w	#maxsize,d7
AGAIN:
	move.w	d7,d5
	add.w	d6,d5
	lsr.w	#1,d5
	bcs	RIGHTVAL
	move.w	d5,d1
	lea	-20(a6,d4.w),a1
	move.l	#1000,d2
	bsr	WTOASCII
	move.l	a5,a0
	moveq	#0,d3
	moveq	#-1,d1
	moveq	#ioa.open,d0
	trap	#2
	cmp.b	#err.orng,d0
	beq	TOOMUCH
	tst.l	d0
	bne	ERROR1
	moveq	#ioa.clos,d0
	trap	#2
	move.w	d5,d6
	bra	AGAIN
TOOMUCH:
	move.w	d5,d7
	bra	AGAIN
RIGHTVAL:
	move.w	d6,d7
	bclr.l	d0,d7
	rts
WTOASCII:
	ext.l	d1
	divu	d2,d1
	add.b	#$30,d1
	move.b	d1,(a1)+
	swap	d1
	divu	#10,d2
	bne	WTOASCII
	rts

	.extern	_scrb
	.extern	_scrl
	.extern	_scrs
	.extern	_scrx
	.extern	_scry
