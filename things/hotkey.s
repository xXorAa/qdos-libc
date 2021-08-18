*
* Hotkey.s 
* 
* A public domain implementation of the HOTKEY II system for c68
* Part of the HOTStuff c68 library
*
* (c) Jonathan Hudson 1993
* v0.02 20/12/93                c68 v.4x compatible
*

.globl  _hk_set
.globl  _hk_reset
.globl  _hk_on
.globl  _hk_off
.globl  _hk_fitem
.globl	_hk_remov
.globl	_hk_stbuf
.globl	_hk_gtbuf
.globl	_hk_cjob
.globl	_hk_kjob
.globl  _hk_do

.globl  ThingTrap

hk.fitem        equ     $14
hk.crjob	equ	$18
hk.kjob		equ	$1c
hk.set         	equ     $20
hk.remov	equ	$24
hk.do		equ	$28
hk.stbuf	equ	$2c
hk.gtbuf	equ	$30
hk.guard        equ     $34

hks.off 	equ	-1
hks.on		equ	 0
hks.rset       	equ      1
hks.set        	equ      2

sms.uthg 	equ    	$28
sms.fthg 	equ    	$29

err.nimp 	equ    	-19

.text

*
*   Use Hotkey system, but be quick .....
*   Returns hotkey linkage in a3
*

hk_use:
	moveq	#sms.uthg,d0
	moveq	#-1,d1
	moveq	#127,d3
	lea.l	hk_thing,a0
	jsr     ThingTrap
	move.l	a1,a3
fail:
	tst.l	d0
	rts
*
* Free the Hotkey system
*

hk_free:
	moveq	#sms.fthg,d0
	moveq	#-1,d1
	lea.l	hk_thing,a0
	jsr	ThingTrap
	rts	

*
*   hk_sstbf. Stuff into stuffer buffer
*

_hk_stbuf:
	link	a5,#0               	; frame pointer
	movem.l	d2-d4/a2-a4,-(sp)
	bsr	hk_use              	; get hotkey system
	bne	hks_done            	; failed ...
	move.l	hk.stbuf(a3),a4       	; our vector
        move.l  8(a5),a1                ; item
	bsr	A1Len
        move.w  d0,d2
hk_go:
	jsr	(a4)                	; do it
        bra     hks_finish

*
* hk_set(key, hk_item)
* hk_reset(newkey, kname)
* hk_on (kname)
* hk_off (kname)
*

_hk_set:
	moveq	#hks.set,d0         	; action needed
	bra	hkset
_hk_reset:
	moveq	#hks.rset,d0         	; action needed
	bra	hkset
_hk_on:
	moveq	#hks.on,d0         	; action needed
	bra	hkset
_hk_off:
	moveq	#hks.off,d0         	; action needed

hkset:	
	link	a5,#0               	; frame pointer
	movem.l	d2-d4/a2-a4,-(sp)
	move.b	d0,d4			; save action
	bsr	hk_use              	; get hotkey system
	bne	hks_done            	; failed ...
	move.b	d4,d0			; what to do
	move.l	hk.set(a3),a4       	; our vector
	cmpi.b	#hks.set,d0		; setting ?
	bne	h1			; no ...
	move.l	8(a5),d1           	; the key
	move.l	12(a5),a1            	; the item address
        move.l  16(a5),a2               ; guard ?
        cmp.l   #0,a2                   ; set
        beq     hk_go                   ; no
        move.l  hk.guard(a3),2(a2)      ; set vector
	bra	hk_go			; OK
h1:
	cmpi.b	#hks.rset,d0		; resetting ?
	bne	h2			; no ...
	move.l	12(a5),a1            	; the item address
	bsr	MakeDesc 		; make descriptor
	move.l	8(a5),d1           	; the key
	bra	hk_act			; OK
h2:	move.l	8(a5),a1		; must be on/off
	bsr	MakeDesc		; stack em up
hk_act:
        move.l  a1,-(sp)
	jsr	(a4)                	; do it
        move.l  (sp)+,a0
        bsr     FreeDesc
        bra     hks_finish

_hk_fitem:	
	link	a5,#0               ; use a5 as frame pointer
	movem.l	d2-d4/a2-a4,-(sp)   
	bsr	hk_use              ; get hot_key
	bne	hks_done            ; quit if we cant

	move.l	hk.fitem(a3),a4     ; this is what we want

        move.l	8(a5),a1            ; string
	bsr	MakeDesc
	move.l  a1,-(sp)		
	jsr	(a4)                ; do hk.fitem
        move.l  (sp)+,a0
        bsr     FreeDesc
        move.l  12(a5),a2           ; item address
        move.l  a1,(a2)             ; return it
        move.l  16(a5),a2           ; hotkey address
        move.w  d1,(a2)             ; return it
        move.l  20(a5),a2           ; hot number address
        move.w  d2,(a2)             ; return it

hks_finish:
	move.l	d0,-(sp)            	; save status
	bsr	hk_free             	; free HK system
	move.l	(sp)+,d0            	; status

hks_done:	
	movem.l	(sp)+,d2-d4/a2-a4
	unlk	a5
	rts

_hk_remov:
	link	a5,#0               	; frame pointer
	movem.l	d2-d4/a2-a4,-(sp)
	bsr	hk_use              	; get hotkey system
	bne	hks_done            	; failed ...
	move.l	hk.remov(a3),a4       	; our vector
        move.l  8(a5),a1                ; item
	bsr	MakeDesc
        move.l  a1,-(sp)
	jsr	(a4)                	; do it
        move.l  (sp)+,a0
        bsr     FreeDesc
        bra     hks_finish


*
*	char * hk_gtbuf(key, &ptr)
*

_hk_gtbuf:
	link	a5,#0               	; frame pointer
	movem.l	d2-d4/a2-a4,-(sp)
	bsr	hk_use              	; get hotkey system
	bne	hks_done            	; failed ...
	move.l	hk.gtbuf(a3),a4       	; our vector
        move.l  8(a5),d0                ; item
	jsr	(a4)                	; do it
        move.l  12(a5),a3               ; return address
        tst.l   d0                      ; OK
        bne     h8                      ; no
	tst.w	d2			; got any
	beq	h8			; no
	addq.w	#1,d2			; plus one for nul
	ext.l	d2			; make long
        move.l  a1,-(sp)                ; save buffer
	move.l	d2,-(sp)		; size
	jsr	_malloc			; 'C' malloc
	lea.l	4(sp),sp		; reset stack
        move.l  (sp)+,a1                ; restore buffer
	move.l	d0,(a3) 		; return it
	beq	h9      		; nothing
	subq.w	#2,d2			; less nul, less 1
        move.l  d0,a0                   ; 'C' buffer
        moveq   #0,d0                   ; preset return
h6:
	move.b	(a1)+,(a0)+		; copy data
	dbra	d2,h6			; loop
h7:	move.b	#0,(a0)			; terminate for 'C'			
        bra     hks_finish
h8:
	move.l	#0,(a3)                 ; show NULL
	bra	hks_finish
h9:
        moveq   #-3,d0                  ; no memory
	bra	hks_finish

*
*   hk_do.  Do a hot item
*

_hk_do:
	link	a5,#0               	; frame pointer
	movem.l	d2-d4/a2-a4,-(sp)
	bsr	hk_use              	; get hotkey system
	bne	hks_done            	; failed ...
	move.l	hk.do(a3),a4       	; our vector
	move.l	8(a5),a1
	move.l	a6,-(sp)
	move.l	__SPbase,a6
	jsr	(a4)
	move.l	(sp)+,a6
	bra	hks_finish

*
*   Create/Kill hot key job
*

_hk_cjob:
	move.w	#hk.crjob,d0
	bra	hkjob
_hk_kjob:
	move.w	#hk.kjob,d0
hkjob:
	link	a5,#0               	; frame pointer
	movem.l	d2-d4/a2-a4,-(sp)
	move.w	d0,d4			; action
	bsr	hk_use              	; get hotkey system
	bne	hks_done            	; failed ...
	move.l	0(a3,d4.w),a4       	; our vector
	jsr	(a4)
	bra	hks_finish

*
*	Creates a QDOS string descriptor on bottom of the stack from the
*	'C' string in A1 and the QDOS string in A1. Assumes it fits.
*	Munges A0, D0, D2
*
A1Len:
        moveq   #0,d0
l1:     tst.b   0(a1,d0.w)          	; got a nul ?
        beq     l2                  	; yes, skip
        addq.w  #1,d0               	; no, inc counter
        bra     l1                  	; and loop
l2:
        rts


MakeDesc:
        movem.l a0/a2/a3/d0/d1/d2/d3,-(sp)
        move.l  a1,-(sp)
        bsr     A1Len
        move.l  d0,-(sp)
        addq.l  #2,d0                   ; plus size word
        move.l  d0,d1                   ; memory needed
        moveq   #0,d2                   ; System owns it
        moveq   #$18,d0                 ; trap
        trap    #1                      ; do it
        move.l  (sp)+,d1                ; size
        move.l  (sp)+,a1                ; C string
        tst.l   d0                      ; OK
        bne     dd20                    ; NO !!
        move.l  a0,a2                   ; allocated memory
        move.w  d1,(a0)+                ; size
dd01:   
        move.b  (a1)+,d2
        beq     dd03
        move.b  d2,(a0)+   
        bra     dd01
dd03:
        move.l  a2,a1                   ; alloc'ed memory 
        tst.l   d0
        movem.l (sp)+,a0/a2/a3/d0/d1/d2/d3
	rts
dd10:
        moveq   #-1,d0
dd20:
        bra     dd03

FreeDesc:
        movem.l a1/a2/a3/d0/d1/d2/d3,-(sp)
        moveq   #$19,d0
        trap    #1
        movem.l (sp)+,a1/a2/a3/d0/d1/d2/d3
        rts

hk_thing:
	dc.w	6
	dc.b	'Hotkey'

	end

