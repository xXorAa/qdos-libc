;
;   i o p _ r p x l
;
; Pointer Environment routine to read a pixel or line of pixels on the display.
;
; Equvalent to C routine:
;
;   int iop_rpxl( chanid_t chid, timeout_t timeout, short *x, short *y, 
;                              short scan,  short *colour);
;
; AMENDEMENT HISTORY
; ~~~~~~~~~~~~~~~~~~
;   First Version       J. Allison Pointer Interface Traps
;
;   30 Oct 93   DJW   - Removed setting of _oserr.
;                     - Removed need for link/ulnj instructions
;                     - Added underscore to entry point name
;                     - Changed to allow for the fact that parameters of type
;                       'short' mow passed as two bytes and not four.
;                     - Corrected fault whereby x and y were treated as being
;                       of type 'long' or 'int' even though the function
;                       definition said they were of type 'short'.
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines


    .text
    .even
    .globl __iop_rpxl

IOP_RPXL equ $72
SAVEREG  equ 16+4               ; size of saved registers + return address

__iop_rpxl:
    movem.l d2-d3/a2-a3,-(a7)
    moveq.l #IOP_RPXL,d0        ; Call code
    move.l  0+SAVEREG(a7),a0    ; Channel id
    move.w  4+SAVEREG(a7),d3    ; timeout
    move.l  6+SAVEREG(a7),a1    ; Address of x coord
    move.l  (a1),d1             ; Get x coord into high word
    move.l  10+SAVEREG(a7),a2   ; Address of y coord
    move.w  (a2),d1             ; Put y coord in low word
    move.l  14+SAVEREG(a7),d2   ; Get scan key (into high word)
    move.l  16+SAVEREG(a7),a3   ; Address of scan colour
    move.w  (a3),d2             ; Scan colour
    trap    #3
    move.w  d1,(a3)             ; New colour
    swap.w  d1                  ; Put new position in lower word of d1
    btst.l  #31,d2              ; Was there a scan ?
    beq     NOSCAN
    btst.l  #18,d2              ; If set it was a l-r scan, else u-d
    beq     UPDOWN
    move.w  d1,(a1)             ; New X coord.
    beq     NOSCAN
UPDOWN:
    move.w  d1,(a2)             ; New Y coord
NOSCAN:
    movem.l (a7),d2-d3/a2-a3
    rts

