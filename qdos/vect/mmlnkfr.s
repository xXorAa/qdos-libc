;
;   m m _ l n k f r  / m e m _ r e h p
;
; assembly routine to link an area (back) into a user heap
; equates to c call
;
;   void mm_lnkfr( char *base, char **ptr, int len)
;
; where
;   base is space to linked
;   **ptr is pointer to pointer to free space
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   24 Jul 93   DJW   - First version (based on mt_lnkfr() code)
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even

    .globl __mm_lnkfr         ; QDOS name for call
    .globl __mem_rehp         ; SMS name for call

SAVEREG equ 20                      ; size of saved registers

__mm_lnkfr:
__mem_rehp:
    movem.l d2-d3/a2-a3/a6,-(a7)    ; stack register variables
    sub.l   a6,a6                   ; relative to a6 (zero)
    move.l  4+SAVEREG(a7),a0        ; set base
    move.l  8+SAVEREG(a7),a1        ; pointer
    move.l  12+SAVEREG(a7),d1       ; length to free
    move.w  $da,a2                  ; vector to call
    jsr     (a2)                    ; do it
    movem.l (a7)+,d2-d3/a2-a3/a6    ; unstack register variables
    rts

