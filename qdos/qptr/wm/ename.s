;
;   w m _ e n a m e  / w m _ r n a m e
;
; C68 Window Manager library routine to edit / read name in a window
;
; Equivalent to C routine:
;
;   int wm_ename (chanid_t chan, QL_TEXT *name)
;   int wm_rname (chanid_t chan, QL_TEXT *name)
;
; Returns:
;       0       OK
;       -ve     error code
;       +ve     terminating character if not <NL>
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       Tony Tebby
;
;   30 Oct 93   DJW   - Added underscore to entry point names
;                     - Added using internal routine to find WMAN vector
;
;   26 Nov 93   DJW   - Only the top two bytes of the wman vector were
;                       being used!   Found by Phil Borman.
;                     - Only two bytes of d0 were being set as a reply.
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

    .text
    .even

    .globl    __wm_ename
    .globl    __wm_rname

WM.RNAME equ    $68
WM.ENAME equ    $6c

__wm_ename:
        moveq   #WM.ENAME,d1
        bra     wme_comm

__wm_rname:
        moveq   #WM.RNAME,d1

SAVEREG equ 4+4
wme_comm:
        move.l  a2,-(sp)                ; save registers used
        movem.l 0+SAVEREG(sp),a0/a1     ; channel / name buffer
        jsr     __wm_fndv               ; get WMAN vector base
        bmi     wme_rts                 ; ... exit if failed
        move.l  d0,a2

        jsr     0(a2,d1.w)              ; call vector

        ble     wme_rts                 ; ... exit if failed
        moveq   #0,d0                   ; clear d0
        move.w  d1,d0                   ; terminating character as reply
wme_rts:
        move.l  (sp)+,a2
        rts

