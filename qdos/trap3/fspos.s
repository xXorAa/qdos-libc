;
;   f s _ p o s
;
; QDOS routines that is equivalent to Unix lseeek().
; Equivalent to C routine:
;
;   long fs_pos( long chan, long pos, int mode)
;
;       where mode can be any of:
;           0       position absolute
;           1       position relative to current position
;           2       position relative to EOF
;
;
; AMENDMENT HISTORY
; =================
;   10 JUN 93   DJW   - Tidied up the code slightly.  Resulte was to reduce
;                       the module size slightly.
;                     - Added small optimisation to mode 2 position to avoid
;                       doing the fs_posre call if offset is zero.
;
;   26 JUL 93   DJW   - Added the fs_posab and fs_posre entry points
;
;   06 Nov 93   DJW   - Added underscore to entry point name
;                     - Allowed for fact that parameters of type 'short' are
;                       now passed as 2 bytes and not 4 bytes as previously.
;
;   20 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes
;
;   10 Nov 94   DJW   - Changed constant for moving to EOF to $3FFFFFF (was
;                       $7FFFFFF).  Apparently this is all QDOS can handle.
;                       (reported by PROGS).
;
;   23 Feb 96   DJW   - Split fs_posab/fs_posre into their own source file.

    .text
    .even

    .globl __fs_pos
    .globl __iof_pos

err_bp .equ -15
err_ef .equ -10

SAVEREG equ 12+4         ; size of saved registers + return address

__fs_pos:
__iof_pos:
    movem.l d3/a2/a3,-(a7)       ; save registers used
    moveq.l #-1,d3              ; timeout
    move.l  0+SAVEREG(a7),a0    ; channel id
    moveq.l #$42,d0             ; preset for FS_POSAB
    move.l  8+SAVEREG(a7),d1    ; mode required
    beq     cont                ; mode = 0, absolute pos
    subq.w  #1,d1
    beq     relative            ; mode = 1, relative to current pos
    subq.w  #1,d1
    beq     relative_eof        ; mode = 2, relative to eof pos
    move.l  #err_bp,d0          ; err_bp
    bra     err                 ; exit with error code

;
;   If relative to EOF, then we must first do
;   an absoulte position to EOF, followed by
;   the required relative position
;
relative_eof:
    move.l  #$3ffffff,d1        ; large value to get to EOF position
    trap    #3
    cmp.l   #err_ef,d0          ; should be err_ef
    bne     err                 ; exit with reply as error code
    tst.l   4+SAVEREG(a7)       ; relative position zero ?
    beq     fin                 ; ... in which case we can exit immediately

;   Now fall through to do the relative part

relative:
    moveq.l #$43,d0             ; fs_posre code
cont:
    move.l  4+SAVEREG(a7),d1    ; position requested
    trap    #3
fin:
    move.l  d1,d0               ; set reply to position
err:
    movem.l (a7)+,d3/a2/a3       ; restore registers used
    rts

