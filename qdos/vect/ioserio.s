;
;   _ i o _ s e r i o
;
; QDOS general serial IO handling
; Equivalent to C routine
;   int io_serq ( chanid_t chanid, timeout_t timeout, int routine,
;                 long * D1, long * D2, char ** A1, ((int *)())func_array[])
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   10 Jul 93   DJW   - First version
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;                     - Added SMS entry points
;                     - Allowed for fact that parameters of type 'short' are
;                       now passed as 2 bytes and not 4 bytes.
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even
    .globl __io_serio
    .globl __iou_ssio

__io_serio:
__iou_ssio:
    movem.l d2-d3/a2-a3,-(a7)   ; save register variables
    move.l  4+16(a7),a0         ; channel id
    move.w  6+16(a7),d3         ; timeout
    move.l  10+16(a7),d0        ; routine number
    move.l  14+16(a7),a2        ; pointer to D1 value
    move.l  (a2),d1
    move.l  18+16(a7),a2        ; pointer to D2 value
    move.l  (a2),d2
    move.l  22+16(a7),a2        ; pointer to A1 value
    move.l  (a2),a1
    move.l  26+16(a7),a2        ; pointer to function array
    move.w  #$4e75,12(a2)       ; ensure finishes with RTS
    pea     cont                ; set continuation address
    move.l  26+16(a7),-(a7)     ; set vectors address
    move.w  $ea,a2              ; vector required
    jmp     (a2)
cont:
    move.l  14+16(a7),a2        ; pointer to D1 value
    move.l  d1,(a2)
    move.l  18+16(a7),a2        ; pointer to D2 value
    move.l  d2,(a2)
    move.l  22+16(a7),a2        ; pointer to A1 value
    move.l  a1,(a2)
    movem.l (a7)+,d2-d3/a2-a3   ; restore register variables
    rts


