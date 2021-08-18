;
;   i o _ o p e n / i o a _ o p e n
;
; routine to open a file. equivalent to c routine
;   long io_open( char *name, int mode)
;
; returns   qdos channel id or QDOS error code
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   10 Jul 93   DJW     Removed setting of _oserr.
;
;   24 Jul 93   DJW   - Added SMS entry point
;                     - Changed link/ulnk instructions to use a5
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes
;
;   29 Jul 96   DJW   - Added new entry point where name passed as a QL string
;                       rather than a C string.  This allows for awkward names
;                       that contain NULL characters (such as QUBIDE direct
;                       sector access);

    .text
    .even
    .globl __io_open      ; QDOS name for call
    .globl __ioa_open     ; SMS name for call

    .globl __io_open_qlstr

NAMESPACE equ 64                        ; Size of space to reserve for name

__io_open_qlstr:
    link    a5,#-0
    move.l  d3,-(a7)                    ; save corrupted reg
    move.l  4+4(a5),a0                  ; QL string (name)
    bra     shared

__io_open:
__ioa_open:
    link    a5,#-NAMESPACE              ; reserve space for file name
    move.l  d3,-(a7)                    ; save corrupted reg
    move.l  4+4(a5),-(a7)               ; C string (name)
    pea.l   -NAMESPACE(a5)              ; QL string
    jsr     __cstr_to_ql                ; convert to qlstr
    addq.l  #8,a7                       ; tidy up stack
    move.l  d0,a0                       ; qlstr
shared:
    move.l  8+4(a5),d3                  ; open type
    moveq.l #1,d0                       ; byte code
    moveq.l #-1,d1                      ; current job
    trap    #2                          ; do call
    tst.l   d0                          ; OK ? 
    bne     fin                         ; ... NO, exit with error code
    move.l  a0,d0                       ; ... YES, set channel id as reply
fin:
    move.l  (a7)+,d3                    ; restore saved registers
    unlk    a5                          ; remove work space
    rts

