;
;           p r o c t y p e
;
;  This routine is used to detect the processor type.
;
;  Support routine used internally by various of the C68 startup modules.
;  Can also be called explicitly by user code if so required.
;
;  Strictly speaking we may not need to do this for the processor type,
;  as there is now a system variable at $a1(SV.BASE) that may already have
;  been set up to handle this.   If this has been set non-zero, then we
;  will skip over the processor detection code.  We will also store the
;  result internally for even faster checks after having found the
;  answer previously.
;
;  *** The FPU checking is now not done here - FPSAVE used instead ***
;  As a slight optimisation, we do not try to make any further checks
;  for hardware FPU if this system has a chip that does not use a VBR
;  to point to exception vectors (i.e. a 68008 or 68000).  We also do
;  not check for a FPU if a Gold Card is fitted as hardware deficiencies
;  in handling of unimplemented instructions stop the checks working.
;
;  If the processor is determined to be a 68020 or better, then a check
;  is made for the string identifying a Miracle Super Gold Card as then
;  no further checks must be made due to hardware deficiencies of the SGC.
;
;  When the processor type is determined, the results are stored
;  into the system variables at offset $a1.
;
;  The Processor type value is encoded as a byte field and put into the 
;  system variable at $a1(SV.BASE).  This byte is encode as follows:
;
;  Bit 0       0 = No MMU present
;              1 = 68851 MMU (or equivalent) found
;  Bits 2-3    0 = No FPU
;              1 = 68881 (or equivalent) found
;              2 = 68882 (or equivalent) found
;  Bits 4-7    0 = 68008 or 68000
;              1 = 68010
;              2 = 68020
;              3 = 68030
;              4 = 68040
;
;  It has been found that a number of programmers have assumed that bits
;  0-3 are zero, so the information about the FPU unit is now stored in
;  the new system variable at $d0(SV.BASE).  This byte is encoded as
;  follows:
;
;       0    No FPU present
;       1    68881 (or equivalent) found
;       2    68882 (or equivalent) found
;       4    68040, core instructions only
;       5    68040  + FPSP  (Floating Point Software Package)
;       6    68060, core instructions only
;       7    68060  + FPSP
;
;  N.B.    Some of the instructions have had to be entered as their
;          resulting bit pattern due to limitations of the AS68 assembler.
;          In these cases the instruction mneumonic follows as a comment.
;
;   Register useage from this point, up to the relocation code are:
;       D7      Results of detection code so far
;       D4      Address of old VBR
;       A4      Address of new VBR (and therefore memory allocated)
;       A5      Saved A7 supervisor mode (to restore after exception vectors)
;       A6      Address of System Variables  (preserved)
;
;  AMENDMENT HISTORY
;  ~~~~~~~~~~~~~~~~~
;  10 Nov 93 DJW  - Made improvements to code for recognising chip details
;
;  12 Mar 94 DJW  - Changed start-up processor detection code to allow for
;                   the Super Gold card having its vectors in ROM.
;
;  19 Mar 94 DJW  - Further changes to processor detection code (using ideas
;                   contributed by Andreas Rudolf).  This new version is more
;                   forward compatible as whenever possible it relocates the
;                   exception vectors via the VBR to ensure they are in RAM.
;                   Also, the information is now encoded according to the
;                   QDOS standard for the system variable (at offset $A1) so
;                   that it is no longer necessary to store it internally.
;
;  16 Apr 94 DJW  - Changes to processor detection code to allow for fact that
;                   some systems (Super Gold Card in particular) can take the
;                   Co-Processor Protocol Violation exception vector when it
;                   had been assumed that the Line-F one would be taken.  This
;                   does NOT, however, fix the screen corruption that can
;                   occur at the same time.
;
;  10 Oct 94 DJW  - The code for detecting processor code put into its own
;                   file as part of the re-organisation of the C68 start-up
;                   code and the commoning up of code with the RLM.
;                 - Comments from original crt_x file that related to
;                   processor detection retained in this file.
;
;  20 Sep 95 SNG  - Faster test for 68020+
;                 - Numerous typos in comments fixed
;
;  22 Feb 97 DJW  - Commente out checks for FPU and MMU.
;                   If you are going to use either of these you should 
;                   load the FP_SAVE code from George Gwilt which will 
;                   set up the  appropriate system variables.  Avoids 
;                   every C68 program having to do this.
;
;  16 May 98 DJW  - Entry point renamed to __ProcessorType to make visible
;                   from C, and then made globally visible.
;                 - Need to be in Supervisor mode on entry removed.
;                 - Need for A6 to be set on entry removed
;                 - Returns processor type in D0 (all other registers preserved)
;
;  14 Jul 98 DJW  - Fixed bug where registers saved and restored did not match.
;                 - Used local variable for faster checkign of whether the
;                   processor type is already known.
;                 - Use the __super() and __superend() routines to enter/exit
;                   Supervisor mode as these will correctly handle being called
;                   while already in Supervisor mode.
;
; BUGS REMAINING:
;
; - Thinks 68060 is a 68040; should check PCR and tweak flags accordingly.
;
;----------------------------------------------------------------------------

    .text    

MMU       equ   $01                 ; => 68851 (or equivalent) MMU

IS881     equ   $04                 ; => 68881 (or equivalent) FPU
IS882     equ   $08                 ; => 68882 (or equivalent) FPU

IS000     equ   $00                 ; => 68000
IS010     equ   $10                 ; => 68010
IS020     equ   $20                 ; => 68020
IS030     equ   $30                 ; => 68030
IS040     equ   $40                 ; => 68040

ILLVEC    equ   $10                 ; Illegal instruction vector
LINEF     equ   $2c                 ; Line F vector
COPROC    equ   $34                 ; CoProcessor Protocol Violation

SMS.INFO  equ   $0              ; TRAP #1 - System Information

MEM.ACHP equ    $c0             ; Allocate Common Heap vector
MEM.RCHP equ    $c2             ; Release Common heap vector

SYS_PTYP equ    $a1             ; Processor type offset in system variables

    .globl  __ProcessorType

CPUTYPE:
    dc.b    -1              ; CPU type stored locally for fast checking

    .even

__ProcessorType:

;   If the processor type information is already known, then
;   there is not much point in trying to determine it again.
;   We can therefore skip all this magic mumbo jumbo

    moveq   #0,d0               ; Clear d0
    move.b  CPUTYPE(pc),d0      ; get CPU type into top byte
    bpl     PROCTYPE_RTS        ; ... if known exit immediately
    movem.l d4/d5/d7/a2/a4/a5/a6,-(sp); Save registers we might corrupt
    moveq   #SMS.INFO,d0        ; Set trap required
    trap    #1                  ; Read system info
    move.b  SYS_PTYP(a0),d0     ; System Variable already set ?
    bne     PROCTYPE_EXIT       ; ... YES, then details already known

;   The processor type is not known so we have to find out what it is

    move.l  a0,a6               ; Save System variables start address
    bsr     __super             ; Enter Supervisor mode
    move.l  a7,a5               ; save a7 for convenience later
    ori.w   #$0700,sr           ; disable all interupts

;   Check for 68020 or better.
;   We did this by realizing that the processors before the
;   68020 ignored any scaling bits in an instruction.
;   Updated by SNG to use faster and shorter MOVEM technique.
;
;   moveq   #1,d0               ; Set index register
;   lea     cputable(pc),a0     ; A0 -> table
;   dc.l    $1e300C00
;   MOVE.B  0(A0,D0.L*4),D7     ; get return value (0 for 68008/68000/68010)

    movem.l a7,-(a7)            ; See if the pre-decrement is pipelined?
    cmp.l   (a7)+,a7
    bne     GOT_020             ; It is an 020 or better
    move.b  #IS000,d7           ; Set to standard 68000

;   We only have a 68008, 68000 or 68010
;   if we get to this point.  We treat the
;   68008 and 68000 both as if they were the
;   68000 as they are completely code compatible

    lea     ILLVEC,a2           ; set A2 to point to vector we will change
    move.l  (a2),d5             ; save old vector value
    lea     GOT_000(pc),a0      ; A0 -> Trap handler
    move.l  a0,(a2)             ; Set new vector
    cmpa.l  (a2),a0             ; did we change it ?
    bne     PROCTYPE_END        ; ... NO, then it is ROM - assume only 68000
                                ; we cannot check for MMU and FPU,
    dc.w    $42c0           
;   MOVE    CCR,D0              ; see if 010 (illegal on 68008/68000)

;   If we got here it is a 68010

    moveq   #IS010,d7           ; it is an 010
GOT_000:
    move.l  a5,a7               ; restore stack from a6
    move.l  d5,(a2)             ; restore vector
    tst.l   d7                  ; was it a 68010 ?
    beq     PROCTYPE_END        ; ... NO, then we are finished

    bsr     SETUP_NEW_VBR       ; set VBR etc
    bra     GO_FPU              ; ... go for FPU type (indirectly)

;   Table used in distinguishing between processors below
;   68020 and those that are 68020 or better. Redundant - SNG
;
; cputable:   ; CPU value table 
;   dc.l      0
;   dc.b      IS020,0,0,0
;
;   This routine is used to set up a new VBR.  It does the following tasks:
;       a)  Allocate memory for the new VBR
;       b)  Save the old VBR value into d4
;       c)  Copy the old vectors into the allocated memory
;       d)  Set the VBR to point to this value

;   It allocates memory, and makes a copy of the current vector table
;   to the address in a4.  The VBR is then changed to use this
;   new table.  On exit, a2 is set to the new LINE_F address.
;   (and d1, a0 and a1 are corrupted)

SETUP_NEW_VBR:
    dc.l    $4e7a4801
;   MOVEC   VBR,D4              ; current vector base register -> d4

;   Allocate memory to hold vector tables
;   (N.B. Must release it before we leave supervisor mode)

    move.w  MEM.ACHP,a0         ; Allocate common heap memory vector
    moveq   #65,d1              ; We want 1024+16 - get by 65 * 16 which
    lsl.l   #6,d1               ;    saves 2 bytes over simple move of constant
    jsr     (a0)                ; do it
    lea     16(a0),a4           ; Go past header and store in a4

    move.w  #$FF,d1            ; count of entries in VBR - 1
    move.l  d4,a0               ; old VBR address as source
    move.l  a4,a1               ; new VBR address as target
COPY_LOOP:
    move.l  (a0)+,(a1)+         ; move one entry
    dbra    d1,COPY_LOOP        ; ... go for next

    dc.l    $4e7BC801
;   MOVEC   A4,VBR              ; a4 -> vector base register
    rts

;   If we get here, then we have at least a 68020
;   Set up LINE-F vector for 68020 or better CPU

GOT_020:

;   These next few lines are to handle problems with the Super Gold Card
;   on which issuing the LINE-F instructions can have undesirable side
;   effects due to hardware limitations.   Future releases of the Super
;   Gold Card will set the system variable so that this point will not
;   be reached, but this caters for all those already shipped.

    move.b  #IS020,d7           ; set as 68020
    cmpi.l  #$476f6c64,$1000a   ; Check for 'Gold' at this address
    beq     GOT_SGC

    bsr     SETUP_NEW_VBR      ; Go to set up the VBR

;   For a 68040/60, we need to invalidate the caches.  As a
;   by-product if this works we know that we have a 68040/60!

    lea     NOT_040(pc),a0
    bsr     SET_VECTORS
    dc.w    $f4f8               
;   CPUSHA  BC                  ;  68040: flush and invalidate caches
    move.b  #IS040,d7           ;  ... it is an 68040

*   Now we can find out if the 68040 has a MMU
*   (i.e. it is a full 68040 or a 68LC040 rather than a 68EC040)

*    lea     FPUTYPE(pc),a0      ; set vector again
*    bsr     SET_VECTORS
*    dc.w    $f518
*;   PFLUSHA
*    addq.b  #MMU,d7
GO_FPU:
    bra     FPUTYPE

;   This routine does the following:
;       a)  Stores the address in a0 in the LINE-F exception vector
;       b)  Stores the address in a0 in the Co-Processor violation vector
;           This one is needed for systems (such as Super Gold Card) which
;           take this vector rather than the LINE-F one (due to hardware
;           limitations) when they do not recognise LINE-F instructions
;       c)  Tidies up the supervisor stack if there is any information
;           left from earlier exceptions.

SET_VECTORS:
    move.l  a0,LINEF(a4)        ; Set LINE-F vector
    move.l  a0,COPROC(a4)       ; Set Co-Processor vector
    move.l  (a7)+,a0            ; get return address
    move.l  a5,a7               ; ensure stack is tidy
    jmp     (a0)                ; return

;   We next decide if it is a 68030 or 68020+68551
;   If not, then the 68020/68040 is already set up.

NOT_040:
    lea     FPUTYPE(pc),a0      ; set vector
    bsr     SET_VECTORS
    dc.l    $f0002400
;   PFLUSHA                     ; flush MMU - 68030 or 68020+68851

;   If we got here we definitely have either
;   a 68030, or a 68020+68851.
;   In both cases we have a MMU, so flag that anyway

*    ori.b   #MMU,d7             ; set MMU flag
    lea     GOT_030(pc),a0      ; set another vector
    bsr     SET_VECTORS
    dc.w    0xf127           
;   PSAVE   -(a7)               ; only for 68851
    bra     FPUTYPE             ; go and look for hardware FPU

GOT_030:
    ori.b   #IS030,d7           ; we are an 68030

;   We next decide whether hardware FP is present

FPUTYPE:
*    lea     GOT_ALL(pc),a0      ; a0 -> trap handler
*    bsr     SET_VECTORS
*    dc.l    $f2800000
*;   FNOP                        ; See if we have hardware FP at all ?
*
*;   We have hardware FP - is it 68881 or 68882/68040/68060?
*
*    dc.w    $f327
*;   FSAVE   -(A7)               ; see if got FPU
*    addq.b  #IS881,d7           ; Assume 68881
*    cmp.b   #0x18,1(a7)         ; is it a 68881?
*    beq     GOT_ALL             ; YES .. we are done
*    addq.b  #IS882-IS881,d7     ; NO, make a 68882

;   It is now time to tidy up as we have our answers

GOT_ALL:
    move.l  a5,a7               ; restore stack
    dc.l    $4e7b4801
;   MOVEC   D4,VBR              ; reset D4 -> vector base register

    lea     -16(a4),a0          ; get area to release (adjusted for header)
    move.w  MEM.RCHP,a1         ; ... YES, set vector required
    jsr     (a1)                ; do it

GOT_SGC:
    move.b  d7,SYS_PTYP(a6)     ; save answers in system variables area

PROCTYPE_END:
    bsr     __superend          ; return to user mode - bypassing signal checking
    moveq   #0,d0               ; clear d0
    move.b  SYS_PTYP(a6),d0     ; Set return value into top byte

PROCTYPE_EXIT:
    lea     CPUTYPE(pc),a0      ; Address to store result inside program
    move.b  d0,(a0)             ; save for next time around
    movem.l (sp)+,d4/d5/d7/a2/a4/a5/a6 ; save registers corrupted
PROCTYPE_RTS:
    rts

