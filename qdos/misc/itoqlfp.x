;
;   i _ t o _ q l f p
;
; routine to quickly convert a 32 bit signed integer into a qlfloat
; corresponds to the c routine :-
;       qlfloat *i_to_qlfp( qlfloat *qlf, int i)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;
;   06 Nov 93   DJW   - Added underscore to entry point names

    .text
    .even
    .globl _i_to_qlfp

_i_to_qlfp:
    jmp     _l_to_qlfp           ; OK as long as int == long

