;   
;   FILE:   s d m i s c
;
;   QDOS routines for the majority of screen I/O handling
;   (except for sd_extop, sd_fount)
;
;   Window Size
;       - Size in pixels                sd_pxenq / iow_pixq
;       - Size in characters            sd_chenq / iow_chrq
;
;   Window Control
;       - Set Border                    sd_bordr / iow_defb
;       - Redefine a window             sd_wdef  / iow_defw
;
;   Cursor Control
;       - Enable cursor                 sd_cure / iow_ecur
;       - Disable cursor                sd_cure / iow_dcur
;
;   Cursor Positioning
;       - Specified column              sd_tab  / iow_scol
;       - New Line                      sd_nl   / iow_newl
;       - Previous Column               sd_pcol / iow_pcol
;       - Next column                   sd_ncol / iow_ncol
;       - Previous Row                  sd_prow / iow_prow
;       - Next Row                      sd_nrow / iow_nrow
;
;   Scrolling Screen
;       - whole window                  sd_scrol / iow_scra
;       - bottom of window              sd_scrbt / iow_scrb
;       - top of window                 sd_scrtp / iow_scrt
;
;   Panning Screen
;       - All of window                 sd_pan   / iow_pana
;       - cursor line                   sd_panln / iow_panl
;       - righthand end of cursor line  sd_panrt / iow_panr
;
;   Clearing Screen
;       - all of screen                 sd_clear / iow_clra
;       - below cursor                  sd_clrbt / iow_clrb
;       - cursor line                   sd_clrln / iow_clrl
;       - right of cursor line          sd_clrrt / iow_clrr
;       - top of screen above cursor    sd_clrtp / iow_clrt
;
;   Setting Modes
;       - set paper colour              sd_setpa / iow_spap
;       - set strip colour              sd_setst / iow_sstr
;       - set ink colour                sd_setin / iow_sink
;       - set flash attribute           sd_setfl / iow_sfla
;       - Set underline attribute       sd_setul / iow_sula
;       - set overwrite attribute       sd_setmd / iow_sova
;       - Area fill mode                sd_flood / iog_fill
;
;
;   All routines are equivalent to C routines of the form:
;
;       int sd_routine ( chanid_t chan, timeout_t timeout, ...)
;
; AMENDMENT HISTORY:
; ~~~~~~~~~~~~~~~~~
;   15 Aug 92   RK      The value moved to D1 changed to be LONG as this is
;                       required by SD_FLOOD  (Richard Kettlewell).
;
;   11 Jul 93   DJW     Removed setting of _oserr.  Now merely returns the
;                       QDOS error code.
;
;   24 Jul 93   DJW   - Added SMS entry point
;
;   29 Jul 93   DJW   - Merged all entry points into this common source file
;
;   06 Nov 93   DJW   - Added underscore to entry points.
;                     - Allowed for fact that parameters of type 'short' are
;                       now passed as 2 bytes and not 4 bytes.
;                     - Removed fs_xxx and io_xxx routines to their own file,
;                       and finished merging in remaining sd_xxxx routines.
;
;   20 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes
;
;   01 Oct 95   DJW   - The iow_defw() and iow_scrt() routines had their names
;                       mispelt so they were not being made globally visible.
;
;   24 Jan 96   DJW   - Minor change to order of code that reduces size
;                       (change suggested by Jack Mitchell)


    .text
    .even

;--------------------------- Window Size -------------------------

    .globl  __sd_pxenq       ; QDOS name for call
    .globl  __iow_pixq       ; SMS name for call
__sd_pxenq:
__iow_pixq:
    moveq   #$a,d0
    bra     share_3a1

    .globl  __sd_chenq       ; QDOS name for call
    .globl  __iow_chrq       ; SMS name for call
__sd_chenq:
__iow_chrq:
    moveq   #$b,d0
    bra     share_3a1

;----------------------- Window Control ------------------------------

    .globl  __sd_bordr       ; QDOS name for call
    .globl  __iow_defb       ; SMS name for call
__sd_bordr:
__iow_defb:
    moveq   #$c,d0          ; code
    bra     share_4w3b

    .globl  __sd_wdef        ; QDOS name for call
    .globl  __iow_defw       ; SMS name for call
__sd_wdef:
__iow_defw:
    moveq   #$d,d0          ; code
    move.l  10+4(a7),a1     ; param block
    bra     share_4w3b


;------------------------- Cursor Control ---------------------

    .globl  __sd_cure         ; QDOS name for call
    .globl  __iow_ecur        ; SMS name for call
__sd_cure:
__iow_ecur:
    moveq   #$e,d0
    bra     share

    .globl  __sd_curs         ; QDOS name for call
    .globl  __iow_dcur        ; SMS name for call
__sd_curs:
__iow_dcur:
    moveq   #$f,d0
    bra     share

;------------------------- Cursor Positioning ------------------

    .globl  __sd_pos         ; QDOS name for call
    .globl  __iow_scur       ; SMS name for call
__sd_pos:
__iow_scur:
    moveq   #$10,d0             ; trap code required
    bra     share_4w3w

    .globl  __sd_tab            ; QDOS name for call
    .globl  __iow_scol          ; SMS name for call
__sd_tab:
__iow_scol:
    moveq   #$11,d0
    bra     share_3w

    .globl  __sd_nl           ; QDOS name for call
    .globl  __iow_newl        ; SMS name for call
__sd_nl:
__iow_newl:
    moveq   #$12,d0
    bra     share

    .globl  __sd_pcol         ; QDOS name for call
    .globl  __iow_pcol        ; SMS name for call
__sd_pcol:
__iow_pcol:
    moveq   #$13,d0
    bra     share

    .globl  __sd_ncol         ; QDOS name for call
    .globl  __iow_ncol        ; SMS name for call
__sd_ncol:
__iow_ncol:
    moveq   #$14,d0
    bra     share

    .globl  __sd_prow         ; QDOS name for call
    .globl  __iow_prow        ; SMS name for call
__sd_prow:
__iow_prow:
    moveq   #$15,d0
    bra     share

    .globl  __sd_nrow         ; QDOS name for call
    .globl  __iow_nrow        ; SMS name for call
__sd_nrow:
__iow_nrow:
    moveq   #$16,d0
    bra     share

    .globl  __sd_pixp
    .globl  __iow_spix
__sd_pixp:
__iow_spix:
    moveq   #$17,d0             ; trap code required
    bra     share_4w3w

;------------------- Scroll Routines ---------------------------

    .globl  __sd_scrol        ; QDOS name for call
    .globl  __iow_scra        ; SMS name for call
__sd_scrol:
__iow_scra:
    moveq   #$18,d0     ; set code for call
    bra     share_3w

    .globl  __sd_scrtp        ; QDOS name for call
    .globl  __iow_scrt        ; SMS name for call
__sd_scrtp:
__iow_scrt:
    moveq   #$19,d0     ; set code for call
    bra     share_3w

    .globl  __sd_scrbt        ; QDOS name for call
    .globl  __iow_scrb        ; SMS name for call
__sd_scrbt:
__iow_scrb:
    moveq   #$1a,d0         ; set code for call
    bra     share_3w

;------------------------- Pan screen -------------------------

    .globl  __sd_pan          ; QDOS name for call
    .globl  __iow_pana        ; SMS name for call
__sd_pan:
__iow_pana:
    moveq   #$1b,d0     ; set code for call
    bra     share_3w

    .globl  __sd_panln        ; QDOS name for call
    .globl  __iow_panl        ; SMS name for call
__sd_panln:
__iow_panl:
    moveq   #$1e,d0     ; set code for call
    bra     share_3w

    .globl  __sd_panrt        ; QDOS name for call
    .globl  __iow_panr        ; SMS name for call
__sd_panrt:
__iow_panr:
    moveq   #$1f,d0     ; set code for call
    bra     share_3w

;**********************************************************************
;   Code common to all entry points
;
;   Inserted centrally in file to enable
;   branches to be short
;***********************************************************************

share_3a1:
    move.l  6+4(a7),a1          ; Parameter 3 is a1
    bra     share

share_3l:
    move.l  6+4(a7),d1          ; Parameter 3 is a long for d1
    bra     share

share_4w3w:
    move.w  8+4(a7),d2          ; Parameter 4 is a word for D2
                                ; ... followed by Param 3 as word (byte) for d1
share_3w:
    move.w  6+4(a7),d1          ; Parameter 3 is a word for d1
    bra     share

share_4w3b:
    move.w  8+4(a7),d2          ; Parameter 4 is a word for D2
                                ; ... followed by Param 3 as byte for d1
share_3b:
    move.b  7+4(a7),d1          ; Parameter 3 is a byte for d1

SAVEREG equ 12+4         ; size of saved registers + return address

share:
    movem.l d3/a2/a3,-(a7)      ; save possible register variables
    move.l  0+SAVEREG(a7),a0    ; channel id
    move.w  4+SAVEREG(a7),d3    ; timeout
    trap    #3                  ; do call
    movem.l (a7)+,d3/a2/a3      ; restore corrupted reg
    rts

;---------------------- Clearing Screen -------------------------

    .globl  __sd_clear        ; QDOS name for call
    .globl  __iow_clra        ; SMS name for call
__sd_clear:
__iow_clra:
    moveq   #$20,d0         ; set code for call
    bra     share

    .globl  __sd_clrtp        ; QDOS name for call
    .globl  __iow_clrt        ; SMS name for call
__sd_clrtp:
__iow_clrt:
    moveq   #$21,d0         ; set code for call
    bra     share

    .globl  __sd_clrbt        ; QDOS name for call
    .globl  __iow_clrb        ; SMS name for call
__sd_clrbt:
__iow_clrb:
    moveq   #$22,d0     ; set code for call
    bra     share

    .globl  __sd_clrln        ; QDOS name for call
    .globl  __iow_clrl        ; SMS name for call
__sd_clrln:
__iow_clrl:
    moveq   #$23,d0     ; set code for call
    bra     share

    .globl  __sd_clrrt        ; QDOS name for call
    .globl  __iow_clrr        ; SMS name for call
__sd_clrrt:
__iow_clrr:
    moveq   #$24,d0         ; set code for call
    bra     share

;------------------ Setting Modes -------------------------

    .globl  __sd_recol        ; QDOS name for call
    .globl  __iow_rclr        ; SMS name for call
__sd_recol:
__iow_rclr:
    moveq   #$26,d0
    bra     share_3a1

    .globl  __sd_setpa            ; QDOS name for call
    .globl  __iow_spap            ; SMS name for call
__sd_setpa:
__iow_spap:
    moveq   #$27,d0
    bra     share_3w

    .globl  __sd_setst            ; QDOS name for call
    .globl  __iow_sstr            ; SMS name for call
__sd_setst:
__iow_sstr:
    moveq   #$28,d0
    bra     share_3w

    .globl  __sd_setin        ; QDOS name for call
    .globl  __iow_sink        ; SMS name for call
__sd_setin:
__iow_sink:
    moveq   #$29,d0
    bra     share_3w

    .globl  __sd_setfl        ; QDOS name for call
    .globl  __iow_sfla        ; SMS name for call
__sd_setfl:
__iow_sfla:
    moveq   #$2a,d0
    bra     share_3b

    .globl  __sd_setul        ; QDOS name for call
    .globl  __iow_sula        ; SMS name for call
__sd_setul:
__iow_sula:
    moveq   #$2b,d0
    bra     share_3b

    .globl  __sd_setmd            ; QDOS name for call
    .globl  __iow_sova            ; SMS name for call
__sd_setmd:
__iow_sova:
    moveq   #$2c,d0
    bra     share_3w

    .globl  __sd_setsz            ; QDOS name for call
    .globl  __iow_ssiz            ; SMS name for call
__sd_setsz:
__iow_ssiz:
    moveq   #$2d,d0             ; byte code
    bra     share_4w3w


;------------------------ Block Filling ----------------------------

    .globl  __sd_fill         ; QDOS name for call
    .globl  __iow_blok        ; SMS name for call
__sd_fill:
__iow_blok:
    moveq   #$2e,d0           ; byte code for sd_fill
    move.l  8+4(a7),a1
    bra     share_3b

    .globl  __sd_donl         ; QDOS name for call
    .globl  __iow_donl        ; SMS name for call

__sd_donl:
__iow_donl:
    moveq   #$2f,d0             ; byte code
    bra     share


    .globl  __sd_flood        ; QDOS name for call
    .globl  __iog_fill        ; SMS name for call
__sd_flood:
__iog_fill:
    moveq   #$35,d0
    move.l  6+4(a7),d1       ; Parameter 3 is a long for d1
    bra     share

