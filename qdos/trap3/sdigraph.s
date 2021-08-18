;
;           s d i g r a p h
;
;
;   Routines to call the ql graphics traps with integer parameters
;
; Equivalent to c routines :-
;
;   int sd_iarc( chanid_t chan, timeout_t timeout, 
;                int x_start, int y_start, int x_end, int y_end, int angle)
;   int sd_ielipse( chanid_t chan, timeout_t timeout, int x_centre, y_centre,
;                   int eccentricity, int radius, int angle_of_rotation)
;   int sd_igcur( chanid_t chan, timeout_t timeout, int vert_offset, 
;                   int horiz_offset, int x_pos, int y_pos )
;   int sd_iline( chanid_t chan, timeout_t timeout, 
;                   int x_start, int y_start, int x_end, int y_end )
;   int sd_ipoint( chanid_t chan, timeout_t timeout, int x, int y)
;   int sd_iscale( chanid_t chan, timeout_t timeout, int scale, 
;                   int x_origin, y_origin)
;
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   11 Jul 93   DJW   - Removed setting of _oserr.
;
;   24 Jul 93   DJW   - Changed entry point to _sdigraph (was sd_igraphic)
;                     - Changed link/ulnk to use a5 instead of a6
;                     - Added SMS entry points
;
;   06 Nov 93   DJW   - Merged all the integer gpahic rouitnes into this
;                       single source file.
;                     - Added underscors to entry point names.
;                     - Allowed for fact that parameters of type 'short' are
;                       now passed as 2 bytes rather than 4 bytes.
;
;   20 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even

    .globl  __sd_iarc         ; QDOS name for call
    .globl  __iog_arc_i       ; SMS name for call

__sd_iarc:
__iog_arc_i:
    moveq   #$32,d0         ; function code for an arc
    moveq   #5,d1           ; Number of parameters
    bra     sdigraph


    .globl  __sd_ielipse     ; QDOS name for call
    .globl  __iog_elip_i     ; SMS name for call

__sd_ielipse:
__iog_elip_i:
    moveq   #$33,d0          ; function code for an elipse
    moveq   #5,d1           ; quick way of putting stuff on the stack
    bra     sdigraph        ; do call


    .globl  __sd_igcur        ; QDOS name for call
    .globl  __iog_sgcr_i      ; SMS name for call

__sd_igcur:
__iog_sgcr_i:
    moveq   #$36,d0         ; function code for graphics cursor set
    moveq   #4,d1           ; quick way of putting stuff on the stack
    bra     sdigraph        ; do call


    .globl  __sd_iline            ; QDOS name for call
    .globl  __iog_line_i          ; SMS name for call

__sd_iline:
__iog_line_i:
    moveq   #$31,d0         ; function code for a line
    moveq   #4,d1           ; quick way of putting stuff on the stack
    bra     sdigraph        ; do call


    .globl  __sd_ipoint       ; QDOS name for call
    .globl  __iog_dot_i       ; SMS name for call

__sd_ipoint:
__iog_dot_i:
    moveq   #$30,d0     ; function code for a point
    moveq   #2,d1       ; quick way of putting 2 on the stack
    bra     sdigraph    ; do call


    .globl  __sd_iscale       ; QDOS name for call
    .globl  __iog_scal_i      ; SMS name for call

__sd_iscale:
__iog_scal_i:
    moveq   #$34,d0         ; function code for scale set
    moveq   #3,d1           ; quick way of putting stuff on the stack


;   Common code - registers should be set up as follow:
;       d0  function code
;       d1  count of parameters

PARAMS equ  4+4         ; size of return address + link address

sdigraph:
    link    a5,#-270            ; ensure enough space for traps
    movem.l d3/d4/a2/a3,-(a7)   ; save regs
    move.w  d0,d4               ; save function code
    move.w  d1,d3               ; number of integer parameters
    lea.l   6+PARAMS(a5),a2     ; address of parameters start
    move.l  a5,a3               ; maths stack start
loop:
    move.l  (a2)+,-(a7)         ; put parameter on stack for conversion
    subq.l  #6,a3               ; allow for a ql float
    move.l  a3,-(a7)            ; address to put qlfloat
    jsr     _l_to_qlfp          ; convert the integer
    addq.l  #8,a7               ; unstack parameters
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

