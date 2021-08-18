/*
 *  Emulation of UNIX sleep call
 *
 *  Ideally we would like an emulation of the alarm
 *  call to implement this completely.
 */

#include <qdos.h>
#include <time.h>
#include <unistd.h>

unsigned  int sleep (seconds)
unsigned  int seconds;
{
    time_t  endtime, reply;

    endtime = time((time_t *)NULL) + seconds;
    (void) mt_susjb((jobid_t)(-1L),(timeout_t)(50*seconds),(char *)NULL);
    reply = endtime - time((time_t *)NULL);
    return (unsigned)((reply > 0) ? reply : 0);
}
