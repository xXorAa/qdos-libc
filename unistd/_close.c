/*
 *					c l o s e
 *
 *	Unix compatible routine to handle closing all level 1 files.
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	23 Feb 93	DJW 	Code for deleting temporary files was not correct.
 *						(reported by David Gilam)
 *
 *	25 Sep 93	DJW 	Code for deleting temporary files was still not correct!
 *						When deleting temporary files, memory used to hold
 *						name freed as well.
 *
 *	08 Oct 93	DJW 	Code for closing 'DUP'ed files was incorrect.
 *
 *	11 Apr 94	EAJ 	Code added, checking for NC-flag set on DUP'ed files.
 *						Also bug fixed: changed unlink(uptr->ufbfh1) to free(same).
 *
 *	12 Nov 95	DJW   - Clear down UFB name field when closing a file
 *
 *	26 May 98	jh		Fix strange close of two channels for D_SOCKET files 
 */

#define __LIBRARY__

#include <qdos.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>

#ifdef TESTING
#include <stdio.h>
#endif

int close	_LIB_F1_ (int,	fd)
{
	struct UFB *uptr;
	int ret = 0;
	short dup_found=0;
	short nc_found=0;

	/*
	 *	Check that the file is open
	 *	and get the unix file structure
	 */
	if((uptr = _Chkufb(fd)) == NULL)
	{
		return -1L;
	}

	/*
	 *	If the DUP flag is set, then we may have multiple files at the
	 *	C level sharing the same underlying QDOS channel.
	 *
	 *	Check to see if any other open file has the same QDOS file handle.
	 *	If so then don't actually close this file with a QDOS call as another
	 *	handle is using it. This way, only when the last handle using this
	 *	file is closed will the real QDOS file be closed.
	 *
	 *	If any file with the same QDOS channel has the NC flag set, then
	 *	note this for later.
	 */
	if( uptr->ufbflg & UFB_DP )
	{
		struct UFB *up;
		int  i;
		for( i = 0; i < _nufbs; i++ )
		{
			if( ((up = _Chkufb(i)) != NULL) 
			&& (up->ufbfh == uptr->ufbfh) )
			{
				if( i != fd )
				{
				   dup_found=1;
				}
				if( up->ufbflg & UFB_NC )
				{
				   nc_found=1;
				}
			}
		}
		/*
		 *	DUPed file handle found ?
		 *	If not, then clear DUP flag
		 */
		if ( dup_found == 0 )
		{
			uptr->ufbflg &= (unsigned short)~UFB_DP;
		}
	}


	/*
	 *	If the DUP flag is still set, then we have multiple files at the
	 *	C level sharing the same underlying QDOS channel.
	 *
	 *	If any of these had the NC (no close) flag set, then they must ALL
	 *	have the flag set. Otherwise, imagine the situation where 2 files
	 *	share a QDOS channel, and only one has the NC flag set. If one then
	 *	close the channel with the set NC flag first, and then the other one,
	 *	the second close will actually *really* close the QDOS channel, contrary
	 *	to one's intention. If one closes the channels in reverse order,
	 *	all will seem OK.
	 */
	if( dup_found && nc_found )
	{
		struct UFB *up;
		int  i;

		for( i = 0; i < _nufbs; i++)
		{
			if( ((up = _Chkufb(i)) != NULL)
			&& (up->ufbfh == uptr->ufbfh) )
			{
				up->ufbflg |= UFB_NC;
			}
		}
	}


	/*
	 *	If there is a real file handle (i.e. file is real)
	 *	and "no close" or "dup" flags are not set, then we
	 *	want to close the underlying QDOS channel.
	 */
	if( (uptr->ufbfh != 0)
	&&	(uptr->ufbflg & (UFB_NC | UFB_DP)) == 0)
	{
		free (uptr->ufbnam);
		uptr->ufbnam = NULL;
		if ((ret = io_close(uptr->ufbfh)) != 0)
		{
			_oserr = ret;
			errno = EOSERR;
			ret = -1;
		}
		/*
		 *	Check if temporary file.
		 *
		 *	If so delete it as well, and
		 *	release memory used to hold name
		 */
		if(uptr->ufbflg & UFB_TF)
		{
			if (uptr->ufbfh1 != 0)
			{
				(void) unlink( (char *) uptr->ufbfh1 );
				free  ( (void *) uptr->ufbfh1 );
			}
		}
#if 0
		/*
		 *	Check if socket - if so close second channel as well
		 *	DJW - Should this be for PIPE?
		 */
		if( uptr->ufbtyp == D_SOCKET )
		{
			(void) io_close( uptr->ufbfh1 );
		}
#endif
	}

	uptr->ufbfh = 0;
	uptr->ufbflg = 0;
	return ret;
}
