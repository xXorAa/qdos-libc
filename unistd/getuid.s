;
;   g e t u i d
;
;   Routine to simulate the various Unix calls to do with
;   processing the User and Group Id.  We act as if we are
;   always super-user.
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   07 Nov 93   DJW   - Added underscore to entry points

    .text
    .even
    .globl _getuid
    .globl _geteuid
    .globl _getgid
    .globl _getegid
    .globl _setgid
    .globl _setuid

_getuid:
_geteuid:
_getgid:
_getegid:
_setgid:
_setuid:
    moveq   #0,d0
    rts

