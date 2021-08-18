#
/*
 * strerror - map error number to descriptive string
 *
 * This version is obviously somewhat Unix-specific.
 *
 *  If CSTRING is not defined, then assembler version is used
 *   N.B. The assembler is not portable to other processor types,
 */

#ifdef CSTRING
/*---------------------------- C version ----------------------------*/
#include <string.h>

char *strerror(errnum)
int errnum;
{
  extern int sys_nerr;
  extern char *sys_errlist[];

  if (errnum > 0 && errnum < sys_nerr)
    return(sys_errlist[errnum]);
  else
    return("unknown error");
}
#else
/*------------------------------ M68000 Assembler version --------------------*/
#if ( TARGET == M68000 )

; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   07 Nov 93   DJW   - Added underscore to entry point

#include <limits.h>

#if (INT_MAX == SHRT_MAX)
#define MOVE_ move.w
#define CMP_ cmp.w
#define LEN 2
#else
#define MOVE_ move.l
#define CMP_ cmp.l
#define LEN 4
#endif

    .data

unknown:
    dc.b  'unknown error',0

    .globl  _strerror

    .text

_strerror:
    MOVE_   4(a7),d1        /* get errnum */
    ble     I1_3            /* errnum <= 0 ? unknown error ! */
    CMP_    _sys_nerr,d1
    bge     I1_3            /* errnum >= sys_nerr ? unknown error ! */
#if (INT_MAX == SHRT_MAX)
    ext.l   d1
#endif
    asl.l   #2,d1           /* errnum *= sizeof( char * ) */
    lea     _sys_errlist,a0
    add.l   d1,a0
    move.l  (a0),d0         /* return ptr to error message */
    bra     I1_1
I1_3:
    move.l  #unknown,d0     /* return "unknown error" */
I1_1:
    rts
#endif /* TARGET == M68000 */

#endif

