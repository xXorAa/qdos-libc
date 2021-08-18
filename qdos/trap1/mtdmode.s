;
;   m t _ d m o d e / s m s _ d m o d
;
; routine to read or set the display mode.
; equals C routines
;
;   void mt_dmode( short * s_mode, short * d_type)
;   void sms_dmod( short * s_mode, short * d_type)
;
;   where
;       *s_mode = 4 for mode 4, 8 for mode 8, -1 for read
;       *d_type = 0 for monitor mode, 1 for tv mode, -1 for read
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   20 Jul 93   DJW   - Added SMS name as additional entry point
;                     - Removed link/ulnk instruction by making all
;                       parameter access relative to a7
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes
;
;   25 Jan 94   DJW   - Parameters changed to use 'word' values instead of
;                       'char' values.  This is to allow Minerva externsions
;                       to be accessible.  Reported by J. Mitchell.

    .text
    .even
    .globl __mt_dmode
    .globl __sms_dmod

SAVEREG equ 20                  ; size of saved registers

__mt_dmode:                     ; QDOS name
__sms_dmod:                     ; SMS name
    movem.l d2/a0-a1/a3-a4,-(a7)
    move.l  4+SAVEREG(a7),a0
    move.w  (a0),d1             ; *s_mode
    move.l  8+SAVEREG(a7),a1
    move.w  (a1),d2             ; *d_type
    moveq.l #$10,d0             ; byte code
    trap    #1
    move.w  d1,(a0)             ; set mode
    move.w  d2,(a1)             ; set display
    movem.l (a7)+,d2/a0-a1/a3-a4
    rts

