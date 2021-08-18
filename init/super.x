;
;       _ s u p e r   /   _ u s e r
;
; Routines for entering/leaving Supervisor mode.
; They are protected against attempts being made to enter/leave
; supervisor mode when already in that state, so that the programmer
; only needs to be aware of the local need for supervisor mode.
;
; This is very C specific.
;
; Special conditions are:
;   a) The routines must be called with no parameters on the stack,
;      or it will mess up on return.
;   b) The routine _superend() or _user() must be called before exiting
;      the C function that called the _super() routine.
;   c) The following special assumptions are made about regsiter usage
;      which are stricter than normal for a C library routine:
;      1) The _super() routine only corrupts d0/d1.
;      2) The _superend() and _user() routines will NOT corrupt d0.
;      This is for convenience of assembler library routines.
;
; Equivalent to C routines:
;
;   void _super (void)
;   void _user  (void)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   13 Apr 94   EAJ   - _super() saves SR on stack, and _user() returns to
;                       the saved mode. This allows for nested calls to
;                       _super/_user(). Only the last call to _user() will
;                       return to user mode. Why this ?
;                       Example: Someone writes a function called foo(), which
;                       contains a call to _super()/_user(). Someone else,
;                       who does not know the internals of foo(), should be
;                       able to write a function baz(), which also calls
;                       _super()/_user(), with a call to foo() inside.
;
;   06 Sep 95   RZ    - added check for pending signals after returning
;                       to user mode
;
;   13 Jul 98   DJW   - Added new entry point __superend.  This is to allow
;                       this routine to be used in contexts for which 
;                       checking signals on return to user mode is not
;                       appropriate
;
;   21 Jul 98   DJW   - The _superend() and _user() routines will now not
;                       corrupt d0.  This helps with calling it inside
;                       assembler routines that have d0 already set to a
;                       return code at the point for ending supervisor mode.

    .text
    .even
    .globl __super
    .globl __superend
    .globl __user

__super:                ; go to supervisor mode - only change stack pointer
    move.l   (a7)+,d0   ; get old return address from user stack
    move.w   sr,d1      ; get sr (including current mode)
    trap     #0         ; go to supervisor mode
    move.w   d1,-(a7)   ; save old sr on new stack
    move.l   d0,-(a7)   ; set supervisor stack up for the return
    rts

;   Exit supervisor mode but do not check signals

__superend:
    lea     userrts(pc),a0  ; dummy to skip check for outstanding signals
    bra     usercont

;   Exit supervisor mode checking signals
__user:                 ; return to previous mode (!)
    lea     __SigCheck,a0   ; Routine to check for oustanding signals

usercont:
    move.l   (a7)+,d2   ; get return address from supervisor stack
    move.w   (a7)+,d1   ; get saved sr
    move.w   d1,sr      ; restore saved mode
    move.l   d2,-(a7)   ; set return address on stack
    andi.w   #$2000,d1  ; user mode again ?
    bne      userrts

    move.l  d0,-(a7)    ; Save d0 to preserve it across this call
    jsr     (a0)
    move.l  (a7)+,d0    ; Restore d0

userrts:
    rts

