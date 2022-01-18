/*
 *				f c n t l
 *
 * Routine to get and set various file parameters
 * such as file flags, type of I/O device etc.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *	26 Aug 93	DJW   - Merged routines l1_to_c() and c_to_l1() into main
 *						body to avoid function call overheads.
 *
 *	25 Sep 93	DJW   - Added support for Posix O_NONBLOCK and O_SYNC modes.
 *
 *	12 Nov 95	DJW   - Added support for O_NONBLOCK mode correctly in its own
 *						right rather than a synonym for O_NDELAY.
 *					  - Switched to using support routines for mode translation.
 *
 *	11 Aug 98	DJW   - Added a call for D_SOCKET type devices.
 *						This is to support the UQLX socket library
 *						(and any future ones as well if necessary).
 */

#define __LIBRARY__

#include <fcntl.h>
#include <stdarg.h>
#include <errno.h>
#include <stddef.h>

extern int fcntl_socket(int, int, int);

/*
 *	UFB flags we are allowed to touch
 */
#define TOUCH_MASK (unsigned short)(UFB_WA|UFB_RA|UFB_NT|UFB_AP|UFB_ND|UFB_NB|UFB_SY)


int fcntl ( int  fd, int  action,  ...)
{
	va_list ap;
	UFB_t * uptr;
	struct	flock *flock;
	int   flags;

	/*
	 *	Start with a sanity check
	*/
	if ( (uptr = _Chkufb( fd )) == NULL)
	{
		return -1;
	}


	va_start (ap,action);
	flags =  *((int *)ap);
	flock = *((struct flock **)ap);
	va_end(ap);

	/*
	 *	Socket FCNTL calls are sent via
	 *	a vector to allow the code to
	 *	be tailored to the socket library.
	 */
	switch (uptr->ufbtyp)
	{
	case D_SOCKET:
			return fcntl_socket(fd,action,flags);
	default:
			break;
	}

	/*
	 *	Now take the required action
	 */
	switch( action )
	{
		case F_GETFD:
			return (int)uptr->ufbtyp;

		case F_SETFD:
			uptr->ufbtyp = (char)flags;
			return 0;

		case F_GETFL:
			return (int)_ModeFd(uptr->ufbflg);

		case F_SETFL:
			uptr->ufbflg &= (short)~((short)TOUCH_MASK);
			uptr->ufbflg |= (short)(_ModeUfb(flags) & (short)TOUCH_MASK);
			return 0;

		case F_GETLK:
			/* Dummy - pretend it works */
			flock->l_type = F_UNLCK;
			flock->l_whence = SEEK_SET;
			return 0;

		case F_SETLK:
			/* Dummy - pretend it works */
			return 0;

		case F_SETLKW:
			/* Dummy - pretend it works */
			return 0;

		default:
			errno = EINVAL;
			return -1;
	}
	/*	NOT REACHED */
}
