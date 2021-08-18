/*
 *					_ c o n w r i t e _ c
 *
 *	This routine is called from the 'write' call when data for
 *	a console or screen device is to be output.    It implements
 *	the handling for the QL screen of the standard ANSI C escape
 *	sequences.
 *	(using ideas from Franz Herrman)
 *
 *	The idea of vectoring the call into this routine is that
 *	this makes it possible to replace this routine with a
 *	full terminal emulator if so desired.	 This can be done
 *	in a way that is transparent to user-level programs.
 *
 *	This routine only needs to handle escape sequences.   It can
 *	leave handling of standard strings to the calling routine
 *	by returning the appropriate values.
 *
 *	RETURN VALUES:
 *			+ve 	This many bytes (from the start of the data
 *					buffer passed can be output without doing
 *					any translation.
 *			  0 	Output finished.   Either all data has been
 *					processed or an error occured.
 *			-ve 	This many characters from the buffer have been
 *					consumed in "special" processing.
 *
 * Routine handles writing to all the different
 * types of device.
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	16 Sep 92	DJW 	- Rewrote original _writetrans() routine as part of
 *						  an upgrade to support a CURSES library.
 *
 *	12 Nov 95	DJW   - Now get timeout via support routine to allow for
 *						the setting of the UFB_ND and UFB_NB flags.
 */

#define __LIBRARY__

#include <qdos.h>
#include <fcntl.h>
#include <string.h>

static
int 	default_conwrite _LIB_F3_ ( struct UFB *,		uptr,	\
									unsigned char *,	buf,	\
									unsigned int,		len)
{
	long	  to_write;
	chanid_t  chanid;
	timeout_t timeout;
	QLRECT_t  cur;
	int 	 pos;

	/*
	 *	If RAW output is required, then let
	 *	the default output routine handle it
	 */
	if ((uptr->ufbflg & UFB_NT))
	{
		return (long)(len);
	}
	chanid	= uptr->ufbfh;
	timeout = _GetTimeout(uptr);
	/*
	 *	Scan data until special character found
	 *	Any data before it is output using string I/O
	 *	(byte level I/O is to expensive )
	 */
	if ((to_write = strcspn ((char *)buf, "\b\r\f\a\t")) != 0)
	{
		return (to_write > len ? (long)len : to_write);
	}
	/*
	 *	If we get here, then one of the special characters
	 *	was found.	 We must now handle it.
	 */
	switch (*buf) {
	case '\b':	/* backspace */
				/* (from Peter Sulzer) */
			(void) sd_pcol( chanid, timeout );
			break;
	case '\r':	/* carriage return */
			(void) sd_tab( chanid, timeout, 0 );
			break;
	case '\a':	/* bell */
			beep( 500, 50 );
			break;
	case '\f':	/* form feed */
			(void) sd_clear( chanid, timeout );
			break;
	case '\t':	/* tabulator */
			 /*
			  * (using a hint from Hans Lub) 
			  * N.B.  We always send at least one space
			  * 	 to ensure pending NL cleared
			  */
			(void) io_sbyte (chanid, timeout, ' ');
			(void) sd_chenq (chanid, timeout, &cur );
			if ((pos = cur.q_x % 8) != 0)
			{
				(void) sd_tab ( chanid, timeout, (short)(cur.q_x + (8 - pos)) );
			}
			break;
	default:
			break;
	}
	return (-1);
}

/*===================================================================
 *		Default vector points to this routine
 *------------------------------------------------------------------*/

#ifdef __STDC__
int 	(*_conwrite)(UFB_t *, void *, unsigned int) = (int (*)(UFB_t *, void *, unsigned int)) default_conwrite;
#else
int 	(*_conwrite)() = default_conwrite;
#endif
