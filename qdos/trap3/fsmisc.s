;   
;   FILE:   f s m i s c
;
;   QDOS routines to do a variety of Flining System Operations
;
;       - Check for pending input       io_pend  / iob_test
;       - Output a byte                 io_sbyte / iob_sbyt
;       - Check opeartions complete     fs_check / iof_chek
;       - Flush buffers for file        fs_flush / iof_flsh
;       - Truncate a file               fs_trunc / iof_trnc
;       - Extended File Information     fs_xinf  / iof_xinf
;
;   All routines are equivalent to C routines of the form:
;
;       int sd_routine ( chanid_t chan, timeout_t timeout, ....)
;
; Version history:
; ~~~~~~~~~~~~~~~
;   11 Jul 93   DJW     Removed setting of _oserr.  Now merely returns the
;                       QDOS error code.
;
;   24 Jul 93   DJW   - Added SMS entry point
;
;   29 Jul 93   DJW   - Merged all entry points into this common source file
;
;   06 Nov 93   DJW   - Added underscore to entry points.
;                     - Allowed for fact that parameters of type 'short' are
;                       now passed as 2 bytes and not 4 bytes.
;
;   20 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes.
;
;   01 Sep 94   DJW   - Removed trailing underscore from __fs_trunc entry
;                       point.  Probelm reported by Eric Slagter.

    .text
    .even

;---------------------- File Operations --------------------

    .globl __io_pend          ; QDOS name for call
    .globl __iob_test         ; SMS name for call
__io_pend:
__iob_test:
    moveq   #0,d0
    bra     share

    .globl  __io_sbyte        ; QDOS name for call
    .globl  __iob_sbyt        ; SMS name for call
__io_sbyte:
__iob_sbyt:
    moveq   #5,d0
    move.b  7+4(a7),d1       ; Byte to send
    bra     share

    .globl __fs_check         ; QDOS name for call
    .globl __iof_test         ; SMS name for call
__fs_check:
__iof_chek:
    moveq   #$40,d0
    bra     share


    .globl __fs_flush         ; QDOS name for call
    .globl __iof_flsh         ; SMS name for call
__fs_flush:
__iof_flsh:
    moveq   #$41,d0
    bra     share


    .globl  __fs_trunc            ; QDOS name for call
    .globl  __io_trunc            ; obsolete QDOS name
    .globl  __iof_trnc            ; SMS name for call
__fs_trunc:
__io_trunc:
__iof_trnc:
    moveq   #$4b,d0
    bra     share

    .globl __fs_xinf          ; QDOS name for call
    .globl __io_fxinf         ; obsolete QDOS name for call
    .globl __iof_xinf         ; SMS name for call
__fs_xinf:
__io_fxinf:
__iof_xinf:
    moveq.l #$4f,d0
    moveq.l #0,d1
    move.l  6+4(a7),a1
    bra     share


;----------------------------------------------------------
;   Code common to all entry points

SAVEREG equ 12+4         ; size of saved registers + return address

share:
    movem.l d3/a2/a3,-(a7)      ; save possible register variables
    move.l  0+SAVEREG(a7),a0    ; channel id
    move.w  4+SAVEREG(a7),d3    ; timeout
    trap    #3                  ; do call
    movem.l (a7)+,d3/a2/a3      ; restore corrupted reg
    rts
