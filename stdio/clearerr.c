/*                             c l e a r e r r                             */
 
#include "stdiolib.h"

/*LINTLIBRARY*/

#undef clearerr
void clearerr F1(FILE *, fp)

{
  _STDIO_CLEARERR_(fp);
}
