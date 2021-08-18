;           _ c h k s i m p l
;
;   This routine is used to determine if a name supplied
;   starts with a simple device name (e.g. CON) rather than
;   a directory device name (e.g. FLP1_).
;
;   REVISION HISTORY:
;   ~~~~~~~~~~~~~~~~
;   02.09.92    DJW     The "close" routine needed the Driver address to be
;                       stored in the channel block on SMS2 and ST/QL's with
;                       level E drivers.
;
;   24.10.92    DJW     Save extra registers in the close phase as these can
;                       be smashed by Minerva.
;
;   06 Nov 93   DJW     Added underscore to entry point names.
;
;   21 Jul 98   DJW     Changed to use get_sysvar() routine for system variables
;                       Changed to use _super() and _superend() routines.

    .text
    .even

    .globl __chksmpl

CHN_DRVR equ $04
CHN_END  equ $18
CHN_OPEN equ $08
CHN_CLOS equ $0c

SV_DRLST equ    $44         ; Offset in System Variables of Simple Device List
ERR_NF   equ    -7          ; "not found" error

SAVEREG  equ 12

__chksmpl:
    movem.l d3/a2/a6,-(a7)  ; save registers we are using
    jsr     _get_sysvar     ; get base of system variables
    move.l  d0,a6           ; save system variable base
    move.l  SAVEREG+4(a7),a1 ; get address of name to check
    bsr     __super         ; enter supervisor level (a1 NOT corrupted)
    moveq   #0,d3           ; ask for old exclusive device open
    move.l  SV_DRLST(a6),a2 ; set start of driver list

;   We will try the open with each driver in turn to
;   see if any of them recognise the name as valid.
;   Registers smashed by Open routine are D1-D7 and A1-A6

loop:
    movem.l d1-d7/a1-a6,-(a7); save all registers across open call
    move.l  a1,a0           ; put name into a0
    lea     -CHN_END(a2),a3  ; set to start of defn. block
    move.l  CHN_OPEN(a2),a4 ; get address of open routine
    jsr     (a4)            ; try open
    movem.l (a7)+,d1-d7/a1-a6 ; restore saved registers after open call
    tst.l   d0              ; did open work ? 
    beq     did_open        ; ... channel did open - must shut it now!
    cmp.w   #ERR_NF,d0      ; was error "not found"
    bne     quit            ; return if any other error
    move.l  (a2),a2         ; get next link
    move.l  a2,d0           ; check if next link is zero
    bgt     loop            ; while link is not zero
    moveq   #ERR_NF,d0      ; set up correct error for return
quit:
    jsr     __superend      ; exit level of supervisor mode (d0 NOT corrupted)
    movem.l (a7)+,d3/a2/a6  ; restore corrupted registers
    rts

;   what to do if channel was opened - close it quick !
;   Registers smashed by Close routine should be D0-D3 and A0-A3
;   However we save the others as some versions of Minerva smash them.

did_open:
    movem.l d1-d7/a1-a6,-(a7) ; save all registers that might be smashed
    lea.l   -CHN_END(a2),a3   ; set a3 to point at defn. block
    move.l  a3,CHN_DRVR(a0)   ; store driver address in channel block      (DJW)
    move.l  CHN_CLOS(a2),a4   ; set address for close call
    jsr     (a4)              ; close channel
    movem.l (a7)+,d1-d7/a1-a6 ; restore registers
    moveq   #0,d0             ; set for good reply
    bra     quit              ; ... and go to exit

