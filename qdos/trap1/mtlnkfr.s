;
;   m t _ l n k f r  / s m s _ r e h p
;
; assembly routine to link an area (back) into a user heap
; equates to c call
;
;   void mt_lnkfr( char *base, char **ptr, long len)
;
; where
;   base is space to linked
;   **ptr is pointer to pointer to free space
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   20 Jul 93   DJW   - Added SMS name as additional entry point
;                     - Removed link/ulnk instruction by making all
;                       parameter access relative to a7
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even
    .globl __mt_lnkfr
    .globl __sms_rehp

SAVEREG equ 20+4                    ; size of saved registers + return address

__mt_lnkfr:                          ; QDOS name
__sms_rehp:                          ; SMS name
    movem.l d2-d3/a2-a3/a6,-(a7)    ; stack register variables
    sub.l   a6,a6                   ; relative to a6 (zero)
    move.l  0+SAVEREG(a7),a0        ; set base
    move.l  4+SAVEREG(a7),a1        ; pointer
    move.l  8+SAVEREG(a7),d1        ; length to free
    moveq.l #$d,d0                  ; call code
    trap    #1                      ; qdos call
    movem.l (a7)+,d2-d3/a2-a3/a6    ; unstack register variables
    rts

