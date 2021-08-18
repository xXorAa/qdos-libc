/*
 *				_ s t d c h a n s
 *
 *	Finish the initialisation of the channels that will be passed
 *	to the user program.	In particular this includes the stdin
 *	stdout and stderr channels.
 *
 *	Amendment History
 *	~~~~~~~~~~~~~~~~~
 *	20 Oct 92	DJW 	Added _conchan global variable to this module 
 *						to avoid the need for a separate library module
 *						merely to define it.
 *
 *	26 Aug 93	DJW   - Ensure timeout field set to for infinite timeout
 *						in UFB.
 *
 *	02 Apr 94	DJW   - Added _condetails parameter to call vai 'consetup'
 *						to improve chance of putting called code into a RLL.
 *
 *	10 Mar 96	DJW   - Removed the setting of the UFB_ND flag for stdout
 *						and stderr.  Instead sets UFB_SY flag.
 *
 *	23 Mar 96	DJW   - Removed setting of UFB_SY flag as it appears to cause
 *						excessive disk I/O on latest SMSQ/E when output is
 *						redirected to a disk file.
 */

#define __LIBRARY__

#include <qdos.h>
#include <fcntl.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

chanid_t  _conchan = -1;

void _stdchans(void)
{
	register struct UFB *uptr;
	long nc;				/* channel OPEN mask */
	int ic; 				/* file descriptor of a console channel */
	short i;

	/*
	 *	Set up default UFB allocation
	 *
	 *	Enough space is set up at this stage to handle the
	 *	3 default files (stdin, stdout and stderr).
	 */
	_ufbs = (struct UFB *)calloc ((size_t)_nufbs,(size_t)sizeof(struct UFB));

	nc = 0; 	/* preset mask as no files opened */
	/*
	 *	If command line re-direction has not been suppressed
	 *	then we open uf the files at level 1.
	 */
	if (_cmdchannels != NULL)
	{
		nc = (*_cmdchannels)(nc);
	}
	/*
	 *	If passing channels via the stack is not suppressed
	 *	then we now need to set up level 1 file channels for
	 *	any channels passed on the stack.
	 */

	if (_stackchannels != NULL)
	{
		nc = (*_stackchannels)(nc);
	}
	/*
	 *	We now try to see if any of the already
	 *	opened channels is a console
	 */
	for (i=0, ic = -1 ; i < 3 ; i++)
	{
		if ( (nc & (1U << i)) &&  isatty(i) )
		{
			ic = i;
			break;
		}
	}
	/*
	 *	We now open any of stdin, stdout and stderr
	 *	that have not already been opened (via command line
	 *	redirection or channels passed on stack) as 'consoles',
	 *	If possible we re-use an existing console details
	 *	so that they all share the same QDOS channel.
	 */
	for (i=0 ; i < 3 ; i++)
	{
		unsigned long  mask;

		mask = 1U << i;
		if ((nc & mask) == 0)
		{
			uptr = &_ufbs[i];
			uptr->ufbflg = 0;				/* Clear flag so we can get at UFB */
			if (ic != -1)
			{
				_ufbs[ic].ufbflg |= UFB_DP; 		/* Ensure DUP flag set */
				(void) memcpy (uptr, &_ufbs[ic], sizeof (struct UFB));
			} else {
				if (open(_conname,O_WRONLY) == -1)
				{
					exit (ERR_NF);
				}
				ic = i;
			}
			uptr->ufbflg &= (unsigned short)~(UFB_RA | UFB_WA); 	/* Clear READ/WRITE flags */
			nc |= mask;
		}
	}
	/*
	 *	Time for a final tidy up.  Go through the channels
	 *	ensuring the UFB flags are all correct.
	 *
	 *	N.B. The stdio package will already has channels
	 *		 0, 1 and 2 preset to open at level 2.
	 */
	for( i = 0; i < 30; i++) {
		unsigned short flagval;

		if ((nc & (1U << i)) != 0)
		{
			uptr = &_ufbs[i];
			/*
			 *	Try and get a CON_ channel for conio routines
			 */
			if (uptr->ufbtyp == D_CON)
			{
				if ((_conchan == -1))
				{
					_conchan = uptr->ufbfh;
				}
			}
			switch (i) {
			case 0: 	/* stdin */
					flagval = UFB_OP | UFB_RA;
					break;
			case 1: 	/* stdout */
					flagval = UFB_OP | UFB_WA;
					/*
					 *	If stdout is to the screen, we might want
					 *	to take special action at this point. 
					 *	Call a routine (that can be user supplied)
					 *	to determine action to take.
					 */
					if ((uptr->ufbtyp == D_CON)
					&&	((uptr->ufbflg & UFB_NC) == 0))
					{
						if (_endmsg)
						{
							_endchanid = uptr->ufbfh;
						} 
						if (_consetup != NULL)
						{
							(*_consetup)(uptr->ufbfh, &_condetails);
						}
					}
					break;
			case 2: 	/* stderr */
					flagval = UFB_OP | UFB_WA | UFB_NC;
					break;
			default:
					flagval = UFB_OP | UFB_WA | UFB_RA;
					break;
			}
			uptr->ufbflg |= (unsigned short)(flagval | ((_fmode & O_RAW) ? UFB_NT : 0U));
		}	/* end of if */
	}	/* end of for loop */
	/*
	 *	Do any initialisation of the console device required
	 *	(This is used initially by the CURSES library).
	 */
	_Initcon();
}
