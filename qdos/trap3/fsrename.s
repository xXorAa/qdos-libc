;
;   f s _ r e n a m e / i o f _ r n a m
;
; QDOS routine to rename a file
; Equivalent to c routine
;       int io_rename( char *old, char *new )
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   10 Jul 93   DJW   - Removed assumption that io_open() or io_close()
;                       sets _oserr.
;                     - Removed setting of _oserr.
;
;   24 Jul 93   DJW   - Added SMS entry point
;                     - Changed link/ulnk isntructions to use a5
;
;   18 Aug 93   DJW   - Changed QDOS entry point to fs_rename()
;
;   06 Nov 93   DJW   - Added underscore to entry point name
;
;   15 Nov 93   DJW   - Error codes were not being preserved if one of the
;                       earlier calls failed.  This could result in a spurious
;                       success report (reported by Eric Slagter)
;
;   20 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes
;
;   03 Sep 94   DJW   - Added underscore to _cstr_to_ql for name hiding reasons

    .text
    .even

    .globl  __fs_rename       ; QDOS name for call
    .globl  __io_rename       ; oboslete QDOS name for call
    .globl  __iof_rnam        ; SMS name for call

OLD_EXCL equ    0

IOA.CLOS equ    $02
IOF.RNAM equ    $4a

WORKLEN  equ    96
SAVEREG  equ    16+4

__fs_rename:
__io_rename:
__iof_rnam:
    link    a5,#-WORKLEN
    movem.l d2/d3/a2/a3,-(a7)  ; save regs
    pea.l   OLD_EXCL        ; old exclusive mode
    move.l  4+4(a5),-(a7)   ; old name
    jsr     __io_open       ; go and try to open
    addq.l  #8,a7           ; ... tidy stack
    move.l  d0,-(a7)        ; push channel id/error code
    bmi     fin             ; ... exit immediately if error occurred in open

    move.l  8+4(a5),-(a7)   ; new name
    pea.l   -WORKLEN(a5)    ; qlstr
    jsr     __cstr_to_ql
    addq.l  #8,a7
    move.l  d0,a1           ; qlstr

    moveq.l #IOF.RNAM,d0    ; action required
    moveq.l #-1,d3          ; timeout
    move.l  (a7)+,a0        ; pop channel id
    trap    #3
    move.l  d0,-(a7)        ; push reply code

    moveq   #IOA.CLOS,d0    ; Action required (channel ID still in a0)
    trap    #2              ; ... do it
fin:
    move.l  (a7)+,d0        ; pop reply code
    movem.l (a7)+,d2/d3/a2/a3  ; retore register variables
    unlk    a5              ; remove workspace
    rts

