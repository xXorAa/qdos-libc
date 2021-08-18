;
;   i o p _ s v p w  /  i o p _ r s p w
;
; Pointer Environment routine to save/load part of a window into a save area
; in memory.  Definition of area to be saved passed in QLRECT pointer, pixel
; position in save area passed, also capability to create a new save
; area, or use an existing one.
;
; Equivalent to C routine:
;
;   int iop_rspw( long chid, timeout_t timeout, struct WM_wsiz *area,
;                         short start_x, short start_y, 
;                         int keepsave, void **save_address);
;
;   int iop_svpw( chanid_t chid, timeout_t timeout, struct WM_wsiz *area,
;               short start_x, short start_y, short savex_size,
;               short savey_size, void **save_address);
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       J. Allison Pointer Interface Traps
;
;   30 Oct 93   DJW   - Removed setting of _oserr
;                     - Removed need for link/ulnk instructions
;                     - Added underscore to entry point name.
;                     - Allowed for fact that parameters of type 'short' are
;                       now passed as 2 bytes rather than 4 bytes as previously
;
;   25 Nov 93   DJW   - Merged iop_rspw entry point into this file
;                       (this had the side effect of adding the missing
;                        parameter as reported by Nathan van der Aunera)
;
;    1 Aug 94   Nathan Van der AuWWWWera
;                     - yet again !!! Nothing can be done right it seems.
;                       It IS NOT so simple to combine both routines into one.
;                       What happens is that when using iop_rspw the
;                       save-address gets overwritten by the x,y coordinates.
;                       And, BTW, iop_rspw MAY NOT change the save-address, so
;                       why use a (void **) ????????????
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines
;                     - Changed to use void * as suggested above.
;                     - Routines ARE merged (and thus smaller) - this time
;                       so that they work correctly.
;                     - Removed d2 and a3 form list of registers saved
;                       (d2 need not be saved, and a3 is not corrupted)
;
;   18 Mar 95   DJW   - Removed movem.l instruction that was "left over" from
;                       an earlier implementation of this routine.
;                       (problem reported by PROGS).
;
;   08 Oct 95   DJW   - Fixed problem with iop_rspw not picking parameters up
;                       from correct stack offsets.
;                       (problem report and fix by Jonathan Hudson)

    .text
    .even
    .globl __iop_svpw
    .globl __iop_rspw

IOP_SVPW equ  $6d
IOP_RSPW equ  $6e
__iop_svpw:
    moveq.l  #IOP_SVPW,d0         ; Call code
    move.l   18+4(a7),a0          ; Address of save area pointer
    move.l   (a0),a0              ; address of save area (temporarily in a0)

    bsr     SHARED

    move.l  18+4(a7),a0           ; Address of save area pointer
    move.l  d1,(a0)               ; Possible new address of save area
    rts

__iop_rspw:
    moveq.l #IOP_RSPW,d0          ; Call code
    move.l  18+4(a7),a0           ; Address of save area (temporarily in a0)
    bsr     SHARED
    rts

SAVEREG  equ  8+4                 ; size of saved registers + return address

SHARED:
    movem.l  d3/a2,-(a7)
    move.l   a0,a2                ; put value saved in a0 into a2
    move.l   0+SAVEREG+4(a7),a0   ; LONG: Channel id
    move.w   4+SAVEREG+4(a7),d3   ; WORD: Timeout
    move.l   6+SAVEREG+4(a7),a1   ; LONG: Area to save
    move.l   10+SAVEREG+4(a7),d1  ; LONG: (2 x WORD) X and Y coord in save area
    move.l   14+SAVEREG+4(a7),d2  ; LONG: X and Y size of save area or Keep flag

    trap     #3

    movem.l  (a7)+,d3/a2
    rts
    
