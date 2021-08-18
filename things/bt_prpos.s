;
;       b t _ p r p o s
;
; C68 library routine to put position primary in button frame
;
; Position primary in button frame. Allocates a hole in the button frame and
; calls wm_prpos to position it. If successful, it clears wwork.flag so that
; there is no shadow!
;
; Equivalent to C routine:
;
;   int bt_prpos (wwork *sub_window)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       Tony Tebby
;
;   31 Oct 93   DJW   - Added underscore to entry point name
;                     - Added check on WMAN vector being known
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

        .text
        .even

        .globl    __bt_prpos

WM.PRPOS equ    $0c

WW_XSIZE equ    $20
WW_XORG  equ    $24
WW_WATTR equ    $28

SAVEREG equ 8+4                 ; size of saved registers + return address

__bt_prpos:
        movem.l d2/a4,-(sp)
        move.l  0+SAVEREG(sp),a4
        lea     WW_XSIZE(a4),a0          ; window definition

        jsr     __btf_use                ; use thing
        bne     btp_exit

        clr.w   WW_WATTR(a4)             ; clear flags / shadow

        add.l   d2,d1                    ; position of inside window
        add.l   WW_XORG(a4),d1           ; position of origin

        jsr     __wm_chkv
        bmi     btp_exit
        move.l  d0,a0
        jsr     WM.PRPOS(a0)             ; position

btp_exit:
        movem.l (sp)+,d2/a4
        rts

