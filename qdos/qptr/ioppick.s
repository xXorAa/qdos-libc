;   i o p p i c k
;
;   Copyright 1992, HaPeSu (Hans-Peter Sulzer)
;   may be included into the C68-compilation system
;   but MUST NOT be included into commercially sold libraries!!!
;
;   int ioppick(long job_id)
;
;   picks the given job to top
;
;   returns 0 or QDOS error code.
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;
;   06 Nov 93   DJW   - Added underscore to entry point name
;
;   20 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes


    .globl __ioppick

    .text

SAVEREG  equ 12+4           ; size of saved registers + return address

__ioppick:
    movem.l d3/a2/a3,-(a7)
    clr.l   d0                  ; mt.inf
    trap    #1
    move.l  d1,d0               ; save current job id
    move.l  0+SAVEREG(a7),d1    ; fetch job id
    cmpi.l  #-1,d1              ; if not own job as -1 given
    bne     other               ;   pick given job
    move.l d0,d1                ; else restore own job id
other:
    suba.l  a0,a0               ; SB-channel 0 is always open
    moveq.l #$7c,d0             ; iop.pick
    trap    #3
    movem.l (a7)+,d3/a2/a3
    rts


; /*
; picktest_c
;
; to test ioppick(long job_id)
; call with: EX'picktest';'job_id':REMark (job id is job_tag*65536+job_no)
; */
;
; #include <stdio.h>
; #include <qdos.h>
;
; int main(int argc,char *argv[]);
; int ioppick(long job_id);
;
; long job_id;
;
; int main(int argc,char *argv[]){
; int rorre;
; if (argc != 2)
;     return ERR_BP;
; job_id = 0L;
; sscanf(argv[1],"%lx",&job_id);
; if (job_id < -1L)
;     return ERR_OV;
; rorre = ioppick(job_id);
; ioppick(-1L);
; if (rorre)
;     printf("Job_id: %lx,  Error: %ld\n",job_id,rorre);
; return rorre;
; }

