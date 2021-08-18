/*
 *      q s t r n c m p
 *
 *  Routine to compare QDOS strings up to 
 *  a maximum length.
 *  QDOS equivalent of C routine strncmp().
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  16 Jun 93   DJW   - First Version
 *
 *  08 Nov 93   DJW   - Changed return type to short
 *
 *  24 Jan 95   DJW   - Missing 'const' keyword added to function definition.
 */

#define __LIBRARY__

#include <qdos.h>

int qstrncmp _LIB_F3_( const struct QLSTR *, string1, \
                       const struct QLSTR *, string2, \
                       short,                maxsize)
{
    short  size1, size2;
    int    reply;

    /*
     *  Save old string sizes, and if either string
     *  is larger than 'maxsize' temporarily adjust length
     */
    if ((size1 = string1->qs_strlen) > maxsize)
        (short)string1->qs_strlen = maxsize;
    if ((size2 = string2->qs_strlen) > maxsize)
        (short)string2->qs_strlen = maxsize;
    /*
     *  Do the comparison
     */
    reply = ut_cstr ((void *)string1, (void *)string2, 0);
    /*
     *  Restore original string lengths before
     *  returning the result of the comparison
     */
    (short)string1->qs_strlen = size1;
    (short)string2->qs_strlen = size2;
    return (reply);
}

