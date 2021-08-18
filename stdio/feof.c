/*                                 f e o f                                 */
 
#include "stdiolib.h"

/*LINTLIBRARY*/

#undef feof
int feof F1(FILE *, fp)

{
  return _STDIO_FEOF_(fp);
}
