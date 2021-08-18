;
;   u t _ e r r
;   u t _ e r r 0
;
; Write an error message to specified channel
;
; equivalent to C routines
;
;   void    ut_err  (long errorcodem chanid_t channel)
;   void    ut_err0 (long errorcode)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   27 Jul 93   DJW   - Corrected bug in ut_err() code which corrupted
;                       the channel ID.
;                     - Merged the ut_err() and ut_err0() calls into a
;                       single source file.  Changed order of parameters
;                       to ut_err() while doing so for convenience.
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;                     - Added SMS entry point
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even
    .globl __ut_err
    .globl __ut_werms
__ut_err:
__ut_werms:
    move.l  8(a7),a0                ; get channel into a0
    move.w  $cc,a1                  ; get required vector into A1
    bra     share

    .globl  __ut_err0
    .globl  __ut_wersy
__ut_err0:
__ut_wersy:
    move.w  $ca,a1                  ; get required vector into A1


;   Shared code

share:
    move.l  4(a7),d0
    jsr     (a1)
    rts

