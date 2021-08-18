;
;       r e l o c L D
;
;   Do program relocation using LD format relocation table
;
;   On entry:
;       a1  Address of relocation table
;       d1  Base address of code to be relocated
;
;   The LD linker format relocation table is as follows
;
;       long        first address needing relocation relative to
;                   programs start
;       byte...     Next address needing relocation relative to last
;                   address relocated.  Special values are:
;                       0 = end of relocation data
;                       1 = Add 254 to relocation address WITHOUT
;                           doing relocation at this address.
;
;   AMENDMENT HISTORY
;   ~~~~~~~~~~~~~~~~~
;   $Log$
;---------------------------------------------------------------------------

    tst.l   (a1)            ; is there any relocation ?
    beq     END_RELOCATE    ; ... NO !! relocation info
    move.l  (a1)+,a0        ; Get first long word of relocation info
    moveq   #0,d0           ; clear d0
LOOP_REL:
    add.l   d1,0(a0,d1.l)   ; relocate one address
LOOP_IT:
    move.b  (a1)+,d0        ; Get next relocation byte
    add.w   d0,a0           ; Add amount to relocation location
    cmpi.w  #1,d0           ; Check value aainst 1 ?
    bhi     LOOP_REL        ; GREATER ... just fix up word at this location
    bmi     END_RELOCATE    ; LESS, ... must be 0 (and thus we are finished)
    add.w   #253,a0         ; EQUAL, ... add another 253 to get 254
    bra     LOOP_IT         ; Get next byte

END_RELOCATE:

