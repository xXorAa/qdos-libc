;
;   FILE: u t o p e n
;
;   u t _ c o n
;   u t _ s c r
;
; QDOS vectors for cimplified opening of screen and console channels
;
; Equivalent to C routines
;
;       chanid_t ut_con( char * paramblock)
;       chanid_t ut_scr( char * paramblock)
;
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   01 Feb 93   DJW   - Register storing vector changed to a0 (was a2).
;                       Fix provided by Dirk Steinkopf.
;   10 Jul 93   DJW   - Removed setting of _oserr - merely returns
;                       QDOS error code on failure
;                     - Removed link/ulnk instructions by making paramater
;                       access relative to a7
;   27 Jul 93   DJW   - Merged ut_con() and ut_src() into single source file
;
;   06 Nov 93   DJW   - Added underscore to entry point name
;                     - Added SMS entry point name
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even

    .globl  __ut_con
    .globl  __opw_con
__ut_con:
__opw_con:
    move.w  $c6,a0
    bra     ut_open

    .globl  __ut_scr
    .globl  __opw_scr
__ut_scr:
__opw_scr:
    move.w  #$c8,a0             ; vector number


;   Shared code

SAVEREG equ 12+4            ; size of saved registers + return address

ut_open:
    movem.l d3/a2-a3,-(a7)      ; save register variables
    move.l  0+SAVEREG(a7),a1    ; parameter block
    jsr     (a0)                ; call it
    tst.l   d0                  ; OK ?
    bne     fin                 ; ... and jump if error
    move.l  a0,d0               ; move channel as return value
fin:
    movem.l (a7)+,d3/a2-a3      ; restore register variables
    rts

