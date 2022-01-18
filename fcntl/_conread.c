/*
 *					_ c o n r e a d _ c
 *
 *	This routine is called from the 'read' call.  It handles
 *	input from the console/screen device.
 *
 *	The idea of vectoring the call into this routine is that
 *	this makes it possible to replace this routine with a
 *	full terminal emulator if so desired.	 This can be done
 *	in a way that is transparent to user-level programs.
 *
 *
 *	RETURN VALUES:
 *			0/+ve	This many bytes (from the start of the data
 *					buffer passed) have been read
 *					any translation.
 *			-1		Error occurred.
 *
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	18 Sep 92	DJW   - Original version
 *						an upgrade to support a CURSES library.
 *
 *	11 Jul 93	DJW   - Removed assumption that io_fbyte() sets _oserr.
 *					  - Removed assumption that sd_curs() sets _oserr.
 *
 *	 4 Apr 94	DJW  - When CTRL-D pressed, must return 0 (was returning -1).
 *					  - Also, was not necessarily returning -1 on error.
 *
 *	 8 Apr 94	EAJ   - Added sd_donl() call to force any pending newlines
 *						to be done (needed on QXL).
 *
 *	13 Apr 94	EAJ   - vectored the call to io_fbyte. See readmove_c.
 *
 *	12 Nov 95	DJW   - Now get timeout via support routine to allow for
 *						the setting of the UFB_ND and UFB_NB flags.
 *
 *	17 Jun 96	RZ	  - Fixed to return count instead of EOSERR if count>0
 *
 */

#define __LIBRARY__

#include <qdos.h>
#include <fcntl.h>
#include <errno.h>

static
int 	default_conread _LIB_F3_(struct UFB *,		 uptr,	\
								 unsigned char *,	buf,	\
								 unsigned int,	   len)
{
	register int	 reply;
	register unsigned char	*ptr;
	register unsigned char	*bufend;
	register chanid_t	 chanid;
	register timeout_t	 timeout;

	/*
	 *	See if we are in EOF state
	 */
	if (uptr->ufbst & UFB_EOF) {
		uptr->ufbst &= (unsigned char)~UFB_EOF;    /* Clear EOF flag */
		_oserr = ERR_EF;
		errno = EOSERR;
		return 0;
	}
	chanid	= uptr->ufbfh;
	timeout = _GetTimeout(uptr);
	/*
	 *	First do any pending newlines, explicitly, for QXL,
	 *	since QXL doesn't do it when enabling the cursor
	 */
	(void) sd_donl( chanid, timeout);

	/*
	 *	Ensure that a cursor is enabled
	 */
	(void) sd_cure( chanid, timeout);

	/*
	 *	Now start reading data from the keyboard.
	 *	Certain characters are treated as having
	 *	special meaning.
	 */
	for ( ptr=buf, bufend=buf+len ; ptr < bufend ; ptr++) {
		if ((reply=(*_readkbd)( chanid, timeout, (char *)ptr)) != 0) {
			if (ptr>buf)
				goto DO_EXIT;
			_oserr = reply;
			errno = EOSERR;
			reply = -1;
			goto KILL_CURSOR;
		}
		/*
		 *	If in RAW mode, there are no special
		 *	characters, and no echoing done.
		 */
		if (uptr->ufbflg & UFB_NT) {
			continue;
		}
		/*
		 *	Handle those characters which need special treatment
		 */
		switch (*ptr) {
		case 4 :		 /* CTRL_D == EOF */
				_oserr = ERR_EF;					/* Set QDOS EOF code */
				uptr->ufbst |= (char) UFB_EOF; 			/* ... and set flag in UFB */
				goto DO_EXIT;						/* Ignore this character, by not incrementing ptr */

		case 192:		/* LEFT == Delete */
		case 194:		/* CTRL-LEFT == Delete */
				if (ptr != buf) {
					(void) sd_pcol	(chanid, timeout);
					(void) io_sbyte (chanid, timeout, ' ');
					(void) sd_pcol	(chanid, timeout);
					ptr--;			/* Ignore character just deleted */
				}
				/* FALLTHRU */
		case 200:		/* RIGHT */
		case 202:		/* CTRL-RIGHT */
				ptr--;				/* Ignore character just read */
				continue;

		case 208:		/* UP */
		case 216:		/* DOWN */
		case '\n':		/* Newline */
				(void) io_sbyte (chanid, timeout, '\n');
				ptr++;
				goto DO_EXIT;
		default:
				(void) io_sbyte (chanid, timeout, *ptr);
				break;
		}	/* End of switch */
	}	/* End of for loop */
	/*
	 *	Suppress cursor when finished
	 */
DO_EXIT:
	reply = (long)(ptr - buf);
KILL_CURSOR:
	(void) sd_curs( chanid, timeout);
	return reply;
}


/*===================================================================
 *		Default vector points to this routine
 *------------------------------------------------------------------*/
#if __STDC__
int 	(*_conread)(UFB_t *, void *, unsigned int) = (int (*)(UFB_t *, void *, unsigned int)) default_conread;
#else
int 	(*_conread)() = default_conread;
#endif
