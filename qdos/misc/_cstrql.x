;
;   c s t r _ t o _ q l
;
;   routine to convert a c (zero terminated) string to a
;   QDOS string (word length first). Equivalent to C call
;       qlstr *cstr_to_ql( struct QLSTR * qlstr, char *cstr)
;
;   AMENDMENT HISTORY
;   =================
;   15 Jun 93   DJW   - Amended to copy starting at end of C string, so that
;                       it is safe to do either an in-situ conversion,
;                       or a conversion between a QLSTR structure and
;                       a C string where the C string occupies the text
;                       part of the QLSTR structure.
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   03 Sep 94   DJW   - Added extra underscore to name as part of implementing
;                       name hiding within C68 libraries.

    .text
    .even
    .globl __cstr_to_ql

__cstr_to_ql:
    moveq   #0,d0           ; preset length of string as zero
    move.l  8(a7),a1        ; get the C string start address
countloop:
    tst.b   (a1)            ; end reached ?
    beq     countdone       ; .. YES, exit loop
    addq    #1,d0           ; increment count
    addq    #1,a1           ; increment address
    bra     countloop       ; ... and try again
countdone:
    move.w  d0,d1           ; copy count
    move.l  4(a7),a0        ; get the qlstr pointer (target address)
    addq.w  #2,a0           ; ... increment so it points to the data area
    add.w   d1,a0           ; ... and then to end of string
    bra     joinloop        ; join loop to move data accross
moveloop:
    move.b  -(a1),-(a0)     ; copy the string
joinloop:
    dbra    d1,moveloop     ; loop until finished

    move.w  d0,-(a0)        ; now store length of QDOS string
    move.l  a0,d0           ; set start address as exit reply
    rts 

