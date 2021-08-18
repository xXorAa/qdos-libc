/*                              t m p f i l e                              */

#ifdef QDOS
#define __LIBRARY__
#include <fcntl.h>
#endif /* QDOS */

#include "stdiolib.h"

/*LINTLIBRARY*/

FILE *tmpfile F0()

{
  char *name;				/* name of file */
  register int i;			/* retry count */
  register FILE *fp;			/* temporary file */
#ifdef QDOS
  struct UFB * uptr;
#endif /* QDOS */

  for (i = TMP_MAX;
       (fp = fopen(name = tmpnam((char *) 0), "w+")) == NULL && --i;
      )
    ;
  if (fp != NULL)
#ifndef QDOS
    remove(name);
#else
    {
    uptr = _Chkufb(fileno(fp));
    uptr->ufbflg |= UFB_TF;
    if ((uptr->ufbfh1 = (long)malloc (strlen(name)+1)) != 0)
        (void)strcpy((char *)uptr->ufbfh1,name);
    }
#endif /* QDOS */
  return fp;
}
