;
;   f s _ p o s a b
;
;   f s _ p o s a b / i o f _ p o s a
;   f s _ p o s r e / i o f _ p o s r
;
; QDOS routines to do the absolute/relative file seek
; equivalent to C routines
;
;   int fs_posab(chanid_t chan, timeout_t, timeout, long *pos)
;   int fs_posre(chanid_t chan, timeout_t, timeout, long *pos)
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
;   23 Feb 96   DJW   - Split off fs_posab/fs_posre into own source file.
;                     - Added check for position parameter being 0 which
;                       means user forgot indirection!  Safety check really.


    .text
    .even

    .globl __fs_posab             ; QDOS name for call
    .globl __iof_posa             ; SMS name for call

    .globl __fs_posre             ; QDOS name for call
    .globl __iof_posr             ; SMS name for call


SAVEREG equ 12+4         ; size of saved registers + return address

__fs_posab:
__iof_posa:
    moveq   #$42,d0         ; Trap code required
    bra     fspos

__fs_posre:
__iof_posr:
    moveq   #$43,d0         ; Trap code required

fspos:
;   d0 already contains required trap code
    movem.l d3/a2/a3,-(a7)       ; save registers used
    move.l  0+SAVEREG(a7),a0     ; channel id
    move.l  6+SAVEREG(a7),a2     ; pointer to position/offset
    move.l  a2,d3                ; see if 0
    beq     L2                   ; .. if so means user forgot indirection
    move.l  (a2),d1              ; position
L2:
    move.w  4+SAVEREG(a7),d3     ; timeout
    trap    #3                   ; N.B.  a2 is preserved

    move.l  a2,d3                ; see if 0
    beq     L3                   ; 0 means user forgot indirection
    move.l  d1,(a2)              ; new position
L3:
    movem.l (a7)+,d3/a2/a3       ; restore registers used
    rts

