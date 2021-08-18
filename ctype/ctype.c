#include <ctype.h>

/*
 *  Definition of the ctype array
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  28 May 94   DJW   - Added a pointer to this table initialised to the
 *                      second element.  This allows for locale handling
 *                      and also generates more efficient code for the
 *                      ctype macros which do not have to add 1 any more
 *                      to the supplied value to get the table offset.
 *
 *  24 Jan 95   DJW   - Changed type of table to 'unsigned char'.  This stops
 *                      the compiler generating warnings, and may well also
 *                      lead to better code in the ctype macros.
 */

static unsigned char ctype_table[257] = {
    /*
     *  We could theoretically put an array of values at
     *  this point to allow for programmers forgetting to
     *  cast char parameters to the macros to unsigned int
     *  and thus using negative values instead of postive.
     *  (except for -1 which is always a special case).
     */
    0,      /* -1 index into array */

    /* NUL SCH STX ETX EOT ENQ ACK BEL */
        _C, _C, _C, _C, _C, _C, _C, _C,

    /* BS    HT	    LF     VT    FF      CR    SO  SI  */
       _C, _C|_S, _C|_S, _C|_S, _C|_S, _C|_S,  _C, _C,

    /* DLE DC1 DC2 DC3 DC4 NAK SYN ETB */
        _C, _C, _C, _C, _C, _C, _C, _C,

    /* CAN  EM SUB ESC  FS  GS  RS  US */
        _C, _C, _C, _C, _C, _C, _C, _C,

    /* SPACE   !    "   #   $   %   &   ' */
        _B|_S, _P, _P, _P, _P, _P, _P, _P,

    /*   (   )   *   +   ,   -   .   / */
        _P, _P, _P, _P, _P, _P, _P, _P,

    /*      0      1      2      3      4      5      6      7 */
        _X|_N, _X|_N, _X|_N, _X|_N, _X|_N, _X|_N, _X|_N, _X|_N,

    /*     8       9   :   ;   <   =   >   ? */
        _X|_N, _X|_N, _P, _P, _P, _P, _P, _P, 

    /*   @      A      B      C      D      E      F   G */
        _P, _X|_U, _X|_U, _X|_U, _X|_U, _X|_U, _X|_U, _U,

    /*   H   I   J   K   L   M   N   O */
        _U, _U, _U, _U, _U, _U, _U, _U,

    /*   P   Q   R   S   T   U   V   W */
        _U, _U, _U, _U, _U, _U, _U, _U,

    /*   X   Y   Z   [   \   ]   ^   _ */
        _U, _U, _U, _P, _P, _P, _P, _P,

    /*   `      a      b      c      d      e      f   g */
        _P, _X|_L, _X|_L, _X|_L, _X|_L, _X|_L, _X|_L, _L,

    /*   h   i   j   k   l   m   n   o */
        _L, _L, _L, _L, _L, _L, _L, _L,

    /*   p   q   r   s   t   u   v   w */
        _L, _L, _L, _L, _L, _L, _L, _L,

    /*   x   y   z   {   |   }   ~   DEL */
        _L, _L, _L, _P, _P, _P, _P, _C,

    /* QL higH character set, 128 - 192 */
        _P, _P, _P, _P, _P, _P, _P, _P,
        _P, _P, _P, _P, _P, _P, _P, _P,
        _P, _P, _P, _P, _P, _P, _P, _P,
        _P, _P, _P, _P, _P, _P, _P, _P,
        _P, _P, _P, _P, _P, _P, _P, _P,
        _P, _P, _P, _P, _P, _P, _P, _P,
        _P, _P, _P, _P, _P, _P, _P, _P,
        _P, _P, _P, _P, _P, _P, _P, _P,

    /* QL high control char set */ 
        _C, _C, _C, _C, _C, _C, _C, _C,
        _C, _C, _C, _C, _C, _C, _C, _C,
        _C, _C, _C, _C, _C, _C, _C, _C,
        _C, _C, _C, _C, _C, _C, _C, _C,
        _C, _C, _C, _C, _C, _C, _C, _C,
        _C, _C, _C, _C, _C, _C, _C, _C,
        _C, _C, _C, _C, _C, _C, _C, _C,
        _C, _C, _C, _C, _C, _C, _C, _C
};


unsigned char *  _ctype = &ctype_table[1];

int     _ctypetemp;

