;
;   _  w m _ f i n d v
;
;   C68 Window Manager library routines to find the
;   window manager.  If it has found it before, then it
;   remembers the answer to avoid having to repeat the
;   overheads of a trap call to find it.
;
;   wm_findv        Given channel ID, return address, or 0
;   _wm_fndv        Given Channel ID, return address, or error code
;   _wm_chkv        Check that vector known.  Return address or error code
;
;   Equivalent to C routines:
;
;       char *  wm_findv (chanid_t  channel)
;       char *  _wm_fndv (void)             *** A0 must contain channel ID ***
;       char *  _wm_chkv (void)
;
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       Tony Tebby
;
;   30 Oct 93   DJW   - Added underscore to entry point names.
;                     - Store value in internal vector on success.
;                       This is then used in preference if set up.
;                     - Added new entry points _wm_fndv() and _wm_getv() for
;                       internal use by library routines.
;                     - Ensured that no registers besides d0 are
;                       corrupted to facilitate internal use by library
;                       routines.
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

    .data
    .even

    .globl  __WM_vector

__WM_vector:
    .data4 0                    ; Vector for Winow Manager (or 0 if not known)

    .text
    .even

    .globl    __wm_findv
    .globl    __wm_fndv
    .globl    __wm_chkv

ERR_NOWMAN  equ -13
IOP_PINF equ $70

;   Try and find address given channel
;   exit with NULL if not found

__wm_findv:
    move.l  __WM_vector,d0      ; do we already know answer ?
    bne     findv_rts           ; ... YES, exit quickly
    move.l  4(sp),a0            ; ... NO, put channel ID in A0
    bsr     shared              ; ... and go to try harder !
    bpl     findv_rts           ; Error reply, exit immediately
findv_err:
    moveq   #0,d0               ; ... otherwise set NULL reply
findv_rts:
    rts

;   Try and find address given channel ID in A0
;   exit with error code if not found

__wm_fndv:
    move.l  __WM_vector,d0      ; See if we alreay know WMAN vector address
    bne     fndv_rts            ; ... YES, then use answer
    bsr     shared              ; ... NO, go try harder
fndv_rts:
    rts                         ; ... and use answer

;   Assumes Channel Id in A0
;   On failure, return error code in d0
;   On success return vector in a0, with condition codes OK
;   No registers other than D0 are corrupted.

shared:
    movem.l d1/d3/a1,-(sp)      ; save registers
    moveq   #IOP_PINF,d0        ; get pointer info
    moveq   #-1,d3              ; timeout

    trap    #3

    tst.l   d0                  ; PI Found ?
    bne     fin                 ; ... No, then error exit
    move.l  a1,__WM_vector      ; ... YES, store for use later
    move.l  a1,d0               ; ... and also set as reply
    bne     fin                 ; WM found ?
    bsr     no_wman             ; ... NO, set error reply
fin:
    movem.l (sp)+,d1/d3/a1      ; restore saved registers
    rts

;   Check address already known
;   Exit with error code if not

__wm_chkv:
    move.l  __WM_vector,d0
    beq     no_wman
chk_rts:
    rts

no_wman:
    moveq   #ERR_NOWMAN,d0
    rts

