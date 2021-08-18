/*
 *      f g e t c h i d
 *
 *  Routine to return a QDOS channel id from a level 2
 *  file descriptor.                                     
 *
 *  Amendment History
 *  ~~~~~~~~~~~~~~~~~
 *  10 Oct 92   DJW   - Added error check on file pointer not being NULL
 */

#define __LIBRARY__

#include <qdos.h>
#include <stdio.h>

extern chanid_t getchid (int);

chanid_t fgetchid  _LIB_F1_ ( FILE *, fp)       /* File pointer to inquire */
{
    if (fp == NULL) {
        return (ERR_NO);
    }
    return getchid( (int)fileno(fp) );
}

