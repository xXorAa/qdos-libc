/*
 *		g m t i m e
 *
 *	ANSI compatible routine to use the given time in seconds
 *	since the Epoch to fill the tm structure with UTC
 *	(Coordinated Universal Time) values.
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	30 Aug 93	DJW   - Replaced original implementation with one taken
 *						from Ralph Wenk's POSIX compatible time routines.
 *
 *	02 Apr 94	DJW   - Allowed for time_t to be signed to give dates
 *						earlier than Unix base date.
 *
 *	18 Apr 94	EAJ   - Fixed handling of leap years and times before 1970.
 *						The previous code didn't handle pre-1970 at all,
 *						and had a too simplistic view of when a year
 *						is a leap year. Also, sets tm_isdst to -1, acc.
 *						to K&R 2nd Ed. pg. 255. Just setting it to 0 was
 *						misleading, I believe.
 *
 *	02 Jan 95	DJW   - Added 'const' qualifier to function declaration.
 */

#define __LIBRARY__

#include <time.h>

#define SECS_PER_MINUTE ((time_t)60)
#define SECS_PER_HOUR	((time_t)(60 * SECS_PER_MINUTE))
#define SECS_PER_DAY	((time_t)(24 * SECS_PER_HOUR))
#define SECS_PER_YEAR	((time_t)(365 * SECS_PER_DAY))
#define SECS_PER_LEAP	((time_t)(SECS_PER_YEAR+SECS_PER_DAY))

static int is_leap( int year )
{
	year += 1900; /* Get year, as ordinary humans know it */

	/*
	 *	 The rules for leap years are not
	 *	 as simple as "every fourth year
	 *	 is leap year":
	 */

	if( (unsigned int)year % 100 == 0 ) {
		return (unsigned int)year % 400 == 0;
	}

	return (unsigned int)year % 4 == 0;
}


struct tm *gmtime _LIB_F1_(const time_t *,  tp)
{
	static struct tm tm;
	time_t t,secs_this_year;

	t = *tp;
	tm.tm_sec  = 0;
	tm.tm_min  = 0;
	tm.tm_hour = 0;
	tm.tm_mday = 1;
	tm.tm_mon  = 0;
	tm.tm_year = 70;
	tm.tm_wday = ( t / SECS_PER_DAY + 4 ) % 7;	/* 01.01.70 was Thu */
	tm.tm_isdst = -1;


	/*
	 *	This loop handles dates in 1970 and later
	 */
	while ( t >= ( secs_this_year =
				   is_leap(tm.tm_year) ?
				   SECS_PER_LEAP :
				   SECS_PER_YEAR ) ) {
		t -= secs_this_year;
		tm.tm_year++;
	}

	/*
	 *	This loop handles dates before 1970
	 */
	while ( t < 0 )
		t += is_leap(--tm.tm_year) ? SECS_PER_LEAP : SECS_PER_YEAR;

	tm.tm_yday = t / SECS_PER_DAY;				/* days since Jan 1 */


	if ( is_leap(tm.tm_year) )					/* leap year ? */
		__days_per_month[1]++;

	while ( t >= __days_per_month[tm.tm_mon] * SECS_PER_DAY ) {
		t -= __days_per_month[tm.tm_mon++] * SECS_PER_DAY;
	}

	if ( is_leap(tm.tm_year) )					/* leap year ? restore Feb */
		__days_per_month[1]--;

	while ( t >= SECS_PER_DAY ) {
		t -= SECS_PER_DAY;
		tm.tm_mday++;
	}
	while ( t >= SECS_PER_HOUR ) {
		t -= SECS_PER_HOUR;
		tm.tm_hour++;
	}
	while ( t >= SECS_PER_MINUTE ) {
		t -= SECS_PER_MINUTE;
		tm.tm_min++;
	}
	tm.tm_sec = t;
	return( &tm );
}


#ifdef TESTING

#include <stdio.h>

main()
{
	struct tm  *tm;
	time_t		readtime;

	while (1) {
		printf ("Enter a raw time value: \n");
		scanf ("%d\n",&readtime);

		tm = gmtime(&readtime);

		printf ("tm_sec=%d\n",tm->tm_sec);
		printf ("tm_min=%d\n",tm->tm_min);
		printf ("tm_hour=%d\n",tm->tm_hour);
		printf ("tm_mday=%d\n",tm->tm_mday);
		printf ("tm_mon=%d\n",tm->tm_mon);
		printf ("tm_year=%d\n",tm->tm_year);
		printf ("tm_wday=%d\n",tm->tm_wday);
		printf ("tm_yday=%d\n",tm->tm_yday);
		printf ("tm_isdst=%d\n",tm->tm_isdst);
	}
}

#endif /* TESTING */
