/*
 *          q d i r _ r e a d / q d i r _ d e l e t e
 *
 *  qdir_read:      Create a sorted, linked QDOS directory list,
 *                  given a device and wildcard name.
 *  qdir_delete:    Delete a linked list create by qdir_read().
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  10 Jul 93   DJW     Removed assumption that io_open() sets _oserr.
 *  11 Jul 93   DJW     Removed assumption that io_fstrg() sets _oserr.
 *  15 Aug 93   DJW     Removed 'err' parameter.  Now always set errno
 *                      if an error occurs, and also _oserr if it was
 *                      a QDOS level error.
 *  22 Oct 93   DJW   - Code for qdir_read() restructured to use internal
 *                      library routines shared with read_qdir() routine.
 *                      This has the by-product that there is now only one
 *                      occurence of this code (and thus place to fix errors!).
 *                    - The DIR_LIST structure was changed so that the C name
 *                      is now at the end of the structure, and is part of the
 *                      structure rather than being a separate field.  This
 *                      means that only one area is allocated and freed rather
 *                      than two which should be more effecient.  It does mean
 *                      however, that the DIR_LIST structure is variable
 *                      length, bu this should not matter (I hope!).
 */

#define __LIBRARY__

#include <qdos.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

struct DIR_LIST *qdir_read _LIB_F3_(char *, devwc, \
                                    char *, stext, \
                                    int,    attr)
{
    chanid_t chid;
    struct DIR_LIST *first, *dp, *p;
    struct qdirect dr;
    int  isdev, num_up;
    char device[12];
    char ndevwc[MAXNAMELEN+1];
    char wc[MAXNAMELEN+1];
    char cname[MAXNAMELEN];
    char cwd[MAXNAMELEN];
    char *gtp;

    /*
     *  First the preperation work
     */
    if (_read_qdir_prep (devwc, ndevwc, wc, &isdev, device, cwd, &gtp, &num_up)) {
        /*
         *  errno should already be set !
         */
        return NULL;
    }
    /*
     *  Now open the device + directory
     */
    if ((chid = io_open( ndevwc, DIROPEN)) < 0 ) {
        _oserr = (int)chid;
        errno = EOSERR;
        return NULL;
    }

    /*
     *  Now read the directory, file by file
     */
    for (first = NULL, p = NULL ; ; ) {
        switch (_read_qdir_action(chid, devwc, cname, &dr, attr, wc, gtp, isdev, device, num_up)) {
        case 0:     /* EOF */
                /*
                 *  EOF:  Close the directory
                 *        ... and clear errno for good exit
                 */
                (void) io_close( chid );
                errno = 0;
                /*
                 *  Sort the linked list - if there is a sort order
                 */
                if ( stext && *stext) {
                    return qdir_sort( first, stext, NULL);
                }
                return first;

        case -1:    /* error */
                qdir_delete( first );
                /*
                 *  errno will already have been set
                 */
                return (NULL);

        default:    /* Good read */
                /*
                 *  Copy the directory details and C name
                 *  just read into allocated space
                 */
                if(!( dp = (struct DIR_LIST *)malloc( sizeof (struct DIR_LIST)
                                                      + strlen (cname) ))) {
                    qdir_delete( first );
                    errno = ENOMEM;
                    return (NULL);
                }
                dp->dl_dir = dr; /* Structure assign direct */
                (void) strcpy (dp->dl_cname, cname);
                /*
                 *  Link the directory just read onto the list
                 */
                dp->dl_next = (struct DIR_LIST *)NULL;
                if( !first ) {
                    first = dp;
                } else {
                    p->dl_next = dp;
                }
                p = dp;
                break;
        } /* end of switch */
    } /* end of for loop */
}

/*----------------------------------------------------------------------*/

void qdir_delete _LIB_F1_( struct DIR_LIST *, list)
{
    struct DIR_LIST *p, *q;

    if( !list ) {
        return;
    }
    for( p = list, q = p->dl_next; p ; p = q, q = q ? q->dl_next : NULL) {
        free( (void *)p );
    }
    return;
}

