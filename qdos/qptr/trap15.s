;
;       t r a p 1 5
;
; C68 library routine to do TRAP15
;
; Equivalent to C Routine:
;
;   int trap15 (any long word parameters)
;
; Transfers the first eight long word params to D0-D7 and executes TRAP #15.
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       Tony Tebby
;
;   31 Oct 93   DJW   - Added underscore to entry point name
;
;   10 Jun 94   DJW   - Extra underscore added for name hiding purposes.

        .text
        .even

        .globl    __Trap15

__Trap15:
        movem.l d1-d7,-(sp)
        movem.l $20(sp),d0-d7
        trap    #15
        movem.l (sp)+,d1-d7
        rts

