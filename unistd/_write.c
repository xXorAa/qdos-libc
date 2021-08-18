/*
 *                  w r i t e _ c
 *
 *  Simulate the UNIX 'write' System call
 *
 * Routine handles writing to all the different
 * types of device.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  11 Jul 93   DJW   - Removed asumption that io_sstrg() sets _oserr.
 *
 *  25 Sep 93   DJW   - Added support for O_SYNC mode writes
 *
 *  11 Jul 95   RZ    - fix to return EINTR when interrupted.
 *
 *  12 Nov 95   DJW   - added support for UFB_NB (Posix O_NONBLOCK) flag
 *                    - Now get timeout via support routine to allow for
 *                      the setting of the UFB_ND and UFB_NB flags.
 *
 *  08 Jun 96   RZ    - changed to use system call functionality of
 *                      signal extension, corrected small bug in error
 *                      reporting
 *
 *  08 Aug 98   DJW   - Included changes for socket handling.
 *                      (based on changes supplied by Jonathan Hudson)
 */

#define __LIBRARY__

#include <qdos.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <sys/signal.h>
#include <sys/socket.h>

#ifdef TESTING
#include <stdio.h>
#endif

#define min(x,y) ((x) > (y) ? (y) : (x))

static int sys_write  _LIB_F3_( int,           fd,     \
                         void *,        buf,    \
                         unsigned int,  len)
{
    UFB_t *   uptr;
    long      tot_written;
    chanid_t  chid;
    timeout_t timeout;
    long      to_write;
    long      num_written;

    sigset_t  *pf;
    int       is_atomic;


    /*
     *  Start with some sanity checks
     */
    if ((uptr = _Chkufb(fd))== NULL)
    {
        return -1;
    }

    if ((uptr->ufbflg & UFB_WA) == 0)
    {
        errno = EACCES;
        return -1;
    }

    /* Determine whether call should be interruptible */

    is_atomic = ( uptr->ufbtyp == D_DISK);
    pf = (sigset_t *)SYSCTL(is_atomic ? 0 : SCTL_EXP);

    /* 
     *  If NULL device, simply ignore and pretend
     *  that it worked without error
     */
    if( uptr->ufbtyp == D_NULL)
    {
        return (int)len;
    }

    /* 
     *  If Append mode, ensure positioned at EOF
     */
    if (uptr->ufbflg & UFB_AP)
    {
        if (lseek(fd, 0L, 2) < 0)
        {
            return -1;
        }
    }

    chid = uptr->ufbtyp == D_SOCKET 
                        ? uptr->ufbfh1
                        : uptr->ufbfh;
    timeout = _GetTimeout(uptr);

    for ( tot_written = num_written = 0 ;
             (to_write = len) > 0L  && (is_atomic || SYS_PENDING(pf)==0);
                (len -= num_written), (((char *)buf) += num_written))
    {
        switch (uptr->ufbtyp)
        {
        case D_SOCKET:
                return send(fd, buf,len, 0);
        case D_CON:
                /*
                 *  If no device driver code, simply
                 *  use the default output code.
                 */
                if (_conwrite == NULL)
                {
                    break;
                }
                /*
                 *  Call the device driver, and then
                 *  handle the return values.
                 */
                if ((to_write = (*_conwrite)(uptr, buf, len)) == 0)
                {
                    /* Error occurred - errno already set */
                    return -1;
                }
                if (to_write < 0)
                {
                    /* negative value - characters handled by translate routine */
                    num_written = -to_write;
                    tot_written += num_written;
                    continue;
                }
                /* positive value - write out as normal */
                break;
        default:
                break;
        }
        /*
         *  Write out a string of data
         *  N.B. io_sstrg only handles writes < 32K
         */
        if (to_write > 0x7FFF)
        {
            to_write = 0x7FFF;
        }
        if ((num_written = io_sstrg( chid, timeout, buf,
                                    (short)to_write)) < 0)
        {
            switch (num_written) {

            case ERR_NC:    /* Acceptable in no delay reads only */
                    /* Not complete only valid if timeout zero */
                    if (uptr->ufbflg & UFB_SY)
                    {
                        (void) fs_flush (chid, timeout);
                    }
                    if (uptr->ufbflg & (UFB_ND|UFB_NB))
                    {
                        if (tot_written > 0)
                        {
                            return tot_written;
                        }
                        errno = EAGAIN;
                        return -1;
                    }
                    else
                    {
                        /* it must be a signal */
                        goto lab99;
                    }

            default:
                    errno = EOSERR;
                    _oserr = (int)num_written;
                    return -1;
            }
        }
        tot_written += num_written;
        if (num_written != to_write)
        {
            break;
        }
    }
    if (uptr->ufbflg & UFB_SY)
    {
        (void) fs_flush (chid, timeout);
    }
  lab99:
    if (tot_written == 0 && SYS_PENDING(pf) && ~is_atomic)
    {
        errno = EINTR;
        return -1;
    }
    return tot_written;
}

int write  _LIB_F3_( int,           fd,     \
                     void *,        buf,    \
                     unsigned int,  len)
{
    struct SYSCTL sctl;

    if (SYSCALL3(0,&sctl,sys_write,fd,buf,len) < 0)
    {
        return sys_write(fd,buf,len);
    }

    if (sctl.pending & _SIG_FTX)
    {
        errno = EFAULT;
        return -1;
    }
    return sctl.rval;
}

