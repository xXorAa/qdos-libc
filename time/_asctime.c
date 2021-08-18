/*
 *				_ a s c t i m e
 *
 *	Convert the tm time structure value to a string.
 *
 *	This function uses the same format, and the same 
 *	internal buffer as ctime().
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	30 Aug 93	DJW   - Parameter check (against NULL) added.
 *					  - Table of month and day names made external
 *						so that it can be shared with other routines.
 *
 *	11 Dec 94	DJW   - Inserted colons back into time part of field.
 *						Somehow they had got removed.
 *						(Problem reported by Johnathan Hudson)
 *
 *	02 Jan 95	DJW   - Added missing 'const' qualifer to function declaration
 */

#define __LIBRARY__

#include <time.h>
#include <stdio.h>

static char timebuf[26] = "Day Mon dd hh:mm:ss yyyy\n";

char *asctime _LIB_F1_(const struct tm *,  tmp)
{
	if ( tmp == (struct tm *)NULL ) {
		return((char *)NULL );
	}
	(void) sprintf( timebuf,"%.3s %.3s %.2d %02d:%02d:%02d %4d\n",
					__week_day[tmp->tm_wday],
					__month[tmp->tm_mon],
					tmp->tm_mday,
					tmp->tm_hour,
					tmp->tm_min,
					tmp->tm_sec,
					tmp->tm_year + 1900 );
	return( timebuf );
}


#ifdef TESTING

#include <stdio.h>


char _prog_name[] = "test of asctime()";

main()
{
	time_t	readtime;
	struct tm	*tm;
	char	*ptr;

	while (1) {
		printf ("Enter a raw time value: ");
		scanf ("%ld\n",&readtime);
		tm = gmtime(&readtime);
		ptr = asctime(tm);
		printf ("asctime() = %s\n", ptr);
	}
}

#endif /* TESTING */
