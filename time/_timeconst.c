/*
 *      _ t i m e c o n s t
 *
 *  Constants used by various of the time routines.
 *
 *  Based on the version of POSIX compatible time routines
 *  produced by Ralf Wenk.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  29 Aug 93   DJW   - First version of this file
 */

#define _LIBRARY_SOURCE

#include <time.h>

char *tzname[2] = {"GMT"," "};  /* timezone name */

int __days_per_month[] = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

int    __local_clock = 1;       /* system clock is local time */
time_t __lt_offset  = 0;        /* offset between GMT and local tz */
time_t __dst_offset = 0;        /* offset between dst and local tz */
time_t __dst_switch = 0;        /* when do we switch to dst */
time_t __back_switch = 0;       /* and when do we switch back */
int    __n_hemi = 1;            /* we are in the northern hemisphere */

