;
;   q l s t r _ t o _ c
;
; Routine to convert a QL string to a C string.
; Written so that an in situ conversion will work
; successfully ( QL strings are shorter than C ones).
;
; Equivalent to C routine 
;       char *qlstr_to_c( char *cstr, struct QLSTR * qls)
;
; Return value:
;   Address of C string
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   15 Jun 93   DJW   - Tidied up code (reduced module size slightly)
;
;   06 Nov 93   DJW   - Added underscore to entry point names

    .text
    .even
    .globl  _qlstr_to_c

_qlstr_to_c:
    move.l  4(a7),a1    ; start address of C string
    move.l  a1,d0       ; ... and preset reply to address of C string
    move.l  8(a7),a0    ; start address of QL string
    move.w  (a0)+,d1    ; extract length of command line
    bra     joinloop    ; ... and join move loop
moveloop:
    move.b  (a0)+,(a1)+ ; move across a byte
joinloop:
    dbra    d1,moveloop ; keep going until finished

    clr.b   (a1)        ; terminate string properly
    rts                 ; exit (correct address already in D0

