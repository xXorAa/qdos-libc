;
;   f s _ d a t e / i o f _ d a t e
;   f s _ v e r s / i o f _ v e r s
;
; routine to set or read a file date or version number.
;
; Equivalent to C routines:
;
;   int fs_date( chanid_t chan, timeout_t timeout, char type, long *sr_date )
;   int fs_vers( chanid_t chid, timeout_t timeout, long *key )
; 
; if type = 0 - then access update date, if type = 2, then access backup date
; if *sr_date = -1 then read date,
; if *sr_date = 0 then set requested date to current date
; if *sr_date = date then set requested date to given date.
;
; *key = -1, return version number.
; *key = 0, preserves old number when file closed
; *key = version no. - sets requested version no.
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   11 Jul 93   DJW   - Removed setting of _oserr.
;                     - Removed link/ulnk instructions by making parameter
;                       access relative to a7
;
;   24 Jul 93   DJW   - Added SMS entry point
;
;   18 Aug 93   DJW   - Changed QDOS entry point to fs_date()
;
;   06 Nov 93   DJW   - Added underscore to entry point name
;                     - Allowed for fact that parameters of type 'short' are
;                       now passed as 2 bytes and not 4 bytes as previously.
;                     - merged if fs_vers() routine
;
;   20 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes
;
;   28 Jan 94   DJW   - Corrected problem with parameters not being picked up
;                       from correct stack position.  Reported by Eric Slagter.

    .text
    .even

SAVEREG equ 12+4         ; size of saved regsiters + return address

    .globl __fs_date          ; QDOS name for call
    .globl __io_fdate         ; obsolete QDOS name
    .globl __iof_date         ; SMS name for call

__fs_date:
__io_fdate:
__iof_date:
    moveq   #$4c,d0            ; byte code
    move.w  6+4(a7),d2         ; type  (strictly only a byte value needed)
    move.l  8+4(a7),a1         ; &sr_date
    bra shared


    .globl  __fs_vers         ; QDOS name for call
    .globl  __io_fvers        ; obsolete QDOS name for call
    .globl  __iof_vers        ; SMS name for call

__fs_vers:
__io_fvers:
__iof_vers:
    moveq   #$4e,d0             ; byte code
    move.l  6+4(a7),a1          ; pointer to key

shared:
    movem.l d3/a2/a3,-(a7)      ; save corrupted regs
    move.l  0+SAVEREG(a7),a0    ; channel id
    move.w  4+SAVEREG(a7),d3    ; timeout
    move.l  (a1),d1             ; get contents pointed to by a1
    trap    #3
    move.l  d1,(a1)             ; date set or read
    movem.l (a7)+,d3/a2/a3      ; restore saved registers
    rts
 
