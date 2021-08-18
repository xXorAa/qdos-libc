/*
 *      p c l o s e
 *
 * Unix compatible routine to shut down a pipe
 * connection to another job.   Returns return
 * value from job we waited for, or -1 if error.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  19 Jun 93   DJW   - Removed redundant close for child pipe channel
 *                      (this has been done in popen() routine).

 */

#define __LIBRARY__

#include <qdos.h>
#include <stdio.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>

int pclose( fp )
FILE *fp;
{
    jobid_t     jobid;
    struct UFB  *uptr;
    int         retval;
    int         ret;

    if ((uptr = _Chkufb(fileno(fp)))==NULL) /* Check file exists */
        return -1;                      /* error exit if not */

    /*
     *  Do some sanity checks
     */
    if ((uptr->ufbtyp  != D_PIPE)         /* Check it could be popen'ed */
    || ((jobid  = uptr->ufbjob) == 0) ) { /* and Target job is set */
        return (-1);
    }

    (void ) fclose(fp);                 /* Close down this end of pipe */
    ret = waitfor(jobid, &retval);      /* Wait for specified job to finish */
    if( ret == -1)
        errno = EPERM;
    else
        ret = retval;

    return ret;
}

