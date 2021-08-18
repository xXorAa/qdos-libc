/*
 *      q s t r n i c m p
 *
 *  Routine to compare QDOS strings up to 
 *  a maximum length ignoring case.
 *  QDOS equivalent of C routine strnicmp().
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  16 Jun 93   DJW   - First Version
 *
 *  08 Nov 93   DJW   - Changed return type to short
 */

#define __LIBRARY__

#include <qdos.h>

int qstrnicmp _LIB_F3_(struct QLSTR *,string1, \
                          struct QLSTR *,string2, \
                          short,maxsize)
{
    short   size1, size2;
    int     reply;

    /*
     *  Save old string sizes, and if either string
     *  is larger than 'maxsize' temporarily adjust length
     */
    if ((size1 = string1->qs_strlen) > maxsize)
        string1->qs_strlen = maxsize;
    if ((size2 = string2->qs_strlen) > maxsize)
        string2->qs_strlen = maxsize;
    /*
     *  Do the comparison
     */
    reply = ut_cstr (string1, string2, 1);
    /*
     *  Restore original string lengths before
     *  returning the result of the comparison
     */
    string1->qs_strlen = size1;
    string2->qs_strlen = size2;
    return (reply);
}

