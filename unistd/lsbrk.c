/*
 *          l s b r k
 *
 *  Level 1 memory allocation routine.
 *  (UNIX compatible routine)
 *
 *  This is the lowest level of memory allocation
 *  within a C program.     It is tries to satisfy the
 *  memory request from the current free memory pool
 *  held by the program, and if that fails to increase 
 *  the size of the free memory pool by allcoating more
 *  memory from QDOS.
 *
 *  The allocation of new memory from QDOS is
 *  controlled by the settings of various global
 *  variables (which the user can optionally set).
 *  Checks are therefore performed before allowing
 *  new allocations to proceed.
 *
 *
 *  AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~~
 *  12 Jul 93   DJW   - Removed assumption that mt_alloc() sets _oserr.
 *
 *  10 May 96   DJW   - Took advantage of fact that mt_alchp() now accepts
 *                      NULL as the 'sizegot' parameter when result no needed.
 *
 *   8 Jun 96   RZ    - changed to use system call functionality of
 *                      signal extension v3
 */

#define __LIBRARY__

#include <unistd.h>
#include <errno.h>
#include <qdos.h>
#include <assert.h>
#include <sys/signal.h>

char *_mheap = (char *)NULL;        /* Pointer to level 1 maintained Heap Areas */
char *_mbase = (char *)NULL;        /* Free memory list */
long  _mfree = 0L;                  /* Amount of memory in free memory list */
long  _mtotal = 0L;                 /* Total memory allocated so far */

extern  long  _memmax;              /* Maximum memory we are allowed to allocate */
extern  long  _memqdos;             /* Amount we must leave for QDOS */
extern  long  _memincr;             /* Minimum increment size */

static void *sys_lsbrk _LIB_F1_ (long,   lnbytes )
{
    char *ret;
    long  newlen, maxlen, lenbytes;

    /*
     *  Sanity check on length requested
     */
    if (lnbytes <= 0L) 
    {
        errno = EINVAL;
        return (char *) NULL;
    }
    /*
     *  Round up size to multiple of allocation unit, and then
     *  try to get some memory from current allocated free memory pool
     */
    lenbytes = newlen = (lnbytes + MELTSIZE-1) & ~(MELTSIZE-1);
    if ((long)(ret = mt_alloc (&_mbase, &newlen)) > 0) 
    {
        /* Length set by mt.alloc trap so we do not need to do it here ! */
        /*  *(long *)ret = newlen;  */      /* Set true length in first 4 bytes */
        _mfree -= newlen;                   /* reduce free memory count */
        return ((void *)ret);
    }
    /*
     * There is no memory in the free memory pool (or at least
     * no area big enough).  We need to get more memory from QDOS!
     *
     *  We actually need an additional header at the start of each area
     *  allocated as we keep them linked on a 'allocated' chain.
     *  This is used by the mechanism for releasing memory so that it is
     *  possible to release areas back to QDOS if all of an area later
     *  becomes free again.
     */
    lenbytes += MELTSIZE;
    /*
     *  We now need to decide what size area to grab.   It must
     *  obviously be large enough for the current allocation, but
     *  we also need to consider the following:
     *      a)  We cannot exceed total free memory
     *      b)  We must leave value set in _memqdos for QDOS use.
     *      c)  We must not exceed the total memory allocation this
     *          program is allowed as set in _memmax.
     *      d)  We must ensure that the unit of allocation is at least
     *          as large as the value in _memincr (if this is zero,
     *          then we are not allowed to increase memory).
     */
    newlen = mt_free() - _memqdos;                  /* Maximum we could grab */
    maxlen = _memmax - _mtotal;                     /* Maximum we are allowed */
    if (newlen > maxlen) newlen = maxlen;           /* set to smaller of these*/

    if ( (_memincr <= 0L)                           /* are we allowed more memory */
    ||   (newlen < lenbytes) )                      /* and is there enough ? */
    {
        errno = ENOMEM;
        return NULL;
    }
    if (newlen > _memincr)
    {
        if (lenbytes < _memincr)
        {
            newlen = _memincr;
        }
        else
        {
            newlen = lenbytes;
        }
    }
    /*
     *  Grab memory from QDOS.
     *  N.B.  QDOS may actually allocate a slightly larger
     *        area than we asked for, but we ignore that !
     */
    ret = mt_alchp(newlen, NULL, (jobid_t)(-1L));
    if ((long)ret <= 0)
    {
        errno = ENOMEM;
        return NULL;
    }
    /*
     *  Add area grabbed to our own private heaps.
     *  It needs to be added to both the list of areas allocated
     *  and also to the free memory list.
     */
    mt_lnkfr(ret, &_mheap, newlen);                 /* Allocated areas */
    _mtotal += newlen;                              /* new total allocated */
    newlen  -= MELTSIZE;                            /* adjust for our header */
    mt_lnkfr (ret + MELTSIZE, &_mbase, newlen);     /* Our free memory list */
    _mfree  += newlen;                              /* current free memory */
    /*
     *  Now try to give the user his actual memory requested
     *  by calling ourselves recursively.
     */
    return (sys_lsbrk (lnbytes));
}

void *lsbrk _LIB_F1_ (long,   lnbytes )
{
    struct SYSCTL sctl;

    if (SYSCALL1(0,&sctl,sys_lsbrk,lnbytes) < 0)
    {
        return sys_lsbrk(lnbytes);
    }

    if (sctl.pending & _SIG_FTX)
    {
        (void)raise(SIGSEGV);
        errno = EFAULT;
        return NULL;
    }
    return (void *)sctl.rval;
}

