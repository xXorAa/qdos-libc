;
;   m t _ c j o b / s m s _ c r j b
;
; routine to create a qdos job
; equals C routine
;
;   jobid_t mt_cjob( long codespace, long dataspace, char *startadd, 
;                   jobid_t owner,   char **jobadd)
;
; returns job id or negative error number
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   10 Jul 93   DJW     Removed setting of _oserr - merely return error code
;                       if an error occurs.
;   20 Jul 93   DJW   - Added SMS name as additional entry point
;                     - Removed link/ulnk instruction by making all
;                       parameter access relative to a7
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even
    .globl __mt_cjob
    .globl __sms_crjb

SAVEREG equ 8                   ; size of saved registers

__mt_cjob:                        ; QDOS name
__sms_crjb:                       ; SMS name
    movem.l d2/d3,-(a7)
    moveq.l #1,d0               ; byte code for create
    move.l  16+SAVEREG(a7),d1   ; owner
    move.l  4+SAVEREG(a7),d2    ; code space
    move.l  8+SAVEREG(a7),d3    ; data space
    move.l  12+SAVEREG(a7),a1   ; start address
    trap    #1
    tst.l   d0                  ; OK ?
    bne     err                 ; ... NO, exit with error code
    move.l  20+SAVEREG(a7),a1   ; address of pointer
    move.l  a0,(a1)             ; store new job address
    move.l  d1,d0               ; new job id
err:
    movem.l (a7)+,d2/d3
    rts

