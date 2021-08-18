;
;   i o _ c l o s e / i o a _ c l o s
;
; routine to close a channel
; equal to c routine
;   int io_close( chanid_t chan )
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   10 Jul 93   DJW   - Removed setting of _oserr.
;
;   20 Jul 93   DJW   - Added SMS entry point
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even
    .globl __io_close
    .globl __ioa_clos

__io_close:                       ; QDOS entry point
__ioa_clos:                       ; SMS entry point
    moveq.l #2,d0
    move.l  4(a7),a0
    trap    #2
    rts

