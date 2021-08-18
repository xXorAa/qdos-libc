;
;   C68 Button frame routines
;
;       bt_frame        Put window into button frame
;       bt_free         Free button frame
;       bt_prpos
;
; Equivalent to C routines:
;
;   int bt_frame (chanid_t chan, swdef *sub_window)
;   int bt_prpos (wwork *sub_window)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       Tony Tebby
;
;   31 Oct 93   DJW   - Added underscore to entry point name
;                     - Added check on WMAN vector being known
;
;   04 Jan 94   EMS   - Commented out __chkv reference to be able to use
;                       bt_frame without the window manager from startup
;                       code.
;                     - Fixed bug in bt_frame routine that caused qlrect
;                       struct on stack to be filled in incorrectly so
;                       iop_outl and window decoration failed.
;                     - Fixed references to address registers that were
;                       not or incorrectly initialised.
;                     - Added description of stack layout for clarity.
;                     - Added a few labels for clarity.
;                     - Added a3 to the saved registers.
;                     - Changed erronous exit via other subroutine in btf_use
;                       which would not pop registers off stack correctly.
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

        .text
        .even

        .globl    __bt_frame
        .globl    __bt_free
        .globl    __bt_prpos

sys_thgl equ    $b8

th_thing equ    $10

thh_type equ    $04
thh_entr equ    $08

sw_xsize equ    $00
sw_ysize equ    $02
sw_xorg  equ    $04
sw_yorg  equ    $06
sw_attr  equ    $08

wwa_clfg equ    $00
wwa_borw equ    $02
wwa_borc equ    $04
wwa_papr equ    $06

iow.defw equ    $0d
iow.clra equ    $20
iow.spap equ    $27
iow.sstr equ    $28
iop.outl equ    $7a
iopo.set equ      0

sms.info equ    $00
sms.uthg equ    $28
sms.fthg equ    $29

err.nimp equ    -19

bt_name: dc.w  12
         dc.b  'Button Frame'

;+++
;
; Allocate window in button frame.
; C68 call compatible.
;
; P0 = channel ID
; P4 = pointer to sub-window structure
;
; returns 0 OK, -ve QDOS error
;
; struct swdef
; {  
;    short xsize;    /* X size */
;    short ysize;
;    short xorg;     /* X origin */          ----- origin is set
;    short yorg;     /* Y origin*/
;    char  clfg;     /* -128 if no clear, +1 if cursor keys */
;    char  shdd;     /* shadow depth */      ----- assumed 0
;    word  borw;     /* border width */
;    word  borc;     /* border colour */
;    word  papr;     /* paper colour */
;    char  *sprite;  /* pointer to sprite */ ----- not used
; }
;

__bt_frame:

btf.frame equ   $08
btf_rect equ    $00
btf_size equ    $00
btf_sizx equ    $00
btf_sizy equ    $02
btf_org  equ    $04
btf_orgx equ    $04
btf_orgy equ    $06

stk_chan equ    $1c
stk_swdf equ    $20

; -- Stack layout --
;
; On calling:
;
;        8 (0x08)   subwindow definition (4)
;        4 (0x04)   channel id (4)
; a7 ->  0 (0x00)   return address (4)
;
; After subtracting btf.frame (a struct QLRECT in fact) (= 8, 0x08) from a7
; and putting 4 registers.l (16 bytes, 0x10) on the stack, the stack pointer has
; decreased by 24 bytes.
;
;       32 (0x20)   subwindow definition (4)
;       28 (0x1c)   channel id (4)
;       24 (0x18)   return address (4)
;       20 (0x14)   d2 (?) (4)
;       16 (0x10)   d3 (?) (4)
;       12 (0x0c)   a2 (?) (4)
;        8 (0x08)   a3 (?) (4)
;        4 (0x04)   btf_org (4)     } struct QLRECT for
; a7 ->  0 (0x00)   btf_size (4)    } iop_outl and window decoration
;

        movem.l d2/d3/a2/a3,-(sp)
        subq.l  #btf.frame,sp

        move.l  stk_swdf(sp),a0             ; (sub-)window definition
        bsr     __btf_use                   ; use thing
        bne     btf_exit                    ; window origin in d2.l

        lea     btf_rect(sp),a1             ; struct QLRECT on stack
        move.l  stk_swdf(sp),a3             ; subwindow definition

        move.l  d2,btf_org(a1)              ;          origin in QLRECT
        move.l  sw_xsize(a3),btf_size(a1)   ;   original size in QLRECT
        move.l  d2,sw_xorg(a3)              ;          origin in window definition
                                            ; size is already in swdef

        move.w  sw_attr+wwa_borw(a3),d0     ; correct for borders
        add.w   d0,sw_xorg(a3)              ; subwindow starts inside border
        add.w   d0,sw_xorg(a3)              ; 2 times for x origin
        add.w   d0,sw_yorg(a3)              ; 1 time  for y origin

        add.w   d0,d0                       ; double for left/up and right/down brdr
        add.w   d0,btf_sizx(a1)             ; add border to xsize
        add.w   d0,btf_sizx(a1)             ; two times (x border = 2x)
        add.w   d0,btf_sizy(a1)             ; add border to ysize

        moveq   #0,d1
        moveq   #iopo.set,d2
        move.l  stk_chan(sp),a0
        moveq   #iop.outl,d0                ; set outline
        bsr     btf_trap3
        bne     btf_exit

        move.w  sw_attr+wwa_borw(a3),d2
        move.w  sw_attr+wwa_borc(a3),d1
        moveq   #iow.defw,d0             ; window and border
        bsr     btf_trap3
        bne     btf_exit

        move.w  sw_attr+wwa_papr(a3),d1 ; paper
        moveq   #iow.spap,d0
        bsr     btf_trap3
        bne     btf_exit

        move.w  sw_attr+wwa_papr(a3),d1 ; strip
        moveq   #iow.sstr,d0
        bsr     btf_trap3
        bne     btf_exit

        tst.b   sw_attr+wwa_clfg(a3)     ; clear window?
        blt     btf_exit                 ; ... no

        moveq   #iow.clra,d0
        bsr     btf_trap3

btf_exit:
        addq.l  #btf.frame,sp
btf_exf:
        movem.l (sp)+,d2/d3/a2/a3
        rts

btf_trap3:
        moveq   #-1,d3
        trap    #3
        tst.l   d0
        rts

;+++
; long bt_free()
;
; Free button frame.
; C68 call compatible.
;
; returns 0 OK, -ve QDOS error
;
;---
__bt_free:
        movem.l d2/d3/a2/a3,-(sp)
        bsr     btf_look
        bne     btff_exit

        lea     bt_name,a0
        moveq   #-1,d1
        moveq   #sms.fthg,d0             ; free button frame
        jsr     (a2)

btff_exit:
        movem.l (sp)+,d2/d3/a2/a3
        tst.l   d0
        rts

;+++
; _btf_use: internal service
;
; d1  r   border adjust
; d2  r   origin
; a0 c  s pointer to sub-window definition
;
; returns 0 OK, -ve QDOS error
;

    .globl  __btf_use

__btf_use:    
        movem.l d3/d7/a0/a2,-(sp)
        move.l  a0,-(sp)
        bsr     btf_look                 ; find thing
        move.l  (sp)+,a0
        tst.l   d0
        bne     btu_exit

        move.l  sw_xsize(a0),d2          ; size
        move.w  sw_attr+wwa_borw(a0),d1
        move.w  d1,d7
        add.w   d1,d7
        swap    d7
        move.w  d1,d7
        add.l   d7,d2
        add.l   d7,d2                    ; including border

        moveq   #0,d3                    ; new position
        lea     bt_name,a0
        moveq   #-1,d1
        moveq   #sms.uthg,d0             ; use button frame
        jsr     (a2)
        move.l  d7,d1                    ; border adjust
btu_exit:
        movem.l (sp)+,d3/d7/a0/a2
        tst.l   d0
        rts

btf_look:
        moveq   #sms.info,d0             ; get system variables
        trap    #1
        move.l  sys_thgl(a0),d1          ; this is the Thing list
        beq     btf_nf                   ; empty list, very bad!
        move.l  d1,a0
btf_lp:
        move.l  (a0),d1                  ; get next list entry
        beq     btf_found                ; end of list? Here should be THING!
        move.l  d1,a0                    ; next link
        bra     btf_lp
btf_found:
        move.l  th_thing(a0),a0          ; get start of Thing
        move.l  thh_type(a0),d1          ; is it our special THING?
        addq.l  #1,d1
        bne     btf_nf                   ; sorry, it isn't
        move.l  thh_entr(a0),a2          ; this is the vector we look for
        rts
btf_nf:
        moveq   #err.nimp,d0             ; no thing
        rts
