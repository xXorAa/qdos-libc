/* 
 *						g e t e n v
 *
 *	Scan enviroment variables of the form name=string for 'name' and return 
 *	a pointer to 'string' if found else return NULL.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *	05 Jan 92	DFN - Initial version by Dave Nash.
 *
 *	02 Jan 95	DJW   - Added missing 'const' qualifer to function declaration
 */

#define __LIBRARY__

#include <stdlib.h>
#include <string.h>
#include <unistd.h>

char  *getenv _LIB_F1_(const char *,  name)
{      
   char  **ptrptr;
   size_t	n = strlen(name);

   if (environ == NULL || name == NULL) {
	  goto ERROREXIT;
   }
   for (ptrptr=environ; *ptrptr; ptrptr++) {     /* look for name match        */
	  if (!strncmp(*ptrptr, name, n) && (*ptrptr)[n] == '=') { /* check next char is '='     */
		 return (*ptrptr + n + 1);				/* return pointer to value	  */
	  }
   }
ERROREXIT:
   return (char *)NULL;
} 
	 
