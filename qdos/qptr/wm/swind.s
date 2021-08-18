;
;       w m _ s w i n d
;
; C68 library routine to do WM_SWINF / SWLIT / SWAPP 
;
;   wm_swapp        Set window to application window.
;   wm_swinf        Set window to information window.
;   wm_swlit        Set window to loose menu item.
;
; Equivalent to C routines:
;
;   chanid_t wm_swapp (wwork *work, short wind_nr, long -ve | ink)
;   chanid_t wm_swinf (wwork *work, short wind_nr, long -ve | ink)
;   chanid_t wm_swlit (wwork *work, short item, long -ve | status (128|0|16)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       Tony Tebby
;
;   31 Oct 93   DJW   - Added underscroer to entry point names
;                     - Allowed for fact that parameters of type 'short' are
;                       now passed in 2 bytes and not 4 bytes as previously.
;                     - Added a check that we know the WMAN vector
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

        .text
        .even

        .globl    __wm_swinf
        .globl    __wm_swlit
        .globl    __wm_swapp

WM.SWINF equ    $58
WM.SWLIT equ    $5c
WM.SWAPP equ    $60

__wm_swinf:
        moveq   #WM.SWINF,d0
        bra     wms_comm

__wm_swlit:
        moveq   #WM.SWLIT,d0
        bra     wms_comm

__wm_swapp:
        moveq   #WM.SWAPP,d0

SAVEREG equ 8+4                     ; size of saved registers +return address

wms_comm:
        movem.l d2/a4,-(sp)
        move.l  0+SAVEREG(sp),a4         ; working def
        move.w  4+SAVEREG(sp),d1         ; item
        move.l  6+SAVEREG(sp),d2         ; colours
        move.w  d0,a0
        jsr     __wm_chkv               ; check we know WMAN vector base
        bmi     wms_rts                 ; ... NO, exit

        jsr     0(a0,d0.l)              ; ... YES, call vector required

        bne     wms_rts
        move.l  a0,d0                    ; return channel ID
wms_rts:
        movem.l (sp)+,d2/a4
        rts

