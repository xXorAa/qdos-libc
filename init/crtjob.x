;
;       c r t j o b
;
;   Code used within the C68 startup modules.
;
;   This piece does work that is only required for the
;   variants of the startup module that are used with
;   jobs.  It is invoked after program relocation has
;   taken place.
;
;   AMENDMENT HISTORY
;   ~~~~~~~~~~~~~~~~~
;   $Log$
;------------------------------------------------------------------------

SMS.ACHP    equ $18
SMS.FRJB    equ $05

    move.l  a7,__SPorig             ; Save the stack pointer

;========================================================================
;  Allocate Default stack
;  ~~~~~~~~~~~~~~~~~~~~~~
;   We ensure that we have at least 500 bytes of stack.
;   Other than this we simply take the users value.
;-------------------------------------------------------------------------
;

    moveq   #SMS.ACHP,d0
    moveq   #-1,d2          ; owner job (this one)
    move.l  __stack,d1      ; bytes required
    trap    #1
    tst.l   d0
    bne     ABORT
    move.l  a0,__SPbase     ; save result for later checking
    add.l   __stack,a0      ; set to end of stack
    move.l  a7,__SPorig     ; Save the original stack pointer
    move.l  a0,a7           ; Make this the stack for this C program

;=========================================================================
;  Clear Uninitialised variables area
;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  We must now ensure that the whole of the BSS area of the
;  program is zero as C programs are entitled to assume this.
;  We assume that the relocation information is to be zeroed.
;  (and any RLL info if present).
;  (The LD linker will have made this assumption).
;------------------------------------------------------------------------
;
    lea     ZERO_START,a0   ; start of area to clear
NEXTUDATA:
    cmpa.l  __SPorig,a0     ; reached bottom of stack?
    beq     ENDUDATA        ; ... YES, then we are finished
    clr.w   (a0)+
    bra     NEXTUDATA
ENDUDATA:

;=======================================================================
;  Complete Programmers Environment
;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  Finish setting up the program enviroment at the C level in 
;  preperation for passing controlto the users 'main' module.
;
;  This involves:
;      a)  Set up System Variables pointer for later use
;      b)  Set uf flag if QJUMP Pointer Environment loaded
;      c)  Set up program name at start of job
;      d)  Setting up the Environment variables
;      e)  Completeing parsing of the command line to build up
;          the parameter vectors for the suer program.
;      f)  Setting up the standard C channels 'stdin', 'stdout'
;          and 'stderr'
;      g)  Setting up semaphores (currently this is really a dummy)
;-------------------------------------------------------------------
;
    moveq   #MT.INF,d0      ; System and job information
    trap    #1              ; ... do it
    move.l  d1,__Jobid      ; save Job Id
    move.l  a0,__sys_var

;   Copy across program name

    pea     __prog_name             ; Get program name
    pea     PROGNAME(pc)            ; ... and where to put it
    jsr     __cstr_to_ql            ; move name as a QL string
    addq.l  #8,a7                   ; tidy up stack
;
;======================================================================
;  Start up user code
;  ~~~~~~~~~~~~~~~~~~
;  Finally it is time to call the user program !
;
;  If we get control back, then this means that the user left main()
;  via a return rather than an exit() call, so we need to do this
;  ourselves (remembering to keep the users error code).
;
;  Note that since the user code is accessed via a vector it is
;  relatively easy to provide alternative initialisation code and
;  ways of starting the user code if so required.
;----------------------------------------------------------------------
;
    pea     UDATA_START     ; pass across standard variables vector
    move.l  ARGV,-(a7)      ; argument vectors
    move.l  ARGC,-(a7)      ; argument count
    move.l  __Cstart,a0     ; get start vector required
    jsr     (a0)            ; ======= call next level =========
;
;   If the user did not call exit() explicitly,
;   thus we try and do some tidying up

    move.l  d0,-(a7)        ; set return code
    jsr     _exit           ; ... and call exit routine

;   Now it is time to abort the program regardless.

ABORT:
    moveq   #-1,d1          ; this job
    move.l  d0,d3           ; set error code to return from d0
    moveq   #SMS.FRJB,d0    ; Force remove job
    trap    #1              ; ... and do it
    bra     ABORT           ; ... should not return but jsut in case

