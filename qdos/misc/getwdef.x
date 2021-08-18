;
;     _ g e t w d e f
;
;   Routine to get the current details of the window
;   position and size for a specified channel.
;
;   Equivalent to C routine
;
;     int _getwdef(chanid_t chanid, struct WINDOWDEF *wdef);
;
;   AMENDMENT HISTORY
;   ~~~~~~~~~~~~~~~~~
;   ?           EAJ   - First version by Erling Jacobsen
;
;   01 Jun 94   DJW   - Tidied up source by using symbolic names, etc.
;                     - Removed link/unlk instructions to save space by
;                       taking parameters directly from the stack.
;                     - Returned full WINDOWDEF structure.
    .text
    .even
    .globl __getwdef

IOW.XTOP equ    $09

SD_XMIN  equ    $18
SD_YMIN  equ    $1a
SD_XSIZE equ    $1c
SD_YSIZE equ    $1e
SD_BORWD equ    $20
SD_PCOLR equ    $44
SD_ICOLR equ    $46
SD_BCOLR equ    $47

SAVEREG  equ    24+4

getwdef:
    move.b  SD_BCOLR(a0),(a1)+          ; border colour
    move.b  SD_BORWD+1(a0),(a1)+        ; border width (top byte)
    move.w  SD_PCOLR(a0),(a1)+          ; paper colour
    move.w  SD_ICOLR(a0),(a1)+          ; ink colour
    move.l  SD_XSIZE(a0),(a1)+          ; x and y sizes
    move.l  SD_XMIN(a0),(a1)            ; x and y position
    moveq   #0,d0
    rts

__getwdef:
    movem.l d2-d4/a2-a4,-(a7)

    moveq.l #IOW.XTOP,d0
    move.l  0+SAVEREG(a7),a0
    move.l  4+SAVEREG(a7),a1
    lea     getwdef(pc),a2
    moveq.l #-1,d3
    trap    #3

    movem.l (a7)+,d2-d4/a2-a4
    rts

