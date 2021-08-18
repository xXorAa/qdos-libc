;
;   f s _ m k d i r / i o f _ m k d r
;
; routine to turn a file on hard disk into a directory
;
; Equivalent to C routine:
;
;   int fs_mkdir( chanid_t chan )
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   11 Jul 93   DJW   - Remopved setting of _oserr.
;
;   24 Jul 93   DJW   - Added SMS entry point
;
;   18 Aug 93   DJW   - Changed QDOS entry poit to fs_mkdir
;
;   06 Nov 93   DJW   - Added underscore to entry point name
;                     - Allowed for fact that parameters of type 'short' are
;                       now passed as 2 bytes and not 4 bytes as previously.
;
;   20 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even

    .globl  __fs_mkdir        ; QDOS name for call
    .globl  __io_mkdir        ; oboslete QDOS name for call
    .globl  __iof_mkdr        ; SMS name for call

IOF.MKDR equ $4d

SAVEREG equ 12+4         ; size of saved registers + return address

__fs_mkdir:
__io_mkdir:
__iof_mkdr:
    movem.l d3/a2/a3,-(a7)            ; save corrupted reg
    moveq.l #IOF.MKDR,d0
    moveq.l #0,d1
    moveq.l #-1,d3
    move.l  0+SAVEREG(a7),a0    ; channel id
    trap    #3
    movem.l (a7)+,d3/a2/a3
    rts

