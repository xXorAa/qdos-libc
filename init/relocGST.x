;
;       r e l o c G S T
;
;   Do program relocation using GST format relocation table
;
;   On entry:
;       a1  Address of relocation table
;       d1  Base address of code to be relocated
;
;   The GST linker format relocation table is as follows
; 
;       long        Count of number of addresses needing relocation
;       long...     Displacement of address needing relocation relative
;                   to program start.
;
;   AMENDMENT HISTORY
;   ~~~~~~~~~~~~~~~~~
;   $Log$
;---------------------------------------------------------------------------

    move.l  (a1)+,d0        ; Get no. of relocation items
    bra     RELOOP
DOREL:
    move.l  (a1)+,a0        ; Get address of item to relocate
    add.l   d1,0(a0,d1.l)   ; Add base of program to it
RELOOP:
    dbra    d0,DOREL        ; loop until finished

END_RELOCATE:

