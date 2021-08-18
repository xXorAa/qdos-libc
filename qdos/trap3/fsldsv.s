;
;   FILE: f s l d s v
;
;   f s _ l o a d / i o f _ l o a d
;   f s _ s a v e / i o f _ s a v e
;
; QDOS routines to load/save a file to from a channel.
;
; equivalent to the C routines :-
;
;   int fs_load( chanid_t chanid, char *buf, long len)
;   int fs_save( chanid_t chanid, char ;buf, long len)
;
; returns:
;       success     length written
;       failure     QDOS error code (which is negative)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   11 jul 93   DJW   - Removed setting of _oserr - now merely returns the
;                       QDOS error code (which is negative).
;                     - Removed link/ulnk instructions by making parameter
;                       access relative to a7.
;
;   24 Jul 93   DJW   - Added timeout parameter
;                       Added SMS entry point
;                       Merge fs_load() and fs_save() into this single file.
;
;   06 Nov 93   DJW   - Added underscore to entry point name
;
;   20 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even

    .globl __fs_load          ; QDOS name for call
    .globl __iof_load         ; SMS name for call

    .globl __fs_save          ; QDOS name for call
    .globl __iof_save         ; SMS name for call


__fs_load:
__iof_load:
    moveq   #$48,d0           ; byte code
    bra     fsldsv

__fs_save:
__iof_save:
    moveq   #$49,d0           ; byte code

SAVEREG equ 16+4            ; size of saved registers + return address

fsldsv:
    movem.l  d2/d3/a2/a3,-(a7)  ; save regs
    move.l   0+SAVEREG(a7),a0   ; channel id
    move.l   4+SAVEREG(a7),a1   ; buffer start
    move.l   a1,a2              ; save buffer start
    move.l   8+SAVEREG(a7),d2   ; length to read
    moveq    #-1,d3             ; timeout
    trap     #3                 ; ... do it
    tst.l    d0                 ; OK ?
    bne      fin                ; ... NO, exit with error code
    sub.l    a2,a1              ; calculate (newpos - oldpos)
    move.l   a1,d0              ; set reply as length saved
fin:
    movem.l  (a7)+,d2/d3/a2/a3
    rts

