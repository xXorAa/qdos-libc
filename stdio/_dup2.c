/*                                _ d u p 2                                */

/* For those ancient systems without dup2, we fake it. This is done by
 * repeatedly calling dup() until it yields the required file number.
 */

#include "stdiolib.h"

/*LINTLIBRARY*/

#ifndef		DUP2

#undef dup2

static int __dup2_ F2(int, x, int, y)

{
  register int n;			/* new file descriptor */
  register int s;			/* return status */

  if ((n = dup(x)) < 0)
    return -1;
  else if (n == y)
    return 0;
  else {
    s = __dup2_(x, y);
    (void) close(n);
    return s;
  }
}

int __dup2 F2(int, x, int, y)

{
  return (close(y) < 0 && errno != EBADF ? -1 : __dup2_(x, y));
}
#endif
