;
;       _ S i g N o I m p x
; 
;   Dummy routine called when this program does
;   not have any signla handling support included.
; 
;   AMENDMENT HISTORY
;   ~~~~~~~~~~~~~~~~~
;   04 Apr 98   DJW   - First version 

    .text

    .globl  __SigNoImp

__SigNoImp:
    move.l  #-1,d0
    rts

