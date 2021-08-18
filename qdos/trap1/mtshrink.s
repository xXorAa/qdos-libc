;
;           m t _ s h r i n k
;
; routine to shrink a ql common heap item.
; needs messing about in supervisor mode. 
; equal to c routine
;   int mt_shrink( char *block, long newsize)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   10 Jul 93   DJW   - Removed setting of _oserr on failure - merely
;                       return QDOS error code.
;                     - Removed link/ulnk instructions by making parameter
;                       access relative to a7
;   05 Oct 93   DJW   - User mode was not restored on error exit
;                       (problem reported by David Gillam)
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even
    .globl __mt_shrink

SAVEREG equ 16                  ; size of saved registers

__mt_shrink:
    movem.l d2/d3/a2/a3,-(a7)
    trap    #0                  ; we are now in supervisor mode  (but A7 unchanged)
    move.l  8+SAVEREG(a7),d2    ; get newsize from stack
    add.l   #31,d2              ; + sizeof(qlheap) + 15
    and.b   #$f0,d2             ; loose lowest 4 bits ( & ~15 )

; newsize now rounded up to higher value of 16

    move.l  4+SAVEREG(a7),a2    ; a2 = start of block
    sub.l   #16,a2              ; a2 = start of blocks heap header

; a2 = start of shrinking blocks heap header

    move.l  (a2),d0             ; size of block
    sub.l   d2,d0               ; h1->qh_size - newsize
    cmp.l   #32,d0              ; (h1->qh_size - newsize < 32) ?
    bpl     bigenuf             ; positive - can continue
    moveq.l #-15,d0             ; err_bp
    and.w   #$dfff,sr           ; go back to user mode
    bra     fin                 ; -ve, newsize > oldsize - thus an error

bigenuf:
    move.l  a2,a3               ; start of blocks heap header
    add.l   d2,a3               ; + newsize

; a3 = start of new block we are creating in order to free, 
; thus shrinking old block.

; set the header of the new block up for a free

    move.l  (a2),d0             ; oldsize
    sub.l   d2,d0               ; oldsize - newsize
    move.l  d0,(a3)             ; set new smaller block size in new heap header
    move.l  4(a2),4(a3)         ; copy free address into new heap header
    move.l  8(a2),8(a3)         ; copy owner id into new heap header
    move.l  #0,$c(a3)           ; long word of zero in new heap header

; now alter the size in the old block

    move.l  d2,(a2)             ; old block size = newsize

    add.l   #16,a3              ; space to call free with in new block
    and.w   #$dfff,sr           ; go back to user mode

; now do a free on the block in a3 to link it back into the heap

    moveq.l #$19,d0
    move.l  a3,a0
    trap    #1
    moveq.l #0,d0               ; set reply as no error
fin:
    movem.l (a7)+,d2/d3/a2/a3
    rts

