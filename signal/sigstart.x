;
;   S i g S t a r t
;
;   This is the vector that is called from the
;   normal C start up module.   It contains the
;   pointer to the initialisation vector.  The
;   Initialisation vector contains either the
;   address of the initialisation code, or NULL
;   if there are no signal handling routines
;   used within this program.
; 
;   AMENDMENT HISTORY
;   ~~~~~~~~~~~~~~~~~
;   29 Jun 97   DJW   - First version.  Used to link signal initialisation
;                       code into the start-up module.
; 
;   18 Mar 98   DJW   - Changed to use double indirection so that even signal
;                       initialisation code is not included if program does
;                       not use signals.  Saves about 450 bytes in this case.
 
    .text

    .globl   __SigStart

__SigStart:
    dc.l    checkvector

checkvector:
    move.l  __SigInitVector,d0      ; Get vector
    beq     urt                     ; ... and exit if not set
    move.l  d0,a0                   ; load into address register
    jsr     (a0)                    ; and call vector
urt:
    rts

