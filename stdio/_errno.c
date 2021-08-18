/*                               _ e r r n o                               */

/* This modules provides a definition for the errno variable.
 * It is used in those cases where the system definition
 * clashes with perror().
 */

#include "stdiolib.h"

/*LINTLIBRARY*/

#ifdef		ERRNO
int __errno = 1;			/* installation flag */
int errno;
#endif
