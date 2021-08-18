;
;              _ i s f s c d b
;
;   To validate that this is a proper FS channel, the Device Driver
;   address is obtained from the Channel Definition Block, and the
;   list of Directory Device Drivers scanned to ensure that it is OK.
;
;  Returns:
;      Success      Address of Physical Definition Block
;      Failure      0
;
;  Equivalent to C function
;
;      int  _isfscdb (struct chan_defb * cdb);
;
; ASSUMPTIONS
; ~~~~~~~~~~~
;   1)  This code is executed in Supervisor mode.
;   2)  Return value is in D0
;   3)  D0, A0, and A1 can be safely smashed
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   28 Aug 93   DJW   - First version.
;                       Developed as the method previously used of simply
;                       checking the size of the channel definition block
;                       fails on the QXL.
;
;   06 Nov 93   DJW   - Added underscore to entry point name
;
;   25 Nov 93   DJW   - Amended to exit with pointer to base of Physical
;                       Definition Block as return value on success.

    .text
    .even
    .globl  __isfscdb

SV_DDLST  equ   $48         ; Offset in System Variables of Device Driver list
CH_DRIVR  equ   $04         ; Offset in Channel Definition to Driver
ERR_NF    equ   -7

SAVEREG   equ   0+4         ; size of saved registers + return address

__isfscdb:
    move.l  0+SAVEREG(sp),d0    ; get channel def block parameter
    bmi     seterror            ; quick sanity check
    move.l  d0,a0               ; get into address register
    move.l  CH_DRIVR(a0),a1     ; get Driver Address
    jsr     _get_sysvar         ; get base of system variables
    move.l  d0,a0
    move.l  SV_DDLST(a0),a0     ; List of Directory Device Drivers
check:
    cmpa.l  a0,a1               ; Match this driver ?
    beq     exit                ; ... YES take good exit
    tst.l   (a0)                ; another driver ?
    beq     seterror            ; ... NO, error exit
    move.l  (a0),a0             ; ... YES, get it
    bra     check               ; and try again

good_exit:
    move.l  a0,d0               ; Set device def. block as reply
    rts

seterror:
    moveq   #0,d0                       ; set error return
exit:
    rts


