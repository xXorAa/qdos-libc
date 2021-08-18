;
;   i o _ e d l i n / i o b _ e l i n
;
; routine to do edited line call. this is complicated - see definition
; best used by fdedit(). equivalent to c routine
;
;   int io_edlin( chanid_t chan, timeout_t timeout, char **cptr, short bufsize, 
;                           short crnt_offset, short *crnt_linelen)
;
; returns QDSO error code.
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   11 jul 93   DJW   - Removed setting of _oserr.  Now merely returns the
;                       QDOS error code on failure
;                     - Removed link/ulnk instructions by making parameter
;                       access relatived to a7
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

    .globl __io_edlin         ; QDOS name for call
    .globl __iob_elin         ; SMS name for call

SAVEREG equ 16+4        ; size of saved registers + return address

__io_edlin:
__iof_elin:
    movem.l d2/d3/a2/a3,-(a7)   ; save registers taht will be corrupted
    moveq.l #4,d0               ; byte code
    move.l  0+SAVEREG(a7),a0    ; channel id
    move.w  4+SAVEREG(a7),d3    ; timeout
    move.l  6+SAVEREG(a7),a1    ; address of pointer to current character
    move.l  a1,a3               ; save it to put new end of line pointer in
    move.l  (a1),a1             ; pointer to current character
    move.w  10+SAVEREG(a7),d2   ; buffersize
    move.l  12+SAVEREG(a7),d1   ; current cursor position (into top 2 bytes)
    move.l  14+SAVEREG(a7),a2   ; get address of current linelen
    move.w  (a2),d1             ; put current linelen in low 16 bits
    trap    #3
    move.w  d1,(a2)             ; new linelength (including terminator)
    move.l  a1,(a3)             ; pointer to byte past end of line
    movem.l (a7)+,d2/d3/a2/a3   ; restore saved registers
    rts

