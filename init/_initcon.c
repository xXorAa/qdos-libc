/*
 *			_ i n i t c o n
 *
 *	Dummy routine used when the functions defined in TERMIOS_H
 *	are not in use.   It merely exits without doing anything.
 *	It is called from the end of the program initialsiation
 *	code in the stdchans() routine.
 *
 *
 *	Amendment History
 *	~~~~~~~~~~~~~~~~~
 *	15 Sep 92  DJW	first version.
 */

#define __LIBRARY__

#include <qdos.h>

/*
 *	This routine is called from the start-up code after any
 *	console channels have been opened.
 */
void	_Initcon( )
{
	return;
}
