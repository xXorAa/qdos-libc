;=========================================================================
;               c C a l l R L M
;
;   C wrapper routines for calling the RLM.
;
;   AMENDMENT HISTORY
;   ~~~~~~~~~~~~~~~~~
;   09 Oct 94   DJW   - First version
;
;   15 Mar 96   DJW   - Added the RLM_LinkRLL and RLM_UnlinkRLL entry points
;-------------------------------------------------------------------------

    .globl  _RLM_LinkCode
    .globl  _RLM_LinkRLL
    .globl  _RLM_UnlinkRLL
    .globl  _RLM_LoadLib
    .globl  _RLM_SetTimeout
    .globl  _RLM_SetLoadMode
    .globl  _RLM_SetLoadDir
    .globl  _RLM_SetDebugDir
    .globl  _RLM_SetDebugMode
    .globl  _RLM_ReadVariables
    .globl  _RLM_RelocLD
    .globl  _RLM_RelocGST


_RLM_LinkCode:
    moveq   #0,d0
DoCall:
    jmp     _CallRLM

_RLM_LinkRLL:
    moveq   #1,d0
    bra     DoCall

_RLM_UnlinkRLL:
    moveq   #2,d0
    bra     DoCall

_RLM_LoadLib:
    moveq   #3,d0
    bra     DoCall

_RLM_SetTimeout:
    moveq   #4,d0
    bra     DoCall

_RLM_SetLoadMode:
    moveq   #5,d0
    bra     DoCall

_RLM_SetLoadDir:
    moveq   #6,d0
    bra     DoCall

_RLM_SetDebugDir:
    moveq   #7,d0
    bra     DoCall

_RLM_SetDebugMode:
    moveq   #8,d0
    bra     DoCall

_RLM_ReadVariables:
    moveq   #9,d0
    bra     DoCall

_RLM_RelocLD:
    moveq   #10,d0
    bra     DoCall

_RLM_RelocGST:
    moveq   #11,d0
    bra     DoCall

