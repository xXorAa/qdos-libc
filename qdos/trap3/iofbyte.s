;
;   i o _ f b y t e / i o b _ f b y t
;
; routine to fetch a byte from a channel
; equivalent to the c routine
;   int io_fbyte( chanid_t chan, timeout_t timeout, char *cptr)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   11 jul 93   DJW   - Removed setting of _oserr.  Now merely returns the
;                       QDOS error code
;
;   24 Jul 93   DJW   - Added SMS entry point
;
;   06 Nov 93   DJW   - Added underscore to entry point name
;                     - Allowed for fact that parameters of type 'short' are
;                       now passed as 2 bytes and not 4 bytes as previously.
;
;   20 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even

    .globl  __io_fbyte         ; QDOS name for call
    .globl  __iob_fbyt        ; SMS name for call

SAVEREG equ 12+4         ; size of saved registers + return address

__io_fbyte:
__iob_fbyt:
    movem.l d3/a2/a3,-(a7)      ; save register
    moveq.l #1,d0               ; byte code
    move.l  0+SAVEREG(a7),a0    ; channel id
    move.w  4+SAVEREG(a7),d3    ; timeout
    trap    #3
    move.l  6+SAVEREG(a7),a0    ; byte pointer
    move.b  d1,(a0)             ; store byte
    movem.l (a7)+,d3/a2/a3      ; unstack reg
    rts

