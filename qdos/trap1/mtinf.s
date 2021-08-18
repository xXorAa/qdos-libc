;
;   m t _ i n f / s m s _ i n f o
;
; routine to get system info + job id, returns job id.
; Equivalent to C routine
;   jobid_t mt_inf( char **sys_vars, long ver_ascii)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   20 Jul 93   DJW   - Added SMS name as additional entry point
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even
    .globl __mt_inf
    .globl __sms_info

SAVEREG equ 4                   ; size of saved registers

__mt_inf:                         ; QDOS name
__sms_info:                       ; SMS name
    move.l  d2,-(a7)
    moveq.l #0,d0
    trap    #1
    move.l  4+SAVEREG(a7),a1
    move.l  a0,(a1)             ; system variables
    move.l  8+SAVEREG(a7),a1
    move.l  d2,(a1)             ; version number
    move.l  d1,d0               ; job id
    move.l  (a7)+,d2
    rts

