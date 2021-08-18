#
;
;       c _ e x t o p
;
; routine to do screen extended operation where called
; routine is written in C (rather than assembler).
; c.f.  sd_extop() for assembler routines
;
; Equivalent to C routine:
;
;   long c_extop(chid_t chid, long timeout, void (*rout)(), int no_of_params,)
;
; these parameters should be followed by no_of_params which are passed on
; to the specified C routine.
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
; 13/08/93  JVA   - First Version written by Joachim Van der Auwera
;                   for PROGS, PROfessional & Graphical Software
;                   (c) 31 August 1993
;
; 08/09/93  DJW   - Added to C68 LIBC_A library, but name changed to
;                   c_extop() (so that original sd_extop() routine can be
;                   used.
;                 - "no-of-params" description changed to int as short would
;                   have a different meaning under a full ANSI compiler.
;                 - Removed link/ulnk instructions by making all parameter
;                   references relative to Stack Pointer.
;
;   06 Nov 93   DJW   - Added underscore to entry point name
;                     - Allowed for fact that parameters of type 'short' are
;                       now passed as 2 bytes and not 4 bytes as previously.


    .text
    .even
    .globl _c_extop

SAVEREG equ 16+4                ; Size of saved registers + return address

_c_extop:
    movem.l d2/d3/a2/a3,-(a7)
    moveq.l #$9,d0              ; byte code for sd_extop
    move.l  0+SAVEREG(a7),a0    ; channel id
    move.w  4+SAVEREG(a7),d3    ; timeout
    lea     callrout,a2
    move.l  6+SAVEREG(a7),d1    ; operation to perform
    lea.l   10+SAVEREG(a7),a1   ; address of parameters
    trap    #3
    movem.l (a7)+,d2/d3/a2/a3
    rts

;   This next bit of code will be called in Supervisor mode
;   from within the sd_extop/iow_xtop call.

callrout:
    move.l  a0,-(sp)            ; keep base of channel block
    move.l  usp,a0              ; replace ssp by usp
    move.l  sp,-(a0)
    move.l  a0,sp
    move.l  d1,a0               ; routine to call
    move.l  (a1)+,d3            ; number of parameters
    move.l  d3,d2
    lsl.l   #2,d3               ; convert number of parameters to size
    adda.l  d3,a1               ; last parameter
    bra     join                ; enter copy loop
cop:
    move.l  -(a1),-(sp)
join:
    dbf d2,cop                  ; limit of 32K parameters - should be enough !

    jsr     (a0)
    add.l   d3,sp               ; ... and use to remove copies of parameters
    move.l  (sp)+,sp            ; restore ssp
    move.l  (sp)+,a0            ; restore base of channel block
    moveq   #0,d0               ; Set return to 0
    rts

#if 0
.text
.even
.globl _iow_xtop

; routine to do screen extended operation
; should include the following line in a header file !!
; long iow_xtop(long chid, long timeout, void (*rout)(), short no_of_params,)
; these parameters should be followed by no_of_params which are passed on
; to the specified C routine.

; written by Joachim Van der Auwera
; for PROGS, PROfessional & Graphical Software
; (c) 31 August 1993


_iow_xtop:
    link    a6,#0
    movem.l d2/d3/a2/a3,-(a7)
    moveq   #0,d0               ; sms.info
    trap    #1                  ; figure out system version (d2)

    moveq.l #$9,d0              ; byte code for sd_extop
    move.l  8(a6),a0            ; channel id
    move.w  $e(a6),d3           ; timeout
    lea     callrout,a2
    move.l  $10(a6),d1          ; operation to perform
    lea.l   $14(a6),a1          ; address of parameters
    trap    #3
    movem.l (a7)+,d2/d3/a2/a3
    unlk    a6
    rts

callrout:
    move.l  a0,-(sp)            ; keep base of channel block
    move    sr,-(sp)            ; keep status registers

; next line is introduced to solve Minerva problems (see below),
; however, it can introduce problems on Atiri Emulator QL machines, when
; CTRL was held down on interrupt disable, on released as second or following
; key during the time the interrupts are disabled
; Therefor, we try to detect Minerva by checking the system version (passed in
; d2). When >"??50" we assume Minerva. Do not know if this is safe !!
    cmpi.w  #$3530,d2           ; Minerva ??
    bmi     nomin               ; assume not
    ori     #$700,sr            ; disable interrupts
nomin:

; next three lines are cause Minerva problems !!
; Minerva calulates the sysvar base with ssp&ffff8000 which makes
; supervisor stack replacement impossible !!
    move.l  usp,a0              ; replace ssp by usp
    move.l  sp,-(a0)
    move.l  a0,sp

    move.l  d1,a0               ; routine to call
    move.l  (a1)+,d3            ; number of parameters
    move.l  d3,d2
    lsl.w   #2,d3
    beq     do
    adda.w  d3,a1               ; last parameter
    subq.w  #1,d2
cop:
    move.l  -(a1),-(sp)
    dbf d2,cop
do:
    jsr     (a0)
    add.l   d3,sp

; next line is removed because it failed on Minerva !!
    move.l  (sp)+,sp            ; restore ssp

    move    (sp)+,sr            ; enable interrupts again
    move.l  (sp)+,a0            ; restore base of channel block
    moveq   #0,d0
    rts

#endif
