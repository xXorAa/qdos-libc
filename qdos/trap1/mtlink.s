;
;   FILE: m t _ l i n k
;
;   m t _ l d d     / s m s _ l f s d
;   m t _ l i o d   / s m s _ l i o d
;   m t _ l p o l l / s m s _ l p o l
;   m t _ l s c h d / s m s _ l s h d
;   m t _ l x i n t / s m s _ l e x i
;
;   m t _ r d d     / s m s _ r f s d
;   m t _ r i o d   / s m s _ r i o d
;   m t _ r p o l l / s m s _ r p o l
;   m t _ r s c h d / s m s _ r s h d
;   m t _ r x i n t / s m s _ r e x i
;
; QDOS routines to link and unlink handlers into/from QDOS.
; Handlers allowed for are:
;      - external interrupts
;      - scheduler
;      - polled
;      - simple devices
;      - directory devices
;
; equal to C routines:
;
;   void mt_ldd  ( struct ql_ddevd *lnk)
;   void mt_liod ( struct ql_link *lnk)
;   void mt_lpoll( struct ql_link *lnk)
;   void mt_lschd( struct ql_link *lnk)
;   void mt_lxint( struct ql_link *lnk)

;   void mt_rdd  ( struct ql_ddevd *lnk)
;   void mt_riod ( struct ql_link *lnk)
;   void mt_rpoll( struct ql_link *lnk)
;   void mt_rschd( struct ql_link *lnk)
;   void mt_rxint( struct ql_link *lnk)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   20 Jul 93   DJW   - Added SMS name as additional entry point
;
;   27 Jul 93   DJW   - Merged all routines for linking/unlinking new
;                       handlers into/from QDOS into a single source file.
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even

    .globl __mt_lxint         ; QDOS name to link external interrupt handler
    .globl __sms_lexi         ; SMS name for call
__mt_lxint:
__sms_lexi:
    moveq   #$1a,d0
    bra     do_link

    .globl __mt_rxint         ; QDOS name to remove external interrup handler
    .globl __sms_rexi         ; SMS name for call
__mt_rxint:
__sms_rexi:
    moveq   #$1b,d0
    bra     do_link

    .globl __mt_lpoll         ; QDOS name to link polled routine
    .globl __sms_lpol         ; SMS name for call
__mt_lpoll:
__sms_lpol:
    moveq   #$1c,d0
    bra     do_link

    .globl __mt_rpoll         ; QDOS name to link polled routine
    .globl __sms_rpol         ; SMS name for call
__mt_rpoll:
__sms_rpol:
    moveq   #$1d,d0
    bra     do_link

    .globl __mt_lschd         ; QDOS name to link scheduler routine
    .globl __sms_lshd         ; SMS name for call
__mt_lschd:
__sns_lshd:
    moveq.l #$1e,d0 
    bra     do_link

    .globl __mt_rschd         ; QDOS name to remove scheduler routine
    .globl __sms_rshd         ; SMS name for call
__mt_rschd:
__sms_rshd:
    moveq   #$1f,d0
    bra     do_link

    .globl __mt_liod          ; QDOS name to link a simple device driver
    .globl __sms_liod         ; SMS name for call
__mt_liod:
__sms_liod:
    moveq   #$20,d0
    bra     do_link

    .globl __mt_riod          ; QDOS name to remove a simple device driver
    .globl __sms_riod         ; QDOS name for call
__mt_riod:
__sms_riod:
    moveq   #$21,d0
    bra     do_link

    .globl __mt_ldd           ; QDOS name to link a simple device driver
    .globl __sms_lfsd         ; SMS name for call
__mt_ldd:
__sms_lfsd:
    moveq   #$22,d0
    bra     do_link

    .globl __mt_rdd           ; QDOS name to remove a directory device driver
    .globl __sms_rfsd         ; SMS name for call
__mt_rdd:
__sms_rfsd:
    moveq   #$23,d0


do_link:
    move.l  4(a7),a0
    trap    #1
    rts

