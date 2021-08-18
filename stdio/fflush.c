/*                               f f l u s h                               */

#include "stdiolib.h"

/*LINTLIBRARY*/

int fflush F1(FILE *, fp)

{
#ifdef QDOS
  if (fp == NULL) {
    /*
     * NULL means flush all channels open for output
     * This is an ANSI and SVR4 feature that is not part (yet) of POSIX
     * As we do not know how to actually do this in this STDIO package,
     * we simply make a good return!
     */
    return 0;
  }
#endif /* QDOS */
  return FFLUSH(fp);
}
