/*
 *		m k t i m e 	/	  l o c a l t i m e    /	t z s e t
 *
 *	Routines for manipulating the time:
 *		localtime
 *		mktime
 *		tzset
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	11 Mar 95	DJW   - Merged mktime(), localtime() and tzset() into this
 *						single source file as mututal interdependencies mean
 *						that including any of them means that you will need
 *						all of them.
 *
 */

#define _LIBRARY_SOURCE

/*------------------------------------------------------------------------
 *						localtime
 *						=========
 *
 *	Synopsis
 *	~~~~~~~~
 *		#include <time.h>
 *		struct tm * localtime (const time_t * timer);
 *
 *	Description
 *	~~~~~~~~~~~
 *	The 'localtime' function converts the calendar time pointed to by 'timer'
 *	into a broken-down time, expressed as local time.
 *
 *	Returns:
 *	~~~~~~~
 *	The 'localtime' function returns a pointer to that object.
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	10 Apr 93	DJW   - The use of the '_days_per_month' array changed to
 *						make this array contain the accumulative days to
 *						this point, and the array made globally visible
 *						for use by the mktime() routine.
 *					  - Calculations on this array ammended accordingly.
 *
 *	30 Aug 93	DJW   - Replaced original implementation with one based on
 *						Ralp Wenk's POSIX compatible time routines.
 *
 *	02 jan 95	DJW   - Added missing 'const' qualifier to function declaration
 *
 *	24 Feb 95	DJW   - Amended to use the _LIB_F1_ macro for parameters
 */

#define _LIBRARY_SOURCE
#include <time.h>
#include <string.h>

struct tm *localtime _LIB_F1_( const time_t *, tp)
{
	struct tm *tmp;
	time_t t;
	int is_dst;

	tzset();
	t = *tp;
	if ( ! __local_clock ) {
		t += __lt_offset;
		is_dst = 0;
	}
	if ( ! __n_hemi )  {                              /* southern hemisphere */
		t += __dst_offset;
		is_dst = 1;
	}
	if ( t >= __dst_switch && t + __dst_offset < __back_switch ) {
		if ( __n_hemi ) {
			t += __dst_offset;
		} else {
			t -= __dst_offset;
		}
		is_dst ^= 1;
	}
	tmp = gmtime( &t );
	tmp->tm_isdst = is_dst;
	return( tmp );
}



/*----------------------------------------------------------------------
 *							mktime
 *							======
 *	Synopsis
 *	~~~~~~~~
 *		#include <time.h>
 *		time_t mktime (struct tm * timeptr);
 *
 *	Description
 *	~~~~~~~~~~~
 *	The 'mktime' function converts the broken-down time, expressed as local
 *	time, in the structure pointer to by 'timeptr' into a calendar time with
 *	the same encoding as that of the values returned by the 'time' function.
 *	The original values of the 'tm_wday' and 'tm_yday' components of the
 *	structure are ignored, and the original values of the other components
 *	are not restricted to the ranges specificied as valid for the 'tm' type
 *	of structure.	On successful completion, the values of the 'tm_wday' and
 *	'tm_yday' components of the structure are set appropriately, and the
 *	other components are set to represent the specified calendar time, but
 *	with their values forced to the ranges indicated above.  The final
 *	value of tm_mday is not set until 'tm_mon' and 'tm_year' are determined.
 *
 *	Returns:
 *	~~~~~~~
 *	The 'mktime' function returns the specified calendar time encoded as a
 *	value of type 'time_t'.  If the calendar time cannot be represented, the
 *	function retruns the value (time_t)-1.
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	30 Aug 93	DJW   - Replaced original implementation of mktime() with one
 *						based on Ralf Wenk's POSIX compatible time routines.
 *					  - Added the tzset() routine from Ralf Wenk's package.
 *						It is in the same file as mktime() as the two
 *						routines are mutually dependant on each other.
 *
 *	24 Feb 95	DJW   - Amended to use the _LIB_Fn_ macros for parameters
 *
 *	04 Mar 95	DJW   - Amended to conform to the ANSI specification on
 *						treatment of tm_yday, and also to ensure that all
 *						fields are correctly normalised and completed on a
 *						successful exit.
 */

#define _LIBRARY_SOURCE
#include <time.h>

#define SECS_PER_MINUTE ((time_t)60)
#define SECS_PER_HOUR	((time_t)(60 * SECS_PER_MINUTE))
#define SECS_PER_DAY	((time_t)(24 * SECS_PER_HOUR))
#define SECS_PER_YEAR	((time_t)(365 * SECS_PER_DAY))

time_t mktime _LIB_F1_(struct tm *, tm)
{
	time_t result;
	int val;
	int x;

	tzset();

	val = tm->tm_year - 70;
	result = val * SECS_PER_YEAR
			+ ( val + 1) / 4 * SECS_PER_DAY;

	for ( x = 0; x < tm->tm_mon; x++ ) {
		result += __days_per_month[x] * SECS_PER_DAY;
	}
	if ( val % 4 == 2 && tm->tm_mon > 1 ) {
		result += SECS_PER_DAY;
	}
	result += ( tm->tm_mday - 1 ) * SECS_PER_DAY;
	result += tm->tm_hour * SECS_PER_HOUR;
	result += tm->tm_min * SECS_PER_MINUTE;
	result += tm->tm_sec;
	if ( tm->tm_isdst ) {
		result -= __dst_offset;
	}
	if ( !__local_clock ) {
		result -= __lt_offset;
	}

	/*
	 *	Check we have a valid time.
	 *	If not, then result must be -1.
	 *	If so, re-setup the tm structure
	 *	to ensure all values set and normalised.
	 */
	if (result >= 0) {
		(void)memcpy(tm,localtime(&result),sizeof(struct tm));
	} else {
		result = -1;
	}
	return( result );
}

/*------------------------------------------------------------------------
 *							tzset
 *							=====
 *
 *	Synopsis
 *	~~~~~~~~
 *		#include <time.h>
 *		void  tzset (void);
 *
 *	Description
 *	~~~~~~~~~~~
 *	The 'tzset' function uses the contents of the environment variable TZ to
 *	override the value of the different external variables used to control
 *	local time settings.   The function 'tzset' is called by the 'asctime'
 *	function and may also be called by the user.
 *
 *	The 'tzset' function scans the contents of the TZ environment variable
 *	and assigns the different fields to the respective variable.
 *
 *	Returns
 *	~~~~~~~
 *	None		(but note the tzset() can change specified global variables)
 */

#define _LIBRARY_SOURCE

#include <time.h>
#include <ctype.h>
#include <limits.h>
#include <stdlib.h>

#define TRUE	1
#define FALSE	0
#define EOS 	'\0'

#define SECS_PER_MINUTE ((time_t)60)
#define SECS_PER_HOUR	((time_t)(60 * SECS_PER_MINUTE))
#define SECS_PER_DAY	((time_t)(24 * SECS_PER_HOUR))
#define SECS_PER_YEAR	((time_t)(365 * SECS_PER_DAY))

static char *_tzname[2];			   /* used by set_tz() for tzset() */
static char *old_tz = (char *)NULL;    /* same time zone used ? */


#ifdef __STDC__
#define _P_(params) params
#else
#define _P_(params) ()
#endif

static char *  designation _P_(( char *cptr ));
static char *  get_hms	   _P_(( char *cptr, time_t *t_offset ));
static time_t  get_num	   _P_(( char **cpptr ));
static char *  rule 	   _P_(( char *cptr, time_t *sw_time));
static char *  set_hms	   _P_(( char *cptr, struct tm *tmp));
static void    set_tz	   _P_(( int which, char *tz, int size ));

#undef _P_

static
time_t get_num _LIB_F1_(char **, cpptr)
{
	time_t val;

	val = 0;
	while ( isdigit( (unsigned char)**cpptr )) {
		val = val * 10 + **cpptr - '0';
		(*cpptr)++;
	}
	return( val );
}


static void set_tz _LIB_F3_ (int,	   which, \
							  char *,	tz, \
							  int,		size)
{
  if ( which == 0 ) {                   /* store the new std time zone name */
		(void)strncpy( _tzname[0], tz, size );
		_tzname[1] = _tzname[0] + size;
		*_tzname[1]++ = EOS;
	}
	(void)strncpy( _tzname[1], tz, size );	  /* store the new dst time zone name */
	_tzname[1][size] = EOS;
	return;
}


static char *designation _LIB_F1_( char *, cptr)
{
	if ( *cptr != ':' ) {               /* no leading colon allowed */
		while ( *cptr != EOS 
				&& *cptr != ',' 
				&& *cptr != '-' 
				&& *cptr != '+' &&
				!isdigit( *cptr )) {
			cptr++;
		}
	}
	return( cptr );
}


static char *get_hms _LIB_F2_( char *,	   cptr, \
								time_t *,	t_offset)
{
	int sgn;

	sgn = -1;
	if ( *cptr == '-' ) {           /* is east (-) or west (+/none) GMT ? */
		sgn = 1;
		cptr++;
	} else {
		if ( *cptr == '+' ) {
			cptr++;
		}
	}
	*t_offset = get_num( &cptr ) * SECS_PER_HOUR;	/* look for hours */
	if ( *cptr == ':' ) {                           /* look for minutes */
		cptr++;
		*t_offset += get_num( &cptr ) * SECS_PER_MINUTE;
		if ( *cptr == ':' ) {                       /* look for seconds */
			cptr++;
			*t_offset += get_num( &cptr );
		}
	}
	*t_offset *= sgn;						/* now correct east or west GMT */
	return( cptr );
}


static char *set_hms _LIB_F2_( char *,		   cptr, \
								struct tm *,	tmp)
{
	tmp->tm_hour = get_num( &cptr );	/* look for hours */
	if ( *cptr == ':' ) {               /* look for minutes */
		cptr++;
		tmp->tm_min = get_num( &cptr );
		if ( *cptr == ':' ) {           /* look for seconds */
			cptr++;
			tmp->tm_sec = get_num( &cptr );
		}
	}
	return( cptr );
}


static char *rule _LIB_F2_( char *,    cptr, \
							 time_t *,	sw_time)
{
	struct tm tm;						/* for use with mktime() */
	time_t now; 						/* current time */
	int cwday;							/* current day of the week */
	int week;							/* week when SDT changes */
	int day;							/* weekday when SDT changes */
	int yday_offset;					/* correct julian day of the year */
	int save_lclk;						/* old locla_clock value */

	save_lclk = __local_clock;
	__local_clock = TRUE;				/* avoid local time offset */
	yday_offset = 0;
	now = time((time_t *)NULL);
	now += __lt_offset; 				/* get local time */
	if ( __dst_switch ) {
		now += __dst_offset;			/* for back-switch add dst offset */
	}
	tm = *gmtime( &now );
	tm.tm_hour = 2; 					/* default changing time is 02:00:00 */
	tm.tm_min = 0;
	tm.tm_sec = 0;
	cptr++;
	switch ( *cptr ) {
		case 'M' :						/* month.week.day style */
			cptr++;
			tm.tm_yday = 0; 			/* avoid mktime() to recognize yday */
			tm.tm_mon = get_num( &cptr ) - 1;		/* get month */
			if ( *cptr++ == '.' ) {     /* look for week */
				week = (int)get_num( &cptr );
				if ( *cptr++ == '.' ) {
					day = (int)get_num( &cptr );
					/*
					 *	POSIX 1003.1 says: Week 5 means the last d day in
					 *	month m.  Week 1 is the first week in which the 
					 *	d'th day occurs.  Day zero is Sunday.
					 */
					tm.tm_mday = 1; 	/* what is the 1st day ? */
					if ( week == 5 ) {
						tm.tm_mday = __days_per_month[tm.tm_mon] - 6;
						if ( tm.tm_year % 4 == 2 && tm.tm_mon == 1 ) {
							tm.tm_mday++;
						}
						week = 1;
					}
					cwday = ( mktime( &tm ) / SECS_PER_DAY + 4 ) % 7;
					tm.tm_mday += ( day - cwday + 7 ) % 7 + ( week - 1 ) * 7;
					if ( *cptr == '/' ) {
						cptr = set_hms( ++cptr, &tm );
					}
					*sw_time = mktime( &tm );
				}
			}
			break;
		case 'J' :						/* julian day from 1 to 365 */
			cptr++;
			yday_offset = -1;			/* struct tm counts from 0 to 365 */
			if ( tm.tm_year % 4 == 2 && tm.tm_yday > 59 ) {
				yday_offset -= 1;		/* no 29th February */
			}
		default :	/* should be 0-9 */ /* julian day from 0 to 365 */
			tm.tm_yday = yday_offset + get_num( &cptr );
			if ( *cptr == '/' ) {
				cptr = set_hms( ++cptr, &tm );
			}
			*sw_time = mktime( &tm );
			break;
	}
	__local_clock = save_lclk;			/* restore old value */
	return( cptr );
}


/*
 *	Scan the TZ environment variable and handle the information given.
 *	Set also the tzname variable with the given designation(s).
 */
void  tzset _LIB_F0_(void)
{
	char *tz, *cptr;
	time_t swap;

	tz = getenv("TZ");
	if ( tz != (char *)NULL && tz != old_tz ) {
		if ( old_tz != (char *)NULL ) {
			free( tzname[0] );
		}
		_tzname[0] = (char *)malloc( strlen( tz ) + 2 );
		old_tz = tz;					/* avoid unnesessary work */
		__local_clock = FALSE;			/* system clock is GMT */
		if ( *tz == ':' ) {             /* implementation specific timezone */
			__local_clock = TRUE;		/* system clock is local time */
			tz++;
		}
		cptr = designation( tz );		/* look for the std time zone */
		if ( cptr - tz >= 3 ) {         /* must be at least 3 bytes */
			set_tz( 0, tz, cptr - tz );
			tz = cptr;
			cptr = get_hms( tz, &__lt_offset );
			if ( __lt_offset || cptr - tz ) {   /* there must be an offset */
				tzname[0] = _tzname[0]; 		/* seems to be valid, install */
				tzname[1] = _tzname[1];
				__dst_offset = 0;				/* clear dst time offset */
				tz = cptr;
				cptr = designation( tz );		/* look for the dst time zone */
				if ( cptr - tz >= 3 ) {         /* must be at least 3 bytes */
					set_tz( 1, tz, cptr - tz );
					cptr = get_hms( cptr, &__dst_offset );
					if ( !__dst_offset ) {
						__dst_offset = SECS_PER_HOUR;
					}
					if ( *cptr == ',' ) {       /* now look for start and end of dst */
						__dst_switch = LONG_MAX;/* use max time to avoid switch */
						__back_switch = 0;		/* use min time to avoid switch */
						cptr = rule( cptr, &__dst_switch );
						if ( *cptr == ',' ) {
							cptr = rule( cptr, &__back_switch );
						}
						__n_hemi = TRUE;
						if ( __back_switch != 0 
						&& __back_switch < __dst_switch ) { 
											/* looks like southern hemisphere */
							swap = __dst_switch;
							__dst_switch = __back_switch;
							__back_switch = swap;
							__n_hemi = FALSE;
						}
					}
				}
			}
		}
	}
	return;
}
