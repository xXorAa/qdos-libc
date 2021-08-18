/*
 *		a b o r t
 *
 *	Abnormal program termination
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	16 Apr 94	DJW   - Changed to raise an abort signal as specified in 
 *						Plauger rather than automatically exiting.	Then
 *						exit if control returned.
 *						Reported by David Gilham.
 *	25 Feb 95	DJW   - Amended to use _LIB_F0_ macro for parameters
 */

#define _LIBRARY_SOURCE

#include <stdlib.h>
#include <signal.h>

void abort _LIB_F0_(void)
{
	(void) raise(SIGABRT);
	exit(-1);
}
