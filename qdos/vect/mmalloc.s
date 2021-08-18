;
;   m m _ a l l o c / m e m _ a l h p
;
; Routine to allocate an area in a user heap.
; Equates to C call
;
;   char *mm_alloc( char **ptr, int *len)
;
; where **ptr is pointer to pointer to free space.
;
; returns:
;       success     address of area allocated
;                   (len contains amount actually allocated)
;       failure     (negative) QDOS error code
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   24 Jul 93   DJW   - First version (based on mt_alloc() code).
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even

    .globl __mm_alloc             ; QDOS name for call
    .globl __mem_alhp             ; SMS name for call

SAVEREG equ 20                  ; size of saved registers

__mm_alloc:
__mem_alhp:
    movem.l d2-d3/a2-a3/a6,-(a7); stack register variables
    move.l  4+SAVEREG(a7),a0    ; set pointer
    sub.l   a6,a6               ; ... relative to a6
    move.l  8+SAVEREG(a7),a1    ; get address of length
    move.l  (a1),d1             ; length required
    move.w  $d8,a2              ; vector required
    jsr     (a2)                ; do it
    tst.l   d0                  ; did it work ?
    bne     fin                 ; ... exit with error code
    move.l  a0,d0               ; set area allocated as reply
    move.l  8+SAVEREG(a7),a1    ; address of length
    move.l  d1,(a1)             ; amount allocated
fin:
    movem.l (a7)+,d2-d3/a2-a3/a6 ; unstack register variables
    rts
      
