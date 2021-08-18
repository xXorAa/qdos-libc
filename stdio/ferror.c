/*                               f e r r o r                               */
 
#include "stdiolib.h"

/*LINTLIBRARY*/

#undef ferror
int ferror F1(FILE *, fp)

{
  return _STDIO_FERROR_(fp);
}
