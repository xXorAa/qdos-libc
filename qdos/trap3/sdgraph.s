;
;   s d g r a p h
;
; Routine to call the QDOS graphics traps
;       sd_arc
;       sd_elipse
;       sd_gcur
;       sd_line
;       sd_point
;       sd_scale
;
; equivalent to c routines :-
;
;   int sd_arc ( chanid_t chan, timeout_t timeout, 
;                                   double x_start, double y_start,
;                                   double x_end, double y_end, double angle)
;   int sd_ielipse( chanid_t chan, timeout_t timeout,
;                                   double x_centre, double y_centre, 
;                                   double  eccentricity, double radius, 
;                                   double angle_of_rotation)
;   int sd_gcur ( chanid_t chan, timeout_t timeout,
;                                   double vert_offset, double horiz_offset, 
;                                   double x_pos, double y_pos )
;   int sd_line( chanid_t chan, timeout_t timeout, 
;                                   double x_start, double y_start, 
;                                   double x_end, double y_end )
;   int sd_point( chanid_t chan, timeout_t timeout, 
;                                   double x, double y)
;   int sd_iscale( chanid_t chan, timeout_t timeout, 
;                                   double scale,
;                                   double x_origin,double y_origin)
;
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
; 02/07/92  The copying of 'double' parameters was reversing them!
;           (Problem report and fix by Anton Botsch)
; 15/08/92  Small optimisation when adding small value to stack.
;           (Richard Kettlewell)
;
;   02 Jul 92   DJW   - value in D0 for sd_gcur changed to $36 (was $32)
;                       Problem report and fix provided by Anton Bosch
;
;   11 Jul 93   DJW   - Removed setting of _oserr.  Now merely returns the
;                       QDOS error code
;
;   24 Jul 93   DJW   - Changed link/ulnk to use a5
;                     - Added SMS entry points
;
;   06 Nov 93   DJW   - Merged in sd_arc, sd_elispse, sd_gcur, sd_line and
;                       sd_point into a single file.
;                     - Added underscore to entry point names.
;                     - Allowed for fact that parameters of type 'short' are
;                       now passed as 2 bytes and not 4 bytes as previously.
;
;   20 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes
;
;   03 Sep 94   DJW   - Added underscore to _d_to_qlfp for name hiding reasons

    .text
    .even

    .globl  __sd_arc      ; QDOS name for call
    .globl  __iog_arc     ; SMS name for call

__sd_arc:
__iog_arc:
    moveq   #$32,d0      ; function code for an arc
    moveq   #5,d1        ; Number of parameters
    bra     sdgraph      ; do call


    .globl  __sd_elipse       ; QDOS name for call
    .globl  __iog_elip        ; SMS name for call

__sd_elipse:
__iog_elip:
    moveq   #$33,d0     ; function code for an elipse
    moveq   #5,d1       ; Number of parameters
    bra     sdgraph     ; do call


    .globl  __sd_gcur         ; QDOS name for call
    .globl  __iog_sgcr        ; SMS name for call

__sd_gcur:
__iog_sgcr:
    moveq   #$36,d0     ; function code for graphics cursor set         v3.02
    moveq   #4,d1       ; number of parameters
    bra     sdgraph     ; do call


    .globl  __sd_line         ; QDOS name for call
    .globl  __iog_line        ; SMS name for call

__sd_line:
__iog_line:
    moveq   #$31,d0          ; function code for a line
    moveq   #4,d1            ; quick way of putting stuff on the stack
    bra     sdgraph          ; do call

    .globl  __sd_point        ; QDOS name for call
    .globl  __iog_dot         ; SMS name for call

__sd_point:
__iog_dot:
    moveq   #$30,d0         ; function code for a point
    moveq   #2,d1           ; Number of parameters
    bra     sdgraph         ; go to carry out call


    .globl  __sd_scale        ; QDOS name for call
    .globl  __iog_scal        ; SMS name for call

__sd_scale:
__iog_scal:
    moveq   #$34,d0     ; function code for scale set
    moveq   #3,d1       ; quick way of putting stuff on the stack

;
;   Shared code.  Registers should be set up as follows:
;       d0  Function code
;       d1  Count of parameters

PARAMS equ  4+4         ; size of return address + link address

sdgraph:
    link    a5,#-270            ; ensure enough space for traps
    movem.l d3/d4/a2/a3,-(a7)    ; save regs
    move.w  d0,d4               ; save function code required
    move.w  d1,d3               ; number of integer parameters
    lea.l   6+PARAMS(a5),a2     ; address of parameters start
    move.l  a5,a3               ; maths stack start
loop:
    move.l  4(a2),-(a7)         ; put double parameter on stack         v3.02
    move.l  (a2),-(a7)          ; ... and second half                   v3.02
    addq.l  #8,a2               ; ... and update source pointer         v3.02
    subq.l  #6,a3               ; allow for a ql float
    move.l  a3,-(a7)            ; address to put qlfloat
    jsr     __d_to_qlfp         ; convert the integer
    add.w   #12,a7              ; unstack parameters                    v3.03
    subq.w  #1,d3               ; one less parameter
    bne     loop                ; do more if neccessary
    move.l  0+PARAMS(a5),a0     ; channel id
    move.w  4+PARAMS(a5),d3     ; timeout
    move.l  a3,a1               ; maths stack start
    move.w  d4,d0               ; code for trap
    trap    #3                  ; do call
    movem.l (a7)+,d3/d4/a2/a3   ; retrieve values
    unlk    a5
    rts

