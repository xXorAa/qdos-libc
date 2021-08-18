/*
 *					j d a t e _ c
 *
 *	Number of days since the base date of the Julian calendar.
 *
 *	NOTE.  This routine is not in either ANSI, POSIX or SVR4
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	24 Jan 95	DJW   - Amended to use the _LIB_F1_ macro for parameters
 */

#define __LIBRARY__

#include <time.h>

long j_date _LIB_F1_(struct tm *, worktime)
{
	long c, y, m, d;

	y = worktime->tm_year + 1900;	/* year - 1900 */
	m = worktime->tm_mon + 1;		/* month, 0..11 */
	d = worktime->tm_mday;			/* day, 1..31 */
	if(m > 2)
		m -= 3L;
	else {
		m += 9L;
		y -= 1L;
	}
	c = y / 100L;
	y %= 100L;
	return( ((146097L * c) >> 2) +
		((1461L * y) >> 2) +
		(((153L * m) + 2) / 5) +
		d +
		1721119L );
}
