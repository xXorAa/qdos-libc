;
;       l i b x c
;
;   This is a dummy library that is forced in when the -Xc option
;   is used with CC.  It modifies certain behaviour of other
;   library routines - in particular the handling of maths errors.
;
;   AMENDMENT HISTORY
;   ~~~~~~~~~~~~~~~~~
;   10 Mar 96   DJW   - First (and probably only) version.

    .text

    .globl  __CCX_option

    dc.b    "_CCX"
__CCX_option:
    dc.b    "c",0


