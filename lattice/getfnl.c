/*
 *				g e t f n l
 *
 * Lattice compatible routine to get a file name list
 *
 *	VERSION HISTORY
 *	~~~~~~~~~~~~~~~
 *	12 Sep 92	DJW 	If there are too many names to fit in the buffer
 *						supplied, then a 'buffer overflow' error is returned.
 *						Previously a 'good' return was made with names
 *						gathered to date.
 *
 *	10 Jul 93	DJW 	Removed assumption that io_close sets _oserr.
 *
 *	22 Aug 93	DJW
 */

#define __LIBRARY__

#include <qdos.h>
#include <errno.h>
#include <string.h>

int getfnl	_LIB_F4_( char *,	wcard,		 /* Wild card to use (or NULL) */
					  char *,	fna,		 /* file name array*/
					  size_t,	fnasize,	 /* Size of file name array */
					  int,		attr)		 /* Search attributes */
{
	chanid_t dir_chan;
	struct qdirect dir;
	char name[50];
	int nused, i, nstr, reply;

	/*
	 *	Open the QDOS directory
	 */
	if((dir_chan = open_qdir( wcard ))<= 0) 
	{
		/* Failed to open */
		return -1;
	}

	for (nused = 0, nstr = 0; ; nstr++)
	{
		if ((reply = read_qdir(dir_chan, wcard, name, &dir, (unsigned short)attr)) <= 0)
		{
			/*
			 *	Check why read failed
			 */
			if (reply == 0) 
			{
				/*
				 *	EOF condition - simply exit loop
				 */
				break;
			} 
			else 
			{
				/*
				 *	Something else went wrong !
				 *	Set for error reply.
				 *	(errno/_oserr already set by read_qdir() routine)
				 */
				nstr = -1;
				break;
			}
		}
		/*
		 *	Copy name into the array
		 *	(checking that there is room)
		 *	Terminate array with a zero byte
		 */
		i = strlen( name ) + 1;
		if( (nused += i) >= fnasize ) 
		{
			errno = ENOMEM;
			nstr = -1;
			break;
		}
		(void) strcpy( &fna[nused-i], name);
		fna[nused] = '\0';
	}

	/*
	 *	Close directory and exit
	 */
	(void) io_close( dir_chan );
	return nstr;
}
