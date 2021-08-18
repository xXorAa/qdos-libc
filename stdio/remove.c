/*                               r e m o v e                               */

#include "stdiolib.h"

/*LINTLIBRARY*/

int remove F1(CONST char *, name)

{
  return unlink(name);
}
