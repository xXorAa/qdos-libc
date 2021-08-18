/*
 *		s t r f t i m e
 *
 *	ANSI/POSIX compatible routine to converts a struct tm to
 *	a text string under the guidance of a format string.
 *
 *	Also supports the following extensions to the ANSI/POSIX
 *	standards:
 *		%e		Day of month  1-31
 *		%R		Time as %H:%M
 *		%z		Time difference to GMT	([+|-]%H%M)
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	30 Aug 93	DJW   - First version
 *						Heavily based on the POSIX 1003.1-1988 compatible
 *						time handling package by Ralf Wenk.
 *
 *	05 Mar 95	DJW   - Added support for 'U' and 'W' options.
 *					  - On error condition, result is now always zero.
 *					  - Parameters now defined using _LIB_F4_ macro.
 *
 *	10 Nov 95	DJW   - Added support for 'c', and 'x' options.
 *					  - Corrected 'x' option (it was really 'X' option)
 *					  - Changed to calling this routine recursively to
 *						simplify some of the more complex combinations.
 *
 *	07 Jan 99	DJW   - Fixed problem (Y2K related I suspose) where the %y
 *						option only returned 1 digit if year less that 10.
 *						(bug report and fix provided by Jonathan Hudson)
 */

#define _LIBRARY_SOURCE

#include <time.h>
#include <string.h>
#include <stdio.h>


#define TRUE	1
#define FALSE	0
#define EOS 	'\0'
#define SECS_PER_MINUTE ((time_t)60)
#define SECS_PER_HOUR	((time_t)(60 * SECS_PER_MINUTE))
#define SECS_PER_DAY	((time_t)(24 * SECS_PER_HOUR))
#define SECS_PER_YEAR	((time_t)(365 * SECS_PER_DAY))

/*
 * Strftime places its output controled by the format string and by the
 * values in struct tm into the string starting at s. The maximum length of
 * the output string is specified by max, including the \0 character. It
 * returns the number of characters placed into s (excluding \0), or zero
 * if the output string would exceed maxsize.
 */

size_t strftime _LIB_F4_( char *,			 s, \
						  size_t,			 max, \
						  const char *, 	 fmt, \
						  const struct tm *, tmp)
{
	static char *lfmt[] = {"%c",
						   "%02d/%02d/%02d",
						   "%02d",
						   "%d",
						   "%.3s",
						   "%2d",
						   "%03d",
						   "%02ld%02ld"
						   };
	char cbuff[26]; 	  /* local expansion buffer */
	char *m_ptr;		  /* points to am or pm */
	int result;
	int yweek,start_of_week_day;
	time_t gmt_offset;	  /* used for %z */

	tzset();
	*s = EOS;
	m_ptr = tmp->tm_hour < 12 ? "AM" : "PM";
	max--;										/* remember \0 */
	while ( *fmt != EOS && max != 0 ) {
		if ( *fmt != '%' ) {
			(void)sprintf( cbuff, lfmt[0], *fmt );
		} else {
			switch ( *++fmt ) {
				case EOS:						/* nothing left to do */
					fmt--;
					cbuff[0] = EOS;
					break;
				case '%':						/* % */
					(void)strcpy( cbuff,"%");
					break;
				case 'a':						/* abbreviated weekday name */
					(void)sprintf( cbuff, lfmt[4], __week_day[tmp->tm_wday] );
					break;
				case 'A':						/* full weekday name */
					(void)strcpy( cbuff, __week_day[tmp->tm_wday] );
					break;
				case 'b':						/* abbreviated month name */
					(void)sprintf( cbuff, lfmt[4], __month[tmp->tm_mon] );
					break;
				case 'B':						/* full month name */
					(void)strcpy( cbuff, __month[tmp->tm_mon] );
					break;
				case 'c':						/* Local appropriate date/time */
					(void) strftime (cbuff,sizeof(cbuff),"%a %b %d %X %Y",tmp);
					break;
				case 'd':						/* day of month (01-31) */
					(void)sprintf( cbuff, lfmt[2], tmp->tm_mday );
					break;
/* POSIX */ 	case 'D':						/* date as %m/%d/%y */
					(void)sprintf( cbuff, lfmt[1], tmp->tm_mon, tmp->tm_mday, tmp->tm_year );
					break;
/* EXTENSION */ case 'e':						/* day of month ( 1-31) */
					(void)sprintf( cbuff, lfmt[5], tmp->tm_mday );
					break;
/* POSIX */ 	case 'h':						/* abbreviated month name */
					(void)sprintf( cbuff, lfmt[4], __month[tmp->tm_mon] );
					break;
				case 'H':						/* hour (00-23) */
					(void)sprintf( cbuff, lfmt[2], tmp->tm_hour );
					break;
				case 'I':						/* hour (00-12) */
					(void)sprintf( cbuff, lfmt[2], tmp->tm_hour % 12 );
					break;
				case 'j':						/* day number of year (001-366) */
					(void)sprintf( cbuff, lfmt[6], tmp->tm_yday + 1 );
					break;
				case 'm':						/* month number (01-12) */
					(void)sprintf( cbuff, lfmt[2], tmp->tm_mon + 1 );
					break;
				case 'M':						/* minute (00-59) */
					(void)sprintf( cbuff, lfmt[2], tmp->tm_min );
					break;
/* POSIX */ 	case 'n':						/* Newline (\n) */
					(void)strcpy( cbuff,"\n");
					break;
				case 'p':						/* ante meridian or post meridian */
					(void)strcpy( cbuff, m_ptr );
					break;
/* POSIX */ 	case 'r':						/* time as %H:%M:%S %p */
					(void)strftime (cbuff,sizeof(cbuff),"%T %p",tmp);
					break;
/* EXTENSION */ case 'R':						/* time as %H:%M */
					(void)strftime (cbuff,sizeof(cbuff),"%H:%M",tmp);
					break;
				case 'S':						/* seconds (00-59) */
					(void)sprintf( cbuff, lfmt[2], tmp->tm_sec );
					break;
/* POSIX */ 	case 't':						/* Tab (\t) */
					(void)strcpy( cbuff,"\t");
					break;
/* POSIX */ 	case 'T':						/* time as %H:%M:%S */
					(void)strftime (cbuff,sizeof(cbuff),"%R:%S",tmp);
					break;
				case 'U':						/* year week (Sunday start) */
					start_of_week_day = 0;
					yweek = ((tmp->tm_wday + 7 - start_of_week_day) % 7)
								- ((tmp->tm_yday) % 7) <= 0;
					yweek += tmp->tm_yday / 7;
					(void)sprintf( cbuff, lfmt[2], yweek);
					break;
				case 'w':						/* weekday number (Sunday = 0) */
					(void)sprintf( cbuff, lfmt[3], tmp->tm_wday );
					break;
				case 'W':						/* year week (Monday start) */
					start_of_week_day = 1;
					yweek = ((tmp->tm_wday + 7 - start_of_week_day) % 7)
								- ((tmp->tm_yday) % 7) <= 0;
					yweek += tmp->tm_yday / 7;
					(void)sprintf( cbuff, lfmt[2], yweek);
					break;
				case 'x':						/* date as wday Mon day, year */
					(void)strftime(cbuff,sizeof(cbuff),"%a %b %d, %Y",tmp);
					break;
				case 'X':						/* time as %H:%M:%S */
					(void)strftime (cbuff,sizeof(cbuff),"%R:%S",tmp);
					break;
				case 'y':						/* year within century (00-99) */
					(void)sprintf( cbuff, lfmt[2], tmp->tm_year % 100 );
					break;
				case 'Y':						/* year as ccyy */
					(void)sprintf( cbuff, lfmt[3], tmp->tm_year + 1900 );
					break;
/* EXTENSION */ case 'z':						/* time ahead of GMT ([+|-]%H%M) */
					gmt_offset = __lt_offset;
					if ( tmp->tm_isdst ) {
						gmt_offset += __dst_offset;
					}
					cbuff[0] = '+'; 			/* default is east of Greenwich */
					if ( gmt_offset < 0 ) {     /* no, we are west */
						gmt_offset = - gmt_offset;
						cbuff[0] = '-';
					}
					(void)sprintf( &cbuff[1], lfmt[7], gmt_offset / SECS_PER_HOUR,
							( gmt_offset % SECS_PER_HOUR ) / SECS_PER_MINUTE );
					break;
				case 'Z':						/* time zone name */
					(void)strcpy( cbuff, tzname[tmp->tm_isdst] );
					break;
				default:
					(void)sprintf( cbuff, lfmt[0], *fmt );
					break;
			}
			if ( max < strlen( cbuff )) {
				cbuff[max] = EOS;
			}
		}
		(void)strcat( s, cbuff );
		max -= strlen( cbuff );
		fmt++;
	}
	if (*fmt != EOS) {
		result = 0;
	}
	if ( result) {
		result = strlen( s );
	}
	return( result );
}
