/*
 *              _ f s t a t
 *
 *  Support routine to used by the stat() and fstat()
 *  Unix compatible routines to enquire on file status.
 *
 *  Necessary to synthesize some of the required information
 *  as QDOS file structures are different to UNIX ones.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  10 Apr 93   DJW   - The way the INODE field is calculated is changed
 *                      to (hopefully) give more chance of a unique value
 *                      for any specific file.
 *
 *  10 Jul 93   DJW   - Removed dependency on _getcdb() setting _oserr.
 *
 *  11 Jul 93   DJW   - Removed dependency on fs_headr() setting _oserr.
 *
 *  22 Aug 93   DJW   - Ensure that count of blocks is rounded up if file
 *                      is not an exact multiple of block size.
 *
 *  28 Aug 93   DJW   - Removed assumption that it was possible to tell if
 *                      a channel belonged to a Directory Device by looking
 *                      at its size (this fails on SMSQ).   Now use the 
 *                      (new) routine _isfscdb() to scan the Directory
 *                      Driver list instead to see if driver there.
 *
 *  14 Oct 93   DJW   - Made into a support routine (that takes QDOS channel
 *                      instead of fd as parameter) as part of making stat
 *                      work on root directory of devices.
 *
 *------------------------------------------------------------------------
 *
 *  10 Dec 93   EMS   - (Eric Slagter) Rewritten to be fully Qdos/SMS 
 *                      compliant but without the need to look through
 *                      system data structures.
 *
 *                      This new version also supports the stat() and
 *                      fstat() calls on non-directory devices, unlike
 *                      the previous one.
 *
 *                      Finally, it is also better at trying to determine
 *                      the device type although not beleived to be fool-proof
 *                      except for local directory devices.
 *
 *  14 Dec 93   DJW   - Reworked part of the code to improve the size of
 *                      the generated code.
 *
 *  20 Dec 93   DJW   - Changed the entry point to this file to _fstat so
 *                      that is a plug compatible replacement for the
 *                      previous _fstat() routine.
 *
 *  17 Apr 94   EAJ   - Changed to use _fake_inode(), so inode values are
 *                      more consistent, and truly different for different
 *                      files. I have seen at least one case where the
 *                      previous method used returned the same inode value
 *                      for different files.
 *
 *  28 May 94   DJW   - Now return non-zero value that is error code on
 *                      failure.  This makes this routine suitable for
 *                      inclusion into a RLL.
 *                    - _fake_inode added to C68 distribution as standard feature.
 *                      The _fstat() library routine now calls this one.
 *
 *  09 Oct 94   DJW   - Small changes to BlockTypeToModeT() routine to generate
 *                      more effient code - no logic changed.
 *
 *  10 Aug 95   DJW   - Removed _super() and _user() calls as it appears that
 *                      the getcdb() routine need not be in supervisor mode
 *                      when it is called.   Suggested by Erling Jacobsen.
 *
 *  18 Jul 98   DJW   - The _fake_inode() routine merged into the _Fstat source
 *                      fiel as it is not sued from anywhere else.
 */

#define __LIBRARY__

#include <qdos.h>
#include <sys/stat.h>
#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <channels.h>

/*
 *  Based on the routine by Eric Slagter, but rotates instead of
 *  shifting, to make all characters significant, not just the ones
 *  that are not shifted out of the 32 bit range.
 */
#define BITS_IN_INO ((int)(8*sizeof(ino_t))) /* not 100% portable, but almost */ 

static
ino_t   NameToIno _LIB_F1_(const struct QLSTR *,    qlstr)
{
    ino_t   res = ULONG_MAX;
    short   len = qlstr->qs_strlen;

    while(--len >= 0 )
    {
        res = ((res & 7) << (BITS_IN_INO-3)) +       /* wrap lowest 3 bits */
              ((unsigned int)res >> 3);              /* shift the rest     */

        res ^= qlstr->qs_str[len];
    }

    return res;
}

/*
 *  Get a suitable value for "inode". 
 *
 *  This routine was developed, because I didn't like the previously used ways
 *  of faking the inode value: using the file date (what about the result
 *  of fast wcopy type actions, which may leave lots of files with the same
 *  date.)
 *
 *  Also, using just this one routine ensures that the inode values returned
 *  by different types of function for the same file will indeed be the same.
 *
 *  My intention when writing this routine was that I would use the drive ID /
 *  file ID pair to make an inode. Unfotunately, SMS2 / QXL /SMSQ, don't
 *  seem to supply unique values here, so I cannot use this, but use the
 *  same algorithm as Eric Slagter (corrected for the bug, by rotating instead
 *  of shifting, thereby loosing information on long names).
 *
 *  Erling Jacobsen, Apr 1994
 */

static
ino_t _fake_inode _LIB_F1_(chanid_t,  channel)
{
    struct fs_cdefb  *cdb;
    struct chan_defb *chdefb;

    chdefb = _getcdb(channel);
    cdb = (struct fs_cdefb *) chdefb;

    /*
     *  If not a file system file, return something which will
     *  still be unique, at least among all non file system files.
     *  I don't know if the inode value will ever be needed in such
     *  a case, but better safe than sorry!
     */

    if( (long)_isfscdb(chdefb) == 0L )
    {
        return (ino_t) (0x80000000UL | (unsigned long)channel);
    }

    return NameToIno( &cdb->fs_name );
}






/* This function tries to construct a unique device number from a   */
/* given device name. It assumes that the device name consists of   */
/* three letters followed by a drive number and an underscore. It   */
/* works with other forms as well but maybe not producing a unique  */
/* device number. Note that this trick only works for level II      */
/* device driver as only then the device name is known.             */

static  dev_t   DevNameToDevT _LIB_F1_(const struct QLSTR *, qlstr)
{
    dev_t   res;
    short   length;

    for (res=0, length=qlstr->qs_strlen ; length > 0 ; length--)
    {
        res <<= 8;
        res  |= qlstr->qs_str[length];
    }

    return(res);
}


/* This function composes the mode for simple devices. This means a.o.  */
/* that the channel is on a character special device, hence the S_IFCHR. */
/* Only for executable files the x-bit is set.                          */

static  mode_t  SimpleTypeToModeT _LIB_F1_(unsigned char, type)
{
    mode_t  res;

    switch(type)
    {
        case(QF_PROG_TYPE):
        {
            res = S_IRWXU | S_IRWXG | S_IRWXO | S_IFCHR;
            break;
        }

        case(THOR_DIR_TYPE):
        case(CST_DIR_TYPE):
        case(QF_DIR_TYPE):
        {
            res = S_IRWXU | S_IRWXG | S_IRWXO | S_IFDIR | S_IFCHR;
            break;
        }

        default: /* data */
        {
            res = S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP |
                  S_IROTH | S_IWOTH | S_IFCHR;
            break;
        }
    }

    return(res);
}

/* This function works the mode out for block devices. Level II directory   */
/* devices may have an additional "readonly" status which is incorporated   */
/* by resetting the relevant write permission bits.                         */

static  mode_t  BlockTypeToModeT _LIB_F2_(unsigned char, type, char, isreadonly)
{
    mode_t  res;

    if (isreadonly)
    {
        res = 0;
    }
    else
    {
        res =  (S_IWUSR | S_IWGRP | S_IWOTH);
    }

    switch(type)
    {
        case(QF_PROG_TYPE):
                res |= (S_IRUSR | S_IXUSR | S_IRGRP | S_IXGRP |
                        S_IROTH | S_IXOTH | S_IFREG);
                break;

        case(THOR_DIR_TYPE):
        case(CST_DIR_TYPE):
        case(QF_DIR_TYPE):
                res |= (S_IRUSR | S_IXUSR | S_IRGRP | S_IXGRP | 
                        S_IROTH | S_IXOTH | S_IFDIR);
                break;

        default: /* data */
                res |= (S_IRUSR | S_IRGRP | S_IROTH | S_IFREG );
                break;

    }

    return(res);
}


int _Fstat _LIB_F2_(chanid_t,       cid,   \
                    struct stat *,  st)
{
    struct          qdirect     qd;
    int             length;
    time_t          now = time((time_t *)0);
    struct  QLRECT  qlrect;

    /*  First clear down the reply structure  */
    /*  We then later only need to set values */
    /*  that are different to these settings  */

    (void) memset (st, '\0', sizeof(struct stat));

    /*  Now try a header read call */
    /*  with a timeout of zero.   */

    length = fs_headr(cid, (timeout_t)0, &qd, sizeof(qd));
    
    /*
     *  We check for the obvious error of
     *  the channel not actually being open 
     */
    if(length == ERR_NO)
    {
        return EBADF;
    }

    /*
     *  now set up some values that will be
     *  the same for all apths we take
     */
    st->st_atime    =   now;
    st->st_rtime    =   now;

    /*
     *  We now diverge according to the
     *  device types we are handling
     */
    if (length < 0)
    {
        if (length == ERR_NC)
        {
            /* No error on fs_headr but did not complete neither.   */
            /* we assume it must be a ser of net channel.           */
            /* be sure to always use zero timeouts if we            */
            /* do not want to wait for hours on the network.        */
            /* Unfortunately there is no way to discriminate        */
            /* beteen ser and net channels. Device = (3, 1).        */
            /* Note that the information in qd is not valid.        */
            
            st->st_dev      =   0x00030001;
#if 0
            st->st_ino      =   0;          /* simple device has no inodes */
#endif
            st->st_mode     =   S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP |
                                S_IROTH | S_IWOTH | S_IFCHR;
#if 0
            st->st_size     =   0;          /* no size */
            st->st_atime    =   now;
#endif
            st->st_mtime    =   now;        /* simulate Unix as much as possible */
            st->st_ctime    =   now;
#if 0
            st->st_rtime    =   now;
#endif
            st->st_btime    =   now;
#if 0
            st->st_blocks   =   0;
            st->st_blksize  =   0;          /* no size */
#endif
        }
        else
        {
            /*  error on fs_headr (simple device, no header)   */
            /*  hey, this must be a pipe or screen!            */
            /*  pipe is device(1, 1) screen is device(2, 1).   */
            /*  we check this with a specific screen enquiry.  */
         
            st->st_dev      =   (dev_t)(sd_chenq(cid, (timeout_t)0, &qlrect) == ERR_BP
                                        ? D_PIPE : D_CON);
#if 0
            st->st_ino      =   0;          /* simple device has no inodes */
#endif
            st->st_mode     =   S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP |
                                S_IROTH | S_IWOTH |
                                (st->st_dev == 0x00010001 ? S_IFIFO : S_IFCHR);
#if 0
            st->st_size     =   0;          /* no size */
            st->st_atime    =   now;
#endif
            st->st_mtime    =   now;        /* simulate Unix as much as possible */
            st->st_ctime    =   now;
#if 0
            st->st_rtime    =   now;
#endif
            st->st_btime    =   now;
#if 0
            st->st_blocks   =   0;
            st->st_blksize  =   0;          /* no size */
#endif
    
        }
    }
    else
    {
        if(length < 64)
        {
            /* fs_headr is allowed and completed. Information in qd is  */
            /* valid for the first 14 bytes. This must be a simple      */
            /* device allowing fs_headr calls. Candidates are again ser */
            /* and net but we can give meaningful information now.      */
            /* Device number stays (3, 1).                              */

            st->st_dev      =   D_AUX;
#if 0
            st->st_ino      =   0;      /* simple device has no inodes */
#endif
            st->st_mode     =   SimpleTypeToModeT(qd.d_type);
            st->st_size     =   qd.d_length;
#if 0
            st->st_atime    =   now;
#endif
            st->st_mtime    =   now;    /* simulate Unix as much as possible */
            st->st_ctime    =   now;
#if 0
            st->st_rtime    =   now;
#endif
            st->st_btime    =   now;
            st->st_blocks   =   (qd.d_length >> 9) + 1;
            st->st_blksize  =   512;
        }
        else
        {
            /* we have a complete 64 byte header in qd. It must be a */
            /* directory device then!  Check to see if it is a level */
            /* 2 device (or better) supporting extended information. */

            struct          ext_mdinf   em;
            
            st->st_ino      =   _fake_inode(cid);
            st->st_size     =   qd.d_length;
#if 0
            st->st_atime    =   now;    /* last accessed: now */
#endif
            st->st_mtime    =   TIME_QL_UNIX(qd.d_update);
            st->st_ctime    =   TIME_QL_UNIX(qd.d_update);
#if 0
            st->st_rtime    =   now;    /* last accessed: now */
#endif
            st->st_btime    =   TIME_QL_UNIX(qd.d_backup);

            if (fs_xinf(cid, (timeout_t)0, &em) < 0)
            {
                /* There is no extended information. It must be a level */
                /* I directory device driver. Block size is always 512  */
                /* bytes. The name of the device and therefore the      */
                /* device number cannot be determined. Use (4, 1) as a  */
                /* fixed device number. The I-node number is composed   */
                /* of the complete filename.                            */

                st->st_dev      =   D_DISK;
                st->st_mode     =   BlockTypeToModeT(qd.d_type, 0);
                st->st_blocks   =   (qd.d_length >> 9) + 1;
                st->st_blksize  =   512;
            
            } 
            else
            {

                /* There is extended information present. It must be a  */
                /* level II device driver then. Use information in      */
                /* extended medium information to determine used block  */
                /* size. The complete filename is used to compose the   */
                /* I-node number. The device name is used to compose a  */
                /* unique device number.                                */

                st->st_dev      =   DevNameToDevT(&em.xm_dname.m_dname);
                st->st_mode     =   BlockTypeToModeT(qd.d_type, em.xm_rdonly);
                st->st_blocks   =   (size_t)((qd.d_length / em.xm_alloc) + 1);
                st->st_blksize  =   (size_t)em.xm_alloc;
            }
        }
    }
    return 0;
}

