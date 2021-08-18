;
;   i o _ d e le t e / i o a _ d e l f
;
; routine to delete a file
; equal to c routine
;   int io_delete( char *name )
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   10 Jul 93   DJW   - Removed setting of _oserr.
;
;   20 Jul 93   DJW   - Added SMS entry point
;
;   24 Jul 93   DJW   - Changed link/ulnk instructions to use a5
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even
    .globl __io_delete
    .globl __ioa_delf

SAVEREG equ 8               ; size of saved registers
WORKLEN equ 128             ; size of stack work area reserved for QL format name

__io_delete:                  ; QDOS entry point
__ioa_delf:                   ; SMS entry point
    link    a5,#-WORKLEN                ; create workspace on stack
    movem.l d3/a2,-(a7)                 ; save registers
    move.l  4+4(a5),-(a7)               ; name
    pea.l   -WORKLEN(a5)                ; qlstr location
    jsr     __cstr_to_ql                ; convert to qlstr
    addq.l  #8,a7                       ; tidy up stack
    move.l  d0,a0                       ; qlstr
    moveq.l #4,d0                       ; byte code
    moveq.l #-1,d1                      ; job id
    trap    #2
    movem.l (a7)+,d3/a2                 ; restore saved registers
    unlk    a5                          ; remove stack workspace
    rts

