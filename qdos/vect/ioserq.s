;
;   _ i o _ s e r q
;
; QDOS serial IO direct queue handler
; Equiavlent to C routine
;   int io_serq ( chanid_t chanid, timeout_t timeout, int routine,
;                 long * D1, long * D2, char ** A1)
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
    .globl  __io_serq
    .globl  __iou_ssq

__io_serq:
__iou_ssq:
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
    move.w  $e8,a2              ; vector required
    jsr     (a2)
    move.l  14+16(a7),a2        ; pointer to D1 value
    move.l  d1,(a2)
    move.l  18+16(a7),a2        ; pointer to D2 value
    move.l  d2,(a2)
    move.l  22+16(a7),a2        ; pointer to A1 value
    move.l  a1,(a2)
    movem.l (a7)+,d2-d3/a2-a3   ; restore register variables
    rts


