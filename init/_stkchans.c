/*
 *  s t a c k c h a n n e l s
 *
 *  This routine is used to set up level 1 file descriptors
 *  for any channels passed on the stack.  There is one
 *  complication in that the first channel passed is set
 *  up as equivalent to fd=0, and the last as fd=1.
 *  Any others are set up as fd=2 upwards.
 *
 *  Another slight complication is that the top bit of
 *  the channel ID being set indicates that we ARE
 *  allowed to close the file from within this program.
 *
 *  NOTE: This is NOT standard QDOS behaviour, and should NOT
 *  be relied on. Instead you should make sure that the channel(s)
 *  are owned by the job. _frkex() does this, where needed.
 *
 *  If any channel has already been opened as a result
 *  of command line re-direction, then this overrides
 *  taking the value from the stack.  We will know that
 *  this has happened as the OPEN mask will already
 *  have the corresponding bit set.
 *
 *  Returns an updated copy of the channels OPEN mask, or
 *  a QDOS error code (negative) on error
 *
 *  It is vectored so that it is easy to omit this routine.
 *
 *  VERSION HISTORY
 *  ~~~~~~~~~~~~~~~
 *  12 Sep 92   DJW   - Changed code to common up handling for space effeciency.
 *                    - Changed to accept parameter showing channels already
 *                      open via command line re-direction.
 *                    - Changed entry point name to _stackchannels().
 *
 *  22 Oct 92   DJW   - Added code that allows top bit of channel ID to be
 *                      set to indicate a channel which despite being
 *                      passed on the stack, this program is allowed to
 *                      close.  Currently used for PIPEs.
 *
 *  31 Dec 93   DJW   - The vector for invoki  ng this code is moved to the
 *                      LIBC_DEFAULTS directory.
 *
 *  7  Apr 94   EAJ   - Changed to check the ownership of channels passed,
 *                      if channel owned by the job itself, then this also
 *                      indicates that we are allowed to close the channel
 *                      from within this program. This is safe, since QDOS
 *                      will eventually close the channel anyway, when the job
 *                      is removed. This change is accompanied by a corresponding
 *                      change in unistdfrkex_c. The previous behaviour,
 *                      involving setting a bit in the channel id, was
 *                      simply not QDOS compatible, and we do not want to
 *                      exclude C68-programs from co-operating with, say,
 *                      Q_Liberat'ed programs.
 *
 *  05 Sep 94   DJW   - General tidyup of code while tracing new startup code:
 *                    - Removed check that channel count did not have top bit
 *                      set as this seemed irrelevant.
 *                    - Ensured that if only ONE channel passed, then treated
 *                      as 'stdin' rather than 'stdout' as previously.
 *                    - Removed checks for top bit of channel ID being set.
 *                      This theoretically removes a certain amount of backwards
 *                      comaptibility, but as that feature never really worked
 *                      properly this is not seen as important.  Removing it
 *                      saves quite a bit of code, and as this module is in
 *                      (virtually) every C68 compiled program this matters.
 *                    - Removed inital check for total number of UFB's available.
 *                      Instead now check that we can get one when we need it.
 *
 *  07 May 95   DJW   - Small optimisations to code (no logic change) while
 *                      investigating possible pipe related problem.
 */


#define __LIBRARY__

#include <qdos.h>
#include <fcntl.h>
#include <stdlib.h>

long    _stkchans (long nc)
{
    int j, tc;
    long *chans;

    if ( (tc = *((short *)_SPorig)) == 0) {
        return nc;
    }

    chans = (long *)(_SPorig + 2); /* Set pointer to QDOS channel id's */

    /*
     *  Open up any channels passed to us.
     *  stdin will always be read only and stdout write only.
     *  All other channels have both read and write capability.
     *
     *  For each channel pased on the stack and accepted, set
     *  the corresponding bit in the 'nc' variable.
     */
    for( j = 0 ; j < tc  ; j++) {
        struct UFB *uptr;
        int     fd;
        long    mask;

        if ( j == 0) {
            fd = 0;                     /* stdin */
        } else if (j == tc-1) {
            fd = 1;                     /* stdout */
        } else {
            fd = j+1;                   /* stderr & others */
        }
        mask = 1 << fd;
        if ( (( nc & mask ) == 0)       /* Check for redirection open */
        &&   (chans[j] != -1L) ) {      /* ... and not wanted */
            uptr = _Newufb(fd);
            if (uptr == NULL) {
                exit (ERR_OM);
            }
            uptr->ufbfh = (chanid_t)chans[j];

            /* The test for the high bit kept for backwards comp. */

            if (_get_chown(uptr->ufbfh) == _Jobid) {
                uptr->ufbflg |= UFB_OP;
            } else {
                uptr->ufbflg |= (UFB_OP | UFB_NC);
            }
            uptr->ufbtyp = isatty(fd) ? (char)D_CON : (char)D_DISK;
            nc |= mask;
        }
    }

    return (long)nc;
}

