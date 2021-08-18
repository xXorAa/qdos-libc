/*
 *      _ M o d e T a b
 *
 *  Table used by support routines when converting
 *  modes between level1 I/O and UFB flags.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  12 Nov 95   DJW   - First version.  Introduced while tidying up the
 *                      handling within the library of the O_NONBLOCK flag.
 */

#define __LIBRARY__

#include <fcntl.h>


/*
 *  Table used to provide translation between
 *  level 1 and ufb flags
 */
struct _MODE_TABLE _ModeTable[] = {
            {UFB_RA|UFB_WA, O_RDWR,         O_RDONLY | O_WRONLY | O_RDWR},
            {UFB_RA,        O_RDONLY,       O_RDONLY | O_WRONLY | O_RDWR},
            {UFB_WA,        O_WRONLY,       O_RDONLY | O_WRONLY | O_RDWR},
            {UFB_AP,        O_APPEND,       O_APPEND},
            {UFB_NT,        O_RAW,          O_RAW},
            {UFB_ND,        O_NDELAY,       O_NDELAY},
            {UFB_SY,        O_SYNC,         O_SYNC},
            {UFB_NB,        O_NONBLOCK,     O_NONBLOCK},
            {UFB_NT,        O_RAW,          O_RAW},
            {0,0,0}
            };

