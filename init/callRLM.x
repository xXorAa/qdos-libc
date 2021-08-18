;=========================================================================
;               C a l l R L M
;
;   Library support routine to call the Runtime Library Manager (RLM).
;
;   NOTE
;   ~~~~
;   The source to this module is held in the INIT sub0directory of the
;   LINC_A library source as it is automatically included in RLL versions
;   of start up modules as well as being available in the library as a
;   free-standing module
;
;   AMENDMENT HISTORY
;   ~~~~~~~~~~~~~~~~~
;   01 Oct 94   DJW   - First version for use in LIBC_A library.
;                       Based on sources provided by Lester Wareham.
;-------------------------------------------------------------------------

    .globl  _CallRLM

SMS.UTHG    equ     $28
SMS.FTHG    equ     $29

rlmname:    dc.b    0,3,'RLM',0
rlmaddr:    dc.l    0
retaddr:    dc.l    0

_CallRLM:
        moveq   #SMS.UTHG,d0        ; Use THING call
        moveq   #-1,d1              ; this job
        moveq   #-1,d3              ; infinite timeout
        lea     rlmname(pc),a0      ; get name of THING required
        bsr     ThingTrap           ; go find it
        tst.l   d0                  ; found ?
        bne     CallRLM_Exit        ; ... NO, then exit
        lea     retaddr(pc),a1      ; get place to store current return address
        move.l  (sp)+,(a1)          ; pop return address
        jsr     20(a0)              ; call RLM
        move.l  d0,-(sp)            ; save result code
        moveq   #SMS.FTHG,d0        ; set to free thing
        moveq   #-1,d1              ; for this job
        lea     rlmname(pc),a1      ; name of thing
        jsr     ThingTrap           ; go free it
        move.l  (sp)+,d0            ; restore exit code
        move.l  retaddr(pc),-(sp)   ; put back original return address
CallRLM_Exit:
        rts

