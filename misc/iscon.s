#
;               i s c o n
;
; routine to check if a channel is a screen channel. Does this by
; requesting window size and position. This has the side effect of
; activating any pending newlines.
;
; Equivalent to c routine:
;
;   int iscon( chanid_t chanid, timeout_t timeout)
;
; ------------------------------------------------------------------
;  N.B. This may not be the best way to do this!   It has been
;       found that certain disk interfaces (such as the Sandy one)
;       incorrectly respond to this with no error!
;-------------------------------------------------------------------
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   07 Nov 93   DJW   - Added underscore to entry point


    .text
    .even
    .globl _iscon

CHANID  equ 8
ERR_NC  equ -1

IOW.PIXQ equ $0a

QLRECT  equ 8           ; Size of a QLRECT (4 x short)

_iscon:
    link    a6,#-QLRECT     ; size of a struct qlrect
    move.l  d3,-(a7)
    lea.l   -QLRECT(a6),a1  ; address of buffer
    moveq   #0,d3           ; timeout
    move.l  CHANID(a6),a0   ; chanid
    moveq   #IOW.PIXQ,d0    ; Pixel size enquiry
    trap    #3              ; try the size read
    tst.l   d0              ; worked ?
    bne     err             ; No
ok:
    moveq   #1,d0           ; true - is a console (CON or SCR) channel
fin:
    move.l  (a7)+,d3
    unlk    a6
    rts
err:
    cmp.l   #ERR_NC,d0      ; not complete error ?
    beq     ok              ; ... still OK
    moveq   #0,d0           ; false - is not a console channel
    bra     fin

