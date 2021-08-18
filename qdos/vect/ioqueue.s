;
;   FILE: i o _ q u e u e
;
;   i o _ q e o f    /  i o q _ s e o f
;   i o _ q i n      /  i o q _ g b y t
;   i o _ q o u t    /  i o q _ p b y t
;   i o _ q s e t    /  i o q _ s e t q
;   i o _ q t e s t  /  i o q _ t e s t
;
; QDOS routines for queue handling.  Includes routines for:
;       - setting EOF marker
;       - adding a byte
;       - removing a byte
;       - setting up a queue
;       - testing a queue
;
; equivalent to C routines
;   void   io_qeof  (char *queue_pointer)
;   int    io_qin   (char *queue_pointer, int byte_value)
;   void   io_qout  (char *queue_pointer, char * next_byte)
;   void   io_qset  (char *queue_pointer, long queue_length)
;   void   io_qtest (char *queue_pointer, char * next_byte, long_ * free_space)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   10 Jul 93   DJW   - First version
;
;   27 Jul 93   DJW   - Produced single file merging all queue handling
;                       routines into a single source file
;                     - Added SMS entry points
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;                     - Added SMS entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes
;
;   17 Oct 97   DJW   - Corrected fact that io_queue was getting parameters
;                       from wrong stack offset (reported by Jonathan Hudson)
;                       Note that fix from Jonathan would have broken other
;                       routines in this file, so needed changing.
;
;   23 Aug 98   DJW   - Corrected fact that shared routine pushed d2, but then
;                       popped d3 (corrupting a potential register variable).
;                       (problem reported by David Gilham).

    .text
    .even

    .globl __io_qset
    .globl __ioq_setq
__io_qset:
__ioq_setq:
    move.w  $dc, a0             ; set vector
    bra     do_queue            ; ... and use common code


    .globl __io_qtest
    .globl __ioq_test
__io_qtest:
__ioq_test:
    move.w  $de, a0             ; set vector
    bsr     io_queue            ; ... and use common code
    tst.l   4+4(a7)             ; next byte wanted ?
    beq     nobyte              ; ... NO, skip
    move.l  4+4(a7),a0          ; get address to store next byte
    move.b  d1,(a0)             ; store byte in user area
nobyte:
    move.l  8+4(a7),d1          ; free space wanted ?
    beq     nofree              ; ... NULL = NO, jump
    move.l  d1,a0               ; get address to store free space
    move.l  a1,(a0)             ; store length in user area
nofree:
    rts


    .globl __io_qin
    .globl __ioq_pbyt
__io_qin:
__ioq_pbyt:
    move.w  $e0, a0             ; set vector
    bra     do_queue            ; ... and use common code


    .globl __io_qout
    .globl __ioq_gbyt
__io_qout:
__ioq_gbyt:
    move.w  $e2, a0             ; set vector
    bsr     io_queue            ; ... and use common code
    move.l  4+4(a7),a0          ; get address to store next byte
    move.b  d1,(a0)             ; store byte in user area
    rts


    .globl __io_qeof
    .globl __ioq_seof
__io_qeof:
__ioq_seof:
    move.w  $e4, a0             ; set vector
do_queue:
    bsr     io_queue            ; ... and use common code
    rts

;   Common code

SAVEREG equ 4+16

io_queue:
    movem.l d2-d3/a2-a3,-(a7)   ; save potential register variables
    move.l  4+SAVEREG(a7),a2    ; queue pointer
    move.l  8+SAVEREG(a7),d1    ; queue length/byte to put in
    jsr     (a0)                ; call it
    tst.l   d0                  ; OK ?
    bne     fin                 ; ... and jump if error
    move.l  d2,a1               ; save value for use in io_qtest()
fin:
    movem.l (a7)+,d2-d3/a2-a3   ; restore potentially corrupted registers
    rts

