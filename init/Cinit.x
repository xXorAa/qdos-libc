#
;
;           C i n i t
;
;   Code to control setting up the C environment for a C68 compiled
;   program.   It is called from the CRT_O startup module unless
;   this has been explicitly suppressed.
;
;   Equivalent to C routine:
;       void    _Cstart (int argc, char * argv[], struct _StdVars *)
;
;   where argc is always 2, argv[0] points to program name, and
;   argv[1] points to stack on entry.
;
;   A maximum of 100 bytes is allowed to be used on the stack before
;   the new stack is allocated, or corruption of UDATA area will occur.
;
;  Amendment History
;  ~~~~~~~~~~~~~~~~~
;  01 Jul 92  EJ - Ensured that command line length rounded to even number
;
;  24 Sep 92 DJW - Added _NDP and _SLASH global variables
;                  (required for future developments)
;                - Made change to allow 'whitespace' to occur between a command
;                  line re-direction symbol and the associated filename
;                - Allowed stderr to be re-directed in isolation from stdin
;                  (the next level always allowed this - but this level did not!)
;
;  14 Jun 93 DJW - Added option to generate a version of the start up code
;                  that is suitable for writing Device Drivers or other code
;                  that is loaded via RESPR.  Does not set up the full C
;                  environment
;
;  31 Jan 94 DJW  - Added some new variables for use with signal handling
;    (v4.13)
;
;  04 Apr 94 DJW  - Added link to pull in default signal handling table
;                   and code.
;
;  10 Jun 94 DJW  - Changed parameter parsing code to correct error whereby
;    (v4.14)        any parameter starting with '1' had the '1' removed.
;                   This problem was reported by David Gilham.
;
;  03 Sep 94 DJW  - Added the -DMINIMUM option to allow for the generation 
;                   of a startup module that has abosult minimal support.
;                   This will allow C68 to be used as a super assembler.
;                 - Removed definition of global variables that are not
;                   directly referenced into their own separate files.
;                 - Corrected problem with switching cache back on for 68030s
;                   (Problem reported by PROGS).
;                 - Moved uninitialised variables into BSS section to reduce
;                   program size.  Changed point at which zeroing starts to
;                   compensate for this.
;                 - Reordered code to move subroutines used by command parsing
;                   routine to be local to that routine.  This slightly
;                   reduces code size.
;                 - Changed program initialisation calls to make use of new
;                   code base on using argunpack() routine.
;                 - Added '_Jobid' to list of variables defined here, and added
;                   code to initialise it.
;
;  01 Oct 94 DJW  - The _Cstart module derived be splitting up the
;                   original CRT_X source module into the part that
;                   has to be present for all startup modes, and the
;                   remainder which is specific to setting up the C
;                   environment moved to this module.  This module
;                   is called unless the _Cstartup vector is set to
;                   NULL in the user program.   This removed the need
;                   for the MINIMUM conditional assembly option.
;                 - Kept past history that is relevant to this part
;                   of the source in this module, removed others.
;
;  18 Dec 95 DJW  - Move signal initialisation to before setting up
;                   environment variables.  Needed in case a signal
;                   is received during initialisation.
;
;  30 Aug 98 DJW  - Fixed problem with maximum length of a name passed
;                   in the command line.  Changed to take size from the
;                   limits.h file rather than hard coding it.
;                   (problem reported by David Gilham).
;-----------------------------------------------------------------------

#include <limits.h>

    .text    

MT.FRJOB equ    $05
MT.FREE  equ    $06
MT.SUSJB equ    $08
MT.ALCHP equ    $18
SMS.RCHP equ    $19


MEM.ACHP equ    $c0             ; Allocate Common Heap vector
MEM.RCHP equ    $c2             ; Release Common heap vector

TAB     equ     $9                  ; tab character
NEWLINE equ     $A                  ; newline
SPACE   equ     $20                 ; space character
DQUOTE  equ     $22                 ; Double quote
PERCENT equ     $25                 ; Percent character
AMPSND  equ     $26                 ; Ampersand character
SQUOTE  equ     $27                 ; Single quote
EQUALS  equ     $3d                 ; Equals character
ONE     equ     $31                 ; 1 character
TWO     equ     $32                 ; 2 character
LESS    equ     $3c                 ; < character
GREATER equ     $3e                 ; > character

ERR_BP  equ     -15                 ; bad parameter

MIN_MEM equ     $800                ; 2k default memory allocation
MIN_STK equ     $400                ; 1k minimum stack

;
;       Enter here with address of base page on stack above return address.
;
.globl  __Cinit

__Cinit:

;   Initialize signals

    move.l  __SigStart,d0           ; Is vector address present ?
    beq     NOSIGS                  ; ... NO, jump over initialisation attempt
    move.l  d0,a0                   ; ... YES, get address
    jsr     (a0)                    ; go to call vector
NOSIGS:


;=====================================================================
;  Deal with any channels open for the job
;
;  Basically all we are doing at this stage is skipping over the
;  channels (if any) so that we can get at the remainder of the
;  command line.
;----------------------------------------------------------------------

    move.l  8(sp),a5        ; get ARGV vector
    move.l  4(a5),a5        ; get original SP
    move.w  (a5)+,d0        ; Get the number of channels open in bottom bits
    and.w   #$7FFF,d0       ; Ensure +ve
    asl.w   #2,d0           ; Multiply no. of channels by channel len 4
    add.w   d0,a5           ; Move pointer past stacked channels
    lea     CL,a3
    move.l  a5,(a3)         ; save value command line for later
    move.w  (a5),d0         ; length of command line                           EJ
    addq.w  #3,d0           ; ... plus count field length + 1 for odd values   EJ
    bclr    #0,d0           ; ... enusre even                                  EJ
    add.w   d0,a5           ; now a5 points to environment area                EJ
    move.l  a5,ENV          ; save answer

;===========================================================================
;  Parse Command Line )if any)
;  ~~~~~~~~~~~~~~~~~~
;   We now parse the command line for special characters
;      =   Introduces stack size setting
;      %   Introduces heap size setting
;      <   Introduces input re-direction
;      >   Introduces output re-direction
;      >&  Introduces output & error re-direction
;      ''  Start-end of a string (treated as a single element)
;      ""  Start-end of a string (treated as a single element)
;  At this stage we replace any command line fields we use up with space
;  characters.   This will simplify things later when we build up a vector
;  of elements that will be  passed as parameters to the users 'main' module.
;
;  a5 is running pointer to command line point being parsed
;----------------------------------------------------------------------------


    clr.w   __iname         ; ensure that names are cleared
    clr.w   __oname         ; N.B.  This cannot be done in BSS clear as
    clr.w   __ename         ;       this occurs later in this module

    move.l  (a3),a5         ; get command line start
    tst.w   (a5)            ; Is command line length zero?
    beq     ENDCOM          ; ... YES, skip command line parsing
    move.l  a5,-(a7)        ; Stack parameters for call
    move.l  a5,-(a7)        ; ... overwriting existing string
    jsr     _qlstr_to_c     ; ... convert to a C style string
    addq.l  #8,a7           ; tidy up stack
    bra     ENDLOOP         ; Check for end of line

SCAN:
    bsr     WHILESPACE
    cmpi.b  #LESS,(a5)      ; start of input file name?
    bne     NT1             ; No
    lea     __iname,a1

;   put the names into the designated area

INP_NAM:
    move.b  #$20,(a5)+              ; store space and get past "<" or ">"
    moveq   #MAXNAMELEN-1,d1        ; set size of name field
    bsr     WHILESPACE              ; Go past any white space
INP02:
    bsr     WHITESPACE_OR_END       ; end of field ?
    beq     INOUT
    move.b  (a5)+,(a1)+             ; move across a character
    move.b  #$20,-1(a5)             ; space fill character taken
    move.b  #0,(a1)                 ; ensure NULL terminated string
    cmp.b   #GREATER,-1(a1)
    beq     INP03
    cmp.b   #AMPSND,-1(a1)
    bne     INP04
INP03:
    bsr     WHILESPACE             ; Skip past any space before filename
INP04:
    dbf     d1,INP02
INOUT:
    bra     ENDLOOP

; Subroutine to go past any white space ( moving a5).

WHILESPACE:
    bsr     WHITESPACE_CHAR
    bne     WHILESPACE_END
    move.b  #$20,(a5)+          ; ensure that character was really space and move on
    bra     WHILESPACE
WHILESPACE_END:
    rts

; Subroutine to go past any non white space (moving a5)

WHILEWORD:
    bsr     WHITESPACE_OR_END
    beq     WHILEWORD_END
    add.l   #1,a5
    bra     WHILEWORD
WHILEWORD_END:
    rts

; Subroutine to go from one quote (single or double) to another (moving a5)

PAST_QUOTE:
    move.b  (a5)+,d6    ; Get either single or double quote
PLOOP:
    cmp.b   (a5),d6     ; Have we found another ?
    beq     POUT        ; yes - return after incrementing a5
    cmp.b   #0,(a5)     ; are we at end of text ?
    beq     DPOUT       ; yes - return - do not increment a5
    addq.l  #1,a5
    bra     PLOOP
POUT:
    addq.l  #1,a5
DPOUT:
    rts

;   Simple Check subroutines for whitespace character - sets condition codes

WHITESPACE_OR_END:
    cmp.b   #0,(a5)                 ; NULL = end of field ?
    beq     WH_END                  ; ... YES, jump
WHITESPACE_CHAR:
    cmp.b   #SPACE,(a5)             ; SPACE = end of field?
    beq     WH_END                  ; ... YES, jump
    cmp.b   #TAB,(a5)               ; TAB = end of field ?
WH_END:
    rts


NT1:
    cmpi.b  #ONE,(a5)       ; start of output file redirection?
    bne     NT1C
    cmpi.b  #GREATER,1(a5)  ; next character is greater than?
    bne     NTS1            ; ... NO, then cannot be redirection
    move.b  #$20,(a5)+      ; change 1 to space
NT1C:
    cmpi.b  #GREATER,(a5)   ; start of output file name?
    bne     NTS1
    lea     __oname,a1
    bra     INP_NAM

NTS1:
    cmpi.b  #TWO,(a5)       ; Could this be start of stderr redirect ?
    bne     NTS2
    cmpi.b  #GREATER,1(a5)
    bne     NTS2
    move.b  #$20,(a5)+      ; skip over '2' character
ERR_NAM:
    lea     __ename,a1
    bra     INP_NAM         ; Go and get error channel name

NTS2:
    cmpi.b  #AMPSND,(a5)    ; alternative stderr re-direct starting with ampersand
    bne     NT2
    bra     ERR_NAM

NT2:
    cmpi.b  #EQUALS,(a5)    ; stack size specification?
    bne     NT3

; N.B.  The user is not allowed to reduce stack
;       below value specified in __stack

    bsr     GETNUM              ; Returns number in d0
    tst.l   d0
    beq     ERROR               ; No stack !!
    cmp.l   #MIN_STK,d0         ; Less than minimu allowed ?
    bgt     STK_10              ; ... NO, so jump
    move.l  #MIN_STK,d0         ; ... YES, rest to minimum
STK_10:
    cmp.l   __stack,d0          ; less than programmers minimum ?
    bmi     ENDLOOP            ; ... YES, cannot override.
    move.l  d0,__stack          ; set stack size
    bra     ENDLOOP

; Subroutine to return a number in d0
; while getting number, replace text with spaces
; Having got a number any following whitespace is skipped
; update a5 as number taken

GETNUM:
    move.b  #$20,(a5)+          ; change to space and move past '=' or '%'
    moveq   #0,d0               ; clear accumulator
GET_02:
    moveq   #0,d1
    move.b  0(a5),d1            ; get digit
    cmp.w   #$39,d1             ; check for numeric
    bgt     END_GET
    sub.w   #$30,d1
    blt     END_GET
    asl.l   #1,d0               ; x2
    move.l  d0,d7               ; Use d7 as temporary storeage
    asl.l   #2,d0               ; x8
    add.l   d7,d0               ; x10
    add.l   d1,d0               ; add in new digit
    move.b  #$20,(a5)+          ; change old digit to space and move to next digit
    bra     GET_02
END_GET:
    rts

ERROR:
    moveq   #ERR_BP,d0              ; set "bad parameter"
    bra     __ABANDON            ; exit

NT3:
    cmpi.b  #PERCENT,(a5)   ; workspace specification ?
    bne     NT4

; N.B.  The user is not allowed to reduce heap
;       below value specified in _mneed

    bsr     GETNUM              ; Returns number in d0
    tst.l   d0
    beq     ERROR
    cmp.l   __mneed, d0         ; less than programmers minimum ?
    bmi     ENDLOOP             ; ... YES, cannot override
    move.l  d0,__mneed          ; Set memory allocate size
    bra     ENDLOOP

NT4:
    cmpi.b  #SQUOTE,(a5)    ; Single quote
    bne     NT5
    bsr     PAST_QUOTE
    bra     ENDLOOP
NT5:
    cmpi.b  #DQUOTE,(a5)    ; Double quote
    bne     NT6
    bsr     PAST_QUOTE
    bra     ENDLOOP
NT6:
    bsr     WHILEWORD       ; Get past a non white space

ENDLOOP:
    cmpi.b  #0,(a5)
    bne     SCAN

ENDCOM:

;========================================================================
;  Decide dynamic memory requirements
;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  we have finished parsing the command line.
;  We now need to calulate our dynamic memory requirements.
;  Sanity checks are also done in case the user has
;  supplied non-sensical values.   Also, we cannot exceed
;  the actual memory free in the machine.
;------------------------------------------------------------------------

    moveq   #MT.FREE,d0
    nop                     ; stops TASKMASTER patching code
    trap    #1              ; QDOS call to find maximum free space
    move.l  __stack,d2      ; get stack setting
    sub.l   d2,d1           ; Reduce free space value by this
    move.l  __mneed,d3      ; See what memory was asked for
    bmi     NASK            ; Negative amount - subtract it from total memory
    bne     PASK            ; Positive amount - this is amount we will have
    sub.l   __memqdos,d1    ; Zero asked for - memory is TOTAL - _MEMQDOS
    bra     MEM2

NASK:
    add.l   d3,d1           ; __mneed is negative here - so add it 
    bra     MEM2

PASK:
    move.l  d3,d1           ; __mneed is OK, take value

MEM2:
    cmp.l   #MIN_MEM,d1     ; make sure we get at least the minimum
    bgt     MEM1
    move.l  #MIN_MEM,d1     ; set minimum memory size
MEM1:
    add.l   d2,d1           ; add in stack requirements
    addq.l  #8,d1           ; ... plus enough for one linkage area
    bclr.l  #0,d1           ; Make code space even
    move.l  d1,d7           ; Save space needed in d7

;
;========================================================================
;  Allocate Dynamic memory (including stack)
;  ~~~~~~~~~~~~~~~~~~~~~~~
;  It is time to set up our initial data area
;  The following code acts as follows:
;      a)  Allocate stack + data as a single area
;      b)  Release the area allocated
;      c)  Allocate the data area
;      d)  Allocate the stack area
;      e)  deallocate the data area
;  This apparently convoluted process is to get the stack to the
;  end of the initial data area.   This means that if the stack
;  outgrows its allocated space is will corrupt this programs data
;  area before other items on the common heap.   This MAY stop 
;  QDOS from crashing if we are very lucky!
;-------------------------------------------------------------------------
;

    move.l  d7,-(a7)        ; Set size required
    jsr     _lsbrk          ; allocate area
    addq.l  #4,a7           ; tidy up stack
    tst.l   d0              ; OK ?
    beq     __ABANDON       ; ... NO, so give up

    move.l  d0,a3           ; start address of area
    move.l  (a3),-(a7)      ; actual size of area allocated
    move.l  d0,-(a7)        ; address of area allocated
    jsr     _rlsml          ; Release area
    addq.l  #8,a7           ; tidy up stack

    move.l  d7,d6           ; original total size wanted
    sub.l   __stack,d6      ; ... less stack space
    move.l  d6,-(a7)        ; set it on stack
    jsr     _lsbrk          ; Allocate DATA space
    addq.l  #4,a7           ; tidy up stack

    move.l  d0,a3           ; save result to deallocate later
    move.l  __stack,-(a7)   ; stack space required
    jsr     _lsbrk          ; Allocate stack space
    addq.l  #4,a7           ; tidy up stack

    move.l  d0,a1           ; start address of area
    move.l  (a1),a1         ; ...actual size allocated
    lea.l   0(a1,d0.l),a7   ; Set up the stack for this C program (use actual space)
    lea     __SPbase,a1
    move.l  (a1),a0         ; get previous stack base
    move.l  d0,(a1)         ; save new stack base result for later checking
    moveq   #SMS.RCHP,d0    ; Call to release previous tack
    trap    #1              ; ... do it

    move.l  d6,-(a7)        ; size of DATA area
    move.l  a3,-(a7)        ; start of DATA area - use value saved earlier
    jsr     _rlsml          ; release it
    addq.l  #8,a7           ; tidy up stack


;=======================================================================
;  Complete Programmers Environment
;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  Finish setting up the program enviroment at the C level in 
;  preperation for passing controlto the users 'main' module.
;
;  This involves:
;      a)  Initialise Signal handling system if required
;      b)  Set uf flag if QJUMP Pointer Environment loaded
;      c)  Set up program name at start of job
;      d)  Setting up the Environment variables
;      e)  Completing parsing of the command line to build up
;          the parameter vectors for the suer program.
;      f)  Setting up the standard C channels 'stdin', 'stdout'
;          and 'stderr'
;      g)  Setting up semaphores (currently this is really a dummy)
;-------------------------------------------------------------------

;   Set up environment

    move.l  ENV,-(a7)                   ; set stack environment pointer
    jsr     __envsetup                  ; set up environment
    addq.l  #4,a7                       ; tidy up stack

;   Set up initial argv vector with program name
;   We deliberately avoid using the argunpack() routine
;   at this stage so that it is not always brought in
;   even when the programmer has specified no command
;   line processing is to be done.  We can also assume
;   that the memory allocations will not fail at this
;   stage as there must be enough to get this far.


    pea     8                           ; size required
    jsr     _malloc                     ; Set up initial argument vector
    addq.l  #4,a7                       ; tidy up stack
    move.l  d0,ARGV                     ; Store result

    pea     __prog_name                 ; String to copy
    jsr     _strdup                     ; copy string
    addq.l  #4,a7                       ; tidy stack
    move.l  ARGV,a0                     ; get address of ARGV vector
    move.l  d0,(a0)+                    ; store program name copy in first entry
    clr.l   (a0)                        ; ensure second entry NULL.
    move.l  #1,d0                       ; set number of arguments
    move.l  d0,ARGC                     ; and that argument count set correctly

;   Parse command line parameters

    move.l  __cmdparams,d0              ; Command line parameters wanted ?
    beq     NO_PARAMS                   ; Jump if no parameters
    move.l  __cmdwildcard,-(a7)         ; Wild card function
    pea     ARGC                        ; Address of argument count
    pea     ARGV                        ; Address of argument vector pointer
    move.l  CL,-(a7)                    ; Command line to parse
    move.l  d0,a0                       ; Get parsing routine address
    jsr     (a0)                        ; ... and call it
    lea     16(a7),a7                   ; tidy up stack

;   Set up stdin, stdout and stderr

NO_PARAMS:
    jsr     __stdchans

#if 0
;   Set up semaphores

    move.l  __nsems,d0
    bne     NOSEMS
    jsr     _initsems

NOSEMS:
#endif

;
;======================================================================
;  Start up user code
;  ~~~~~~~~~~~~~~~~~~
;  Finally it is time to call the user program !
;
;  If we get control back, then this means that the user left main()
;  via a return rather than an exit() call, so we need to do this
;  ourselves (remembering to keep the users error code)
;----------------------------------------------------------------------
;

    move.l  __environ,-(a7) ; environment vectors
    move.l  ARGV,-(a7)      ; argument vectors
    move.l  ARGC,-(a7)      ; argument count
    jsr     _main           ; ======= Call user program =========
    lea     12(a7),a7       ; tidy up stack

    move.l  d0,-(a7)        ; set return code
    jsr     _exit           ; ... and call exit routine
    addq.l  #4,a7           ; we should not get back, but just in case!

    .globl  __ABANDON
__ABANDON:
    moveq   #-1,d1          ; this job
    move.l  d0,d3           ; set error code to return from d0
    moveq   #MT.FRJOB,d0    ; Force remove job
    trap    #1              ; ... and do it
    bra     __ABANDON       ; ... should not return but jsut in case


;========================================================================
;           U n i n i t i a l i s e d    D a t a    A r e a s
;-----------------------------------------------------------------------

    .bss

CL:                        ; Pointer to command line (if any) on program entry
    .space  4

ENV:                       ; Pointer to Environment on stack (if any) on program entry
    .space  4

ARGC:
    .space  4

ARGV:
    .space  4
