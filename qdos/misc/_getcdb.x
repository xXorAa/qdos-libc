;
;              _ g e t c d b
;
;  Get QDOS Channel definition block
;
;  Returns:
;      Success      address of block
;      Failure      -ve (QDOS error code).
;
;  Checks are made:
;      a)  Channel number is inside channel table
;      b)  Channel tag agrees with value passed
;
;  Equivalent to C function
;      struct fs_cdefb * _getcdb (chanid_t channel);
;
;  At assembler level parameter is a long word that is accessed as:
;      stack +4    WORD    channel tag
;      stack +6    WORD    channel number
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   10 Jul 93   DJW   - Removed setting of _oserr.  Now returns the
;                       QDOS error code (which is negative) on failure
;
;   06 Nov 93   DJW   - Added underscore to entry point name

CHTAG equ 4
CHNUM equ 6

ERR_NO equ -6

CHN_TAG   equ   $10

SV_CHBASE equ   $78
SV_CHTOP  equ   $7C

    .text
    .even
    .globl  __getcdb

__getcdb:
    jsr     _get_sysvar                 ; get base of system variables
    move.l  d0,a0
    move.l  SV_CHBASE(a0),a1            ; base of channel table
    move.l  SV_CHTOP(a0),d1             ; channel top
    sub.l   a1,d1                       ;... less base = size
    moveq   #0,d0                       ; clear d0
    move.w  CHNUM(a7),d0                ; get channel number in bottom word
    lsl.l   #2,d0                       ; convert to displacment
    cmp.l   d0,d1                       ; is channel in range ?
    bmi     seterror                    ; ... NO, error exit
    move.l  0(a1,d0),a0                 ; get address of channel definition block
    move.w  CHN_TAG(a0),d0              ; get channel tag
    cmp.w   CHTAG(a7),d0                ; channel tags agree ?
    bne     seterror                    ; ... NO, error exit
    move.l  a0,d0                       ; ... YES, set OK return value
fin:
    rts
seterror:
    moveq   #ERR_NO,d0                  ; set error return
    bra     fin                         ; ... and then exit

