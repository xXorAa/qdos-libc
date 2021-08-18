/*
 *              s e t n b f _ c             
 *                                          
 *  Routine to disable level 2 buffering    
 *  (stdio.h may also contain macro version 
 */

#define __LIBRARY__

#include <stdio.h>
#include <sys/types.h>

#ifdef setnbf
#undef setnbf
#endif

void    setnbf _LIB_F1_(FILE *,  fp)
{
    setbuf(fp,(char *)NULL);
    return;
}

