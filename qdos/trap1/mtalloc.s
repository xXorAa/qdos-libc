;
;   m t _ a l l o c / s m s _ a l h p
;
; Routine to allocate an area in a user heap.
; Equates to C call
;
;   char *mt_alloc( char **ptr, int *len)
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
;   10 Jul 93   DJW     Removed setting of _oserr on failure - now merely
;                       returns the QDOS error code
;   20 Jul 93   DJW   - Added SMS name as additional entry point
;                     - Removed link/ulnk instruction by making all
;                       parameter access relative to a7
;
;   06 Nov 93   DJW   - Added underscore to entry point names

    .text
    .even
    .globl __mt_alloc
    .globl __sms_alhp

SAVEREG equ 20+4                ; size of saved registers + return address

__mt_alloc:
__sms_alhp:
    movem.l d2-d3/a2-a3/a6,-(a7); stack register variables
    move.l  0+SAVEREG(a7),a0    ; set pointer
    sub.l   a6,a6               ; ... relative to a6
    move.l  4+SAVEREG(a7),a1    ; get address of length
    move.l  (a1),d1             ; length required
    moveq.l #$c,d0              ; call code
    trap    #1                  ; qdos call
    tst.l   d0                  ; did it work ?
    bne     fin                 ; ... exit with error code
    move.l  a0,d0               ; set area allocated as reply
    move.l  4+SAVEREG(a7),a1    ; address of length
    move.l  d1,(a1)             ; amount allocated
fin:
    movem.l (a7)+,d2-d3/a2-a3/a6 ; unstack register variables
    rts

