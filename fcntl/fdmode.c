/*
 *					f d m o d e
 *
 *	Unix compatible routine to change raw or cooked mode
 *	using level 1 file.
 */

#define __LIBRARY__

#include <qdos.h>
#include <stdio.h>
#include <fcntl.h>
#include <errno.h>

int fdmode	_LIB_F2_( int,	fd, 	\
					  int,	mode)
{
	struct UFB *uptr;

	if( !( uptr = _Chkufb( fd )))
	{
		return -1;
	}

	if( mode )
	{
		uptr->ufbflg |= UFB_NT;
	}
	else
	{
		uptr->ufbflg &= (short)~UFB_NT;
	}
	return 0;
}
