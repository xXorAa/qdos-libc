;
;   f s _ m d i n f / i o f _ m i n f
;
; routine to return info on a medium.
; equal to C call
;   int fs_mdinf( chanid_t chan, timeout_t timeout, char *medname, 
;                   short *unusecs, short *goodsecs )
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   11 jul 93   DJW   - Removed setting of _oserr - now merely returns the
;                       QDOS error code on failure.
;                     - Removed link/ulnk instructions by making parameter
;                       access relative to a7
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

    .globl __fs_mdinf         ; QDOS name for call
    .globl __iof_minf         ; SMS name for call

SAVEREG equ 16+4        ; size of saved registers + return address

__fs_mdinf:
__iof_mdinf:
    movem.l d2/d3/a2/a3,-(a7)   ; save regs corrupted
    move.l  0+SAVEREG(a7),a0    ; channel id
    move.w  4+SAVEREG(a7),d3    ; timeout
    move.l  6+SAVEREG(a7),a1    ; buffer for medium name
    moveq.l #$45,d0             ; byte code
    trap    #3                  ; do the call
    tst.l   d0                  ; OK ?
    bne     fin                 ; ... No, exit with error

; call was ok

    move.l  14+SAVEREG(a7),a0   ; get pointer to good sectors
    move.w  d1,(a0)             ; ... and put good sectors in place
    swap    d1                  ; get unused sectors
    move.l  10+SAVEREG(a7),a0   ; get pointer to unused sectors
    move.w  d1,(a0)             ; ... put unused sectors in place

fin:
    movem.l (a7)+,d2/d3/a2/a3   ; restore saved registers
    rts

