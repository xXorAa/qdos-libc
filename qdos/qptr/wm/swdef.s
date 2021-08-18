;
;       w m _ s w d e f
;
; C68 library routine to do SWDEF / SWSEC
;
;   wm_swdef        Set given channel to application sub-window.
;   wm_swsec        Set given channel to application sub-window section
;
; Equivalent to C routines:
;
;   chanid_t wm_swdef (wwork *work, swdef *sw, chanid_t channel_ID)
;   chanid_t wm_swsec (wwork *work, swdef *sw, short x_sect, y_sect, long -ve | ink)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       Tony Tebby
;
;   31 Oct 93   DJW   - Added underscroer to entry point names
;                     - Allowed for fact that parameters of type 'short' are
;                       now passed in 2 bytes and not 4 bytes as previously
;                     - Added error check on knowing WMAN vector.
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

        .text
        .even

        .globl    __wm_swdef
        .globl    __wm_swsec

WM.SWDEF equ    $28
WM.SWSEC equ    $64

SAVEREG equ 16+4                ; size of saved registers + return address

__wm_swdef:
        movem.l d2/a1/a3/a4,-(sp)
        moveq   #WM.SWDEF,d0
        move.l  8+SAVEREG(sp),a0         ; set channel
        bra     wms_swcomm

__wm_swsec:
        movem.l d2/a1/a3/a4,-(sp)
        moveq   #WM.SWSEC,d0
        move.l  8+SAVEREG(sp),d1         ; section X and Y numbers
        move.l  12+SAVEREG(sp),d2        ; colours

wms_swcomm:
        move.l  0+SAVEREG(sp),a4         ; working def
        move.l  4+SAVEREG(sp),a3         ; sub-window
        move.l  d0,a1                    ; save required vector
        jsr     __wm_chkv                ; do we know WMAN vector base ?
        bmi     fin                      ; ... NO, exit immediately

        jsr     0(a1,d0.l)               ; ... YES, call required vector

        bne     fin
        move.l  a0,d0                    ; return channel ID
fin:
        movem.l (sp)+,d2/a1/a3/a4
        rts

