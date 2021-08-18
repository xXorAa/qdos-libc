;
;       q d o s 2
;
;   Routine to call QDOS trap #2.  Allows user to specify all registers
;   and get back returned register values.
;
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   06 Nov 93   DJW   - Added underscore to entry point names
;                     - Removed need for link/ulnk instructions by making
;                       all parameter access relative to a7

    .text
    .even
    .globl _qdos2

; routine to replace standard qdos calls.

SAVEREG equ 40+4            ; size of saved registers + return address

_qdos2:
    movem.l d2-d7/a2-a5,-(a7)               ; save registers
    move.l  0+SAVEREG(a7),a5                ; get pointer to input values
    movem.l (a5),d0/d1/d2/d3/a0/a1/a2/a3    ; put them in registers
    trap    #2                              ; ... do call
    move.l  4+SAVEREG(a7),a5                ; get pointer to output values
    movem.l d0/d1/d2/d3/a0/a1/a2/a3,(a5)    ; save returned registers
    movem.l (a7)+,d2-d7/a2-a5               ; restore saved registers
    rts


