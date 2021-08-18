;
;   c n _ d a t e / c v _ i l d a t 
;   c n _ d a y   / c v _ i l d a y
;
;   Does the QDOS-vector for C, to convert a QDOS-format date 
;   (local time in seconds from 1961 Jan 01 00:00:00)
;   into:
;       - date and time                 cn_date / cv_ildat
;       - day of the week               cn_day  / cv_ilday
;
;   Value returned us a '\0'-terminated character vector (C-string).
;
;   Assumptions:
;       - Function return value passed in d0
;       - Compiler must _NOT_ assume that a0, a1, d1 are preserved
;         in function calls!
;
;   Equivalent to C routine:
;       char *cn_date (char * buffer, long qdos_date)
;       char *cn_day  (char * buffer, long_qdos_date)
;
;       buffer must have at least 25 characters for cn_date, 
;                    and at least 7  characters for cn_day
;
;   cn_day returns a pointer to '\0'-terminated char vector.
;   WARNING: the result of the function is __N_O_T__ the start of the buffer!!
;         The result is buffer+2, the first word (Motorola format, 2 bytes)
;         holds the length of the string
;
;   AMENDMENT HISTORY
;   ~~~~~~~~~~~~~~~~
;               PH    - Original version by Peter Holzer
;
;   11 Mar 93   DJW   - Added cn_day entry point, and slightly reworked
;
;   29 Jul 93   DJW   - Added the SMS entry points
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes
;
;   24 Mar 96   DJW   - Reworked to allow for the fact that QDOS assumes
;                       that the buffer starts on an even address even though
;                       this is not documented in the Technical Guide.
;                       (Problem reported by Phil Borman).

    .text
    .even

    .globl  __cn_date     ; QDOS name for call
    .globl  __cv_ildat    ; SMS name for call
__cn_date:
__cv_ildat:
    move.w  $ec,a0          ; vector CN.DATE
    link    a5,#-24         ; Reserve space for conversion buffer
    lea     22(a7),a1       ; set pointer to end of buffer
    bra     share

    .globl  __cn_day      ; QDOS name for call
    .globl  __cv_day      ; SMS name for call
__cn_day:
__cv_day:
    move.w  $ee,a0          ; vector CN.DAY
    link    a5,#-8          ; reserve space for conversion buffer
    lea     6(a7),a1        ; set pointer to end of buffer

SAVEREG equ 8+4         ; size of saved registers + return address

share:
    movem.l a2/a6,-(sp)         ; Save registers corrupted
    move.l  8+4(a5),d1          ; get second argument (qdat)
    suba.l  a6,a6               ; this makes a1 to an absolute pointer
    jsr     (a0)                ; do conversion

    move.w  (a1),d1             ; get length returned
    move.l  8+0(a5),a2          ; get first argument, i.e. pointer to buffer (ascdat)
    move.w  (a1)+,(a2)+         ; move across length word
    move.l  a2,d0               ; set pointer to text part as result
loop:   
    move.b  (a1)+,(a2)+         ; move a byte across
    dbra    d1,loop             ; go for more until count finished 
    clr.b   -(a2)               ; ... and add NULL byte

    movem.l (a7)+,a2/a6         ; restore saved registers
    unlk    a5                  ; remove conversion buffer
    rts

