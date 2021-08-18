;
;           u t _ l i n k
;
;   Routine to call QDOS vector to link an item into a linked list
;
;   Equvalent to C routine
;
;       void  ut_link (char *previtem, char * newitem)
;
;   AMENDMENT HISTORY
;   ~~~~~~~~~~~~~~~~~
;   06 Nov 93   DJW   - Added underscore to entry point name
;                     - Added SMS entry point name
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even
    .globl __ut_link
    .globl __mem_list

SAVEREG equ 4+4         ; size of saved registes + return address

__ut_link:
__mem_list:
    move.l  a2,-(a7)            ; save register variable
    move.l  0+SAVEREG(a7),a1    ; previous item
    move.l  4+SAVEREG(a7),a0    ; new item
    move.w  $d2,a2              ; vector required
    jsr     (a2)                ; ... and use it
    move.l  (a7)+,a2            ; restore register variable
    rts

