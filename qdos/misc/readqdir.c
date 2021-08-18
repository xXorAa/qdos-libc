/*
 *          r e a d q d i r _ c
 *
 *  Read a QDOS directory entry, only returning entries
 *  that match required name and attributes.
 *
 *  Return values:
 *      1   OK
 *      0   End of File reached
 *     -1   Error occurred.  errno (and possibly _oserr) set appropriately.
 *
 *  Amendment History
 *  ~~~~~~~~~~~~~~~~~
 *  25 Jul 92   DJW   - Incorrectly checked length of 'ndevwc' instead of 'devwc'
 *                      (reported by Dirk Steinkopf)
 *  11 jul 93   DJW   - Removed assumption that io_fstrg() sets _oserr.
 *  18 Aug 93   DJW   - Ensured that 'errno' set to EOSERR when _oserr
 *                      contains a valid error code.
 *  22 Oct 93   DJW   - Restructured so that most of the code is in two
 *                      routines that are internal to the library, so that
 *                      they can be shared with the qdir_read() routine.
 *                    - Fixed problem which meant that file types outside
 *                      the expeced range always got returned, whatever the
 *                      selection criteria.
 *                    - Added consistency check to directory file type for
 *                      the file length being a multiple of 64.  This is to
 *                      cater for packages such as SPECULATOR which can use
 *                      more file types than is traditional under QDOS.
 */

#define __LIBRARY__

#include <qdos.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>


/*
 *-------------------------------------------------------------
 *  Internal library support routine that prepares to
 *  read a QDOS directory.  This routine is also called
 *  from the qdir_read() routine.
 *-------------------------------------------------------------
 */

int  _read_qdir_prep _LIB_F8_ (char *,  devwc, \
                               char *,  ndevwc, \
                               char *,  wc, \
                               int *,   isdev, \
                               char *,  device, \
                               char *,  cwd, \
                               char **, gtp, \
                               int *,   num_up)
{
    int     devtype;
    short   i, num;

    /*
     *  Start with a quick sanity check
     */
    if( strlen(devwc) > MAXNAMELEN) {                                   /* v3.02 */
        errno = EINVAL;
        return -1;
    }
    /*
     *  If no device passed, then put the 
     *  default data device in front
     */
    if( !(*isdev = isdevice( devwc, &devtype ))) {
        (void) getcwd(cwd,MAXNAMELEN);
        if((*num_up = _qlmknam( ndevwc, cwd, devwc, MAXNAMELEN)) < 0) {
            /*
             *  N.B. errno set by _qlmkname() routine
             */
            return -1;
        }
    } else {
       /*
        *  Device was passed.
        *  Check it's a directory device
        */
        if (!(devtype & DIRDEV)) {
            errno = EINVAL;
            return -1;
        }
        (void) strcpy( ndevwc, devwc);
    }

    /*
     *  First split device and wildcard name
     *  Go past either one or 2 '_'s
     */
    for( *gtp = ndevwc, num = (devtype & NETDEV) ? (short)2 : (short)1 ; 
                                                num; (*gtp)++, num--) {
        while  (**gtp != '_') {
            (*gtp)++;
        }
    }

    i = (short)(*gtp - &ndevwc[0]);
    (void) strncpy( device, ndevwc, (size_t)i);
    device[i] = '\0'; /* Terminate the string correctly */
    (void) strcpy( wc, &ndevwc[i]);
    return 0;
}

/*
 *-------------------------------------------------------------------
 *  Support routine which does action part of a directory read
 *  This routine also called from qdir_read() function.
 *-------------------------------------------------------------------
 */

int _read_qdir_action _LIB_F10_ (chanid_t,          chid, \
                                 char *,            devwc, \
                                 char *,            ret_name, \
                                 struct qdirect *,  ret_dir, \
                                 int,               attr, \
                                 char *,            wc, \
                                 char *,            gtp, \
                                 int,               isdev, \
                                 char *,            device, \
                                 int,               num_up)
{
    short   i;
    int     rd;
    char    fname[MAXNAMELEN+1];

    for(;;) {
        /*
         *  Now read a directory entry
         */
        if((rd =io_fstrg(chid,(timeout_t)-1,(char *)ret_dir,DREADSIZE)) != DREADSIZE) {
            /* Didn't read an entry */
            if (rd == ERR_EF) {
                /* return Zero on EOF */
                return 0;
            } else {
                /* return error code otherwise */
                _oserr = rd;
                errno = EOSERR;
                return -1;
            }
        }
        /*
         *  If no file or name does not match wild name,
         *  then try to get next entry.
         */
        if ((ret_dir->d_szname == 0)
        ||  !fnmatch( qlstr_to_c(fname, (struct QLSTR *)&ret_dir->d_szname), wc)) {
            continue;
        }
        /*
         *  Ensure the file type wanted matches
         *  We only need to check if a sub-range
         *  of file types is wanted
         */
        if( attr != QDR_ALL) {
            switch (ret_dir->d_type) {
            case CST_DIR_TYPE:
            case THOR_DIR_TYPE:
                    /*
                     *  Check that length is a multiple of 64.  If not, then
                     *  this is not a directory, but the file type has been
                     *  used for some other purpose (such as SPECULATOR)
                     */
                    if (ret_dir->d_length % 64) {
                        goto DATATYPE;
                    }
                    /* FALLTHRU */
            case QF_DIR_TYPE:
                    /*
                     *  No Directories wanted ?
                     */
                    if (!(attr & QDR_DIR)) {
                        continue;
                    }
                    break;
            case QF_PROG_TYPE:
                    /*
                     *  No progs wanted ?
                     */
                    if (!(attr & QDR_PROG)) {
                        continue;
                    }
                    break;
            default:
                    /*
                     *  No data files wanted ?
                     */
DATATYPE:
                    if (!(attr & QDR_DATA)) {
                        continue;
                    }
                    break;
            }
        }
        /*
         *  If we get here, then we have read an entry
         *  successfully, so now create the 'C' name
         */
        if( isdev ) {
            (void) strcpy( ret_name, device);
            (void) strcat( ret_name, fname);
        } else {
            *ret_name = 0;
            for( i = 0; i < num_up; i++ )
                (void) strcat( ret_name, ".._");
            /*
             *  Name in directory entry is already in fname
             */
            (void) strcat( ret_name, &fname[ strlen(gtp) - strlen(devwc) + (num_up*3)]);
        }
        break;
    }
    /*
     *  Good return (a name was read)
     */
    return 1;
}


int read_qdir _LIB_F5_ (chanid_t,           chid, \
                        char *,             devwc, \
                        char *,             ret_name, \
                        struct qdirect *,   ret_dir, \
                        int,                attr) /* Types to read 0 = all,
                                                                   1 = data,
                                                                   2 = prog, 
                                                                   4 = directory */
{
    int  isdev, num_up;
    char device[12];
    char ndevwc[MAXNAMELEN+1];
    char wc[MAXNAMELEN+1];
    char cwd[MAXNAMELEN+1];
    char *gtp;

    if (_read_qdir_prep (devwc, ndevwc, wc, &isdev, device, cwd, &gtp, &num_up)) {
        return -1;
    }
    return _read_qdir_action(chid, devwc, ret_name, ret_dir, attr, wc, gtp, isdev, device, num_up);
}


