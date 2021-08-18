*
*   l i b s o c k e t
*
*   This is a dummy file used when the library is not linked
*   in to the program in question.  If the library is present, then
*   an equivalent file is used at the start of a library to
*   get a comment into it.   It also means that examination of the
*   binary program can tell what versions of the libraries were used.
*
*   AMENDMENT HISTORY
*   ~~~~~~~~~~~~~~~~~
*   09 Aug 98   DJW   - First version
*                       (based on code supplied by Jonathan Hudson)

        .text

        .globl  LIBSOCKET_VER
        .globl  _recv
        .globl  _send
        .globl  _fcntl_socket

ENETDOWN equ 50

LIBSOCKET_VER:   

_recv:
_send:  
_fcntl_socket:
        move.l  #ENETDOWN,_errno
        moveq   #-1,d0
        rts
        end

