;
;       c n _ i t o
;
; QDOS vectors to convert a number to DECIMAL/HEX/BINARY 
; ASCII strings
;
; Equivalent to C routines of the form:
;
;   char * cn_ito?? (char * dest, 'type *' value)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;               DJW   - First version
;
; 29 Jul 93     DJW   - Added SMS entry points
;                     - Removed link/ulnk instructions by making all
;                       parameter access relative to a7
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even

    .globl __cn_itod      ; QDOS name for call
    .globl __cv_iwdec     ; SMS name for call
__cn_itod:
__cv_iwdec:
    move.w  $f2,a0
    bra     shared

    .globl  __cn_itobb    ; QDOS name for call
    .globl  __cv_ibbin    ; SMS name for call
__cn_itobb:
__cv_ibbin:
    move.w  $f4,a0
    bra     shared

    .globl  __cn_itobw    ; QDOS name for call
    .globl  __cv_iwbin    ; SMS name for call
__cn_itobw:
__cv_iwbin:
    move.w  $f6,a0
    bra     shared

    .globl  __cn_itobl    ; QDOS name for call
    .globl  __cv_ilbin    ; SMS name for call
__cn_itobl:
__cv_ilbin:
    move.w   $f8,a0
    bra     shared

    .globl  __cn_itohb    ; QDOS name for call
    .globl  __cv_ibhex    ; SMS name for call
__cn_itohb:
__cv_ibhex:
    move.w  $fa,a0
    bra     shared

    .globl  __cn_itohw    ; QDOS name for call
    .globl  __cv_iwhex    ; SMS name for call
__cn_itohw:
__cv_iwhex:
    move.w  $fc,a0
    bra     shared

    .globl  __cn_itohl    ; QDOS name for call
    .globl  __cv_ilhex    ; SMS name fpr call
__cn_itohl:
__cv_ilhex:
    move.w  $fe,a0

SAVEREG equ 16+4        ; size of saved registers + return address

shared:
    movem.l d2-d3/a2-a3,-(a7)   ; save register variables
    move.l  a0,a2               ; save vector to use
    move.l  4+SAVEREG(a7),a1    ; get address of value
    sub.l   #4,a7               ; reserve stack space for value
    move.l  a7,a0               ; start of area
    moveq   #3,d0               ; count to move - 1
loop:
    move.b  (a1)+,(a0)+         ; move a byte (this allows for odd addresses in C)
    dbra    d0,loop             ; ... repeat until finished
    move.l  a7,a1               ; set A1 stack pointer
    sub.l   a6,a1               ; ... A1 must be A6 relative
    move.l  0+SAVEREG+4(a7),a0  ; target address
    sub.l   a6,a0               ; ... A0 must be A6 relative
    jsr     (a2)                ; call vector
    addq    #4,a7               ; tidy up stack
    move.l  d1,d0               ; set character count (for cn_itod())
    movem.l (a7)+,d2-d3/a2-a3   ; restore register variables
    rts

