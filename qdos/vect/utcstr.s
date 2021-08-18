;
;   u t _ c s t r
;
;   Does the UT.CSTR QDOS-vector for C, to compare two QDOS strings.
;
;   Assumptions:
;       - Function return value passed in d0
;       - Compiler must _NOT_ assume that a0, a1, d1 are preserved
;         in function calls!
;
;   Equivalent to C routine:
;       int     ut_cstr(string1, string2, mode)
;       struct QLSTR * string1;         /* pointer to a QL string */
;       struct QLSTR * string2;         /* pointer to a QL string */
;       int     mode;                   /* type of comparison to use */
;
;   Return value:
;       0       Strings are the same
;       -1      'string1' is less than 'string2'
;       +1      'string1' is greater than 'string2'
;
;   WARNING: 
;       The comparison uses the QDOS defined collating sequence, which is
;       NOT the same as the ASCII collating sequence
;
;   AMENDMENT HISTORY
;   ~~~~~~~~~~~~~~~~~
;   20 Jun 93   DJW     First version produced (c) D.J.Walker
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even
    .globl __ut_cstr

__ut_cstr:
    move.l  4(a7),a0        ; get first argument, i.e. string1 address
    move.l  8(a7),a1        ; get second argument, i.e. string2 address
    move.l  12(a7),d0       ; comparison type
    movem.l a2/a6, -(sp)    ; save registers
    sub.l   a6,a6           ; addresses need to be a6 relative
    move.w  $e6,a2          ; UT_CSTR vector
    jsr    (a2)             ; do conversion
    movem.l (a7)+,a2/a6     ; restore saved registers
    rts                     ; that's all folks ... answer is in d0

