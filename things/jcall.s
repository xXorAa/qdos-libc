;******************************************************************************
;
; The function jcall sets up a C function as a dependant job.
; This Job can share the workspace of its parent.
;
; It returns the JOBID or 0 if the job fails. In this case, _oserr is set.
;
; The call parameters are:
;                            char *     function
;                            char *     job name
;                            long       priority
;                            long       data space
;                            long       number of parameters to pass
;                            .....      parameters passed to function.
;
;******************************************************************************

.globl _jcall

sms.myjb equ    -1
sms.crjb equ    $01
sms.frjb equ    $05
sms.acjb equ    $0a

jcb_a0   equ    $40
jcb_a7   equ    $5c
jcb_end  equ    $68

_jcall:

movem.l d2-d4/d7/a2/a3,-(sp)
stk_func equ    $1c
stk_jnam equ    $20
stk_prio equ    $24      
stk_data equ    $28
stk_npar equ    $2c      
stk_parm equ    $30

        move.l  stk_jnam(a7),a0          ; first we count that characters
        moveq   #-1,d4                   ; of the jobname 'cos C does not
jc_cntc:                                 ; know about strings
        addq.l  #1,d4
        tst.b   (a0)+
        bne     jc_cntc

        move.w  sr,d7
        move.l  a7,a3
        trap    #0                       ; atomic while we patch the jcb

        moveq   #sms.myjb,d1             ; create for me
        moveq   #11,d2                   ; header and round up
        add.l   d4,d2
        and.w   #$fffe,d2                ; asm bug in bclr
        move.l  stk_data(a3),d3          ; data space
        sub.l   a1,a1

        moveq   #sms.crjb,d0
        trap    #1
        move.l  d0,__oserr                ; error?
        blt     jc_njobu                 ; ... yes

        move.l  stk_func(a3),jcb_a0-jcb_end(a0) ; set Job's A0

        move.l  stk_npar(a3),d0
        lsl.l   #2,d0                    ; 4 bytes per parameter
        lea     stk_parm(a3,d0.l),a1     ; the parameters
        move.l  jcb_a7-jcb_end(a0),a2    ; and push bits onto the stack
        bra     jc_parme
jc_parml:
        move.l  -(a1),-(a2)              ; push parameter
jc_parme:
        subq.l  #4,d0
        bge     jc_parml

        move.l  a2,jcb_a7-jcb_end(a0)    ; set job's stack pointer

        lea     jc_header,a1

        move.l  (a1)+,(a0)+              ; header
        move.l  (a1)+,(a0)+
        move.w  d4,(a0)+                 ; job name

        move.l  stk_jnam(a3),a1
jc_cname:
        move.b  (a1)+,(a0)+
        bne     jc_cname

        move.w  d7,sr                    ; back to user mode

        moveq   #sms.acjb,d0             ; activate
        move.l  stk_prio(a7),d2
        moveq   #0,d3                    ; and do not wait
        trap    #1
        move.l  d0,__oserr
        bne     jc_njob

        move.l  d1,d0                    ; job id
jc_exit:
        movem.l (sp)+,d2-d4/d7/a2/a3
        rts
jc_njobu:
        move.w  d7,sr                    ; back to user mode
jc_njob:
        moveq   #0,d0
        bra     jc_exit


jc_header: jmp  jc_wrapper                ; jump to wrapper
        dc.w   $4afb


jc_wrapper:
        jsr     (a0)                     ; jsr to function
jc_die:
        moveq   #sms.frjb,d0
        moveq   #sms.myjb,d1
        moveq   #0,d3
        trap    #1                       ; then die

