/*
 *              _ O p e n 
 *
 * Routine to simulate the UNIX 'open' call
 * (i.e. open a level 1 file)
 *
 * Adds default device name to start
 * name doesn't start with a device.
 * Also ensures SCR_ and CON_ devices are 
 * set to D_CON devices.
 *
 *  Amendment History
 *  ~~~~~~~~~~~~~~~~~
 *  25 Jul 92   DJW   - Added seek to EOF if opened in APPEND mode
 *                      (reported by Dirk Steinkopf)
 *
 *  07 Sep 92  DJW    - Added "PIPE" as extra name for input pipes
 *
 *  20 Oct 92  DJW    - It was possible if there was a problem with the
 *                      isdevice() call to exit via the error path
 *                      without setting the errno to an error code.
 *                    - The check for a CON/SRC device was being done
 *                      before the channel was opened!  Now done at end
 *                      of open code if we do not know device type.
 *                    - We now check for a directory device, and if not
 *                      try to open as a simple device.  If this fails with
 *                      ERR_NF it is now assumed default directory needed.
 *                    - Improved setting of device type field in UFB
 *                      structure, particularily for pipes.
 *
 *  19 Jun 93  DJW    - PIPE code merged in with code for simple device,
 *                      which results in more compact code. As a by-product
 *                      fixed problem with PIPE device type whereby all PIPE
 *                      open calls were being treated as INPUT type!
 *                      Also fixed a problem wherebye it was not possible to
 *                      open a SER device in READ mode.
 *
 *  10 Jul 93   DJW   - Removed dependency on io_open() and io_close()
 *                      setting _oserr.
 *
 *  26 Aug 93   DJW   - Added setting of UFB timeout at open stage.  It was
 *                      previously being set in _chkufb() routine.
 *
 *  25 Sep 93   DJW   - Corrected problem that would cause opening in "append"
 *                      mode to always fail for directory devices.
 *                    - Added support for Posix O_SYNC and I_NONBLOCK modes
 *                    - Open code for directory devices amended to try and
 *                      avoid doing an open just to see if a file exists.
 *
 *  03 Oct 93   DJW   - Reworked code slightly to be mor efficient.
 *                      Removed sanity check on name length - done anyway
 *                      by _qlmknam() call.
 *
 *  30 Mar 94   DJW   - On the QXL, open of simple devices could fail if
 *                      the mode parameter was invalid.
 *
 *  04 Apr 94   EAJ   - If device is an input pipe, mode is really a
 *                      channel id, and so will not pass the sanity
 *                      checks, unless replaced by O_RDONLY. This
 *                      is now done at the start of the code.
 *
 *  15 May 94   DJW   - Changes needed to handle named pipes correctly.
 *                      Previous code was OK for unnamed pipes, but did
 *                      not handle read end of named pipes correctly.
 *                      All the PIPE identification code was moved
 *                      before any checks or analysis of the 'mode'
 *                      field as it can have special constraints
 *                      imposed for the case of pipes.
 *                      (problem reported by Phil Borman)
 *
 *  28 Jun 94   EAJ   - If we cannot open the file, set errno to ENOENT
 *                      instead of EOSERR, as GNU RCS checks errno for
 *                      this value (ENOENT), and doesn't understand EOSERR.
 *                      It is annoying to have a program (such as RCS) report
 *                      Unknown error -1, when the program understands ENOENT.
 *
 *  20 Aug 94   DJW   - Opening a non-existent file should fail even if RW
 *                      mode asked for if the file does not exist.
 *                      (problem reported by Lester Wareham)
 *
 *  24 Sep 94   DJW   - Removed the sanity check of O_RDONLY and O_TRUNC being
 *                      both specified.  This does not work when the O_RDONLY
 *                      mode is allowed to be zero.  However, we do now check
 *                      that if O_TRUNC is set then a 'write' mode is used.
 *                    - Various other small changes to cater for the fact that
 *                      O_RDONLY now has a value of zero.
 *
 *  31 Dec 94   DJW   - Changed entry point name to __Open to reflect the
 *                      fact it is normally called indirectly via a vector
 *
 *  08 Aug 95   DJW   - Added ERR_NI and ERR_EX to error codes that are
 *                      caught within a "Simple Device" open to allow
 *                      processing to continue with looking for directory
 *                      devices.   This is an attempt to let file names
 *                      that start with SPELL_ be tried with the default
 *                      directory name added.
 *
 *  12 Nov 95   DJW   - Store name of channel when doing open
 *
 *  14 Aug 98   DJW   - Added some checks on valid filename parameter
 *                      (part of investigating occassional lockups).
 */

#define __LIBRARY__

#include <assert.h>
#include <qdos.h>
#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int __Open  (const char *name, int mode, ...)
{
    int simplemode;             /* mode used for io_open() of simple devices */
    char * (*function)(char *, int);
    struct UFB *uptr;
    char str[MAXNAMELEN + 2];
    char dp[MAXNAMELEN + 2];
    short   ufbflags;
    char    ufbtype;
    chanid_t    chid;
    int fd;

    /*
     *  Do some basic chaecking on parameters
     */
    if (name == NULL)
    {
        errno = EFAULT;
        return -1;
    }
    if (strlen(name) > MAXNAMELEN)
    {
        errno = ENAMETOOLONG;
        return -1;
    }
    /*
     *  Search existing table to find a file handle for open
     */
    if ((fd = _Openufb()) < 0) 
    {
        return -1;
    }
    uptr = &_ufbs[fd];
    ufbtype  = D_UNKNOWN;       /* and unknown type */
    ufbflags = UFB_OP;          /* Preset open status bit */
    uptr->ufbnam = strdup((char *)name);/* Store name */
    /*
     *-------------------------------------
     *  PIPE devices need special handling,
     *  so identify them immediately.  We 
     *  look for a name starting with the
     *  letters PIPE (not case sensitive)
     *  followed by a NULL or underscore.
     *-------------------------------------
     */
    if ((strnicmp("PIPE",name, (size_t) 4) == 0)
    &&  ((name[4] == '\0') || (name[4] == '_')) ) 
    {
        char *underptr;

        ufbtype = D_PIPE;
        /*
         *  There are a number of legal types of name
         *  for pipes.  We assume one of the following:
         *      PIPE                Unnamed READ pipe
         *      PIPE_               Unnamed READ pipe
         *      PIPE_0              Unnamed READ pipe
         *      PIPE_value          Unnamed WRITE pipe
         *      PIPE_name           Named READ pipe
         *      PIPE_name_value     Named WRITE pipe
         *  In these examples 'value' is any non-zero
         *  integer, and 'name' is any text (which can
         *  contain further underscores).
         *
         *  We start the further analysis by finding
         *  the last underscore in the name.
         */
        if ( ((underptr = strrchr(name,'_')) == NULL)
        ||  ( (&name[4] == underptr) 
               && (*++underptr == '\0' 
                    || (*underptr == '0' && *++underptr=='\0')) ) ) 
        {
            /*
             *  We have one of the first of three cases
             *  from the above list, so we have an
             *  unnamed input pipe.  In this case the
             *  mode field passed is really the channel
             *  id of thw write end of the pipe that we
             *  want to read.  Set this to the be the
             *  open mode for the io_open() call, and
             *  change 'mode' to a vlaue that will
             *  satisfy the sanity checks on 'mode'.
             */
            simplemode = mode;          /* Mode is really channel ID */
            mode = O_RDONLY;
        } 
        else 
        {
            /*
             *  We now know that we do not have the
             *  awkward case of the unnamed READ pipe.
             *  We still need to ensure that we have a
             *  sutiable mode for the io_open() call.
             *  Named inout pipes in MUST use mode 1
             *  (i.e. OLD_SHARE).
             *
             *  We will assume the user has asked for
             *  a sensible mode in his open() statement
             *  and set ourselves up accordingly.  If this
             *  not the cas, the the io_open() call will
             *  fail generating an error report to the user.
             *
             *  It is possible that we might find cases
             *  where the following code is too simplistic
             *  but until we find such cases why put in
             *  more code than we need?
             */

            if ((mode & (O_WRONLY|O_RDWR|O_RDONLY))== O_RDONLY) 
            {
                simplemode = OLD_SHARE;
            } 
            else 
            {
                simplemode = OLD_EXCL;
            }
        }
    } 
    else 
    {
        /*
         *  For non-pipe devices we set the io_open() mode
         *  to OLD_EXCL.  It is possible that there may be
         *  cases where this is to simplistic a mode, but
         *  if so they have not been identified to date.
         */
        simplemode = OLD_EXCL;
    }
    /*
     *--------------------------------
     *  Set up the UFB flags according
     *  to the open modes specified.
     *--------------------------------
     */
    /*
     *  Toggle RAW state according to _iomode
     */
    if ((mode & (O_WRONLY|O_RDWR)) == (O_WRONLY|O_RDWR)) 
    {
        errno = EINVAL;
        return -1;
    }
    mode ^= (_iomode & O_RAW);
    ufbflags |= _ModeUfb (mode);
    /*
     *---------------------------------
     *          NULL device
     *
     *  Check for NULL name/device. We
     *  give this special handling.
     *
     *  We assume a NULL device if the
     *  either no name is supplied, or
     *  the special name "NULL".
     *---------------------------------
     */
    if(name==NULL || *name=='\0' || stricmp( name, "NULL")==0) 
    {
        uptr->ufbfh = -1L;
        uptr->ufbtyp = D_NULL;
        uptr->ufbflg = ufbflags;
        return fd;
    }
    /*
     *-------------------------------------------------
     *          SIMPLE DEVICES
     *
     *  Try to open the given name as a simple device.
     *  If the name does not correspond to a simple
     *  device we will simple fail with an error code.
     *--------------------------------------------------
     */
    if( ! isdirdev( name )) 
    {
        if ((chid = io_open( name, simplemode)) > 0L) 
        {
            if (ufbtype == D_UNKNOWN) 
            {
                ufbtype = (iscon(chid,(timeout_t)1)) 
                            ? (char)D_CON 
                            : (char)D_AUX;
            }
            uptr->ufbfh = chid;
            uptr->ufbtyp = ufbtype;
            uptr->ufbflg = ufbflags;
            return fd;
        }
        /*
         *  We failed.  If this was because the
         *  name did not correspond to a simple
         *  device, then we want to try again as
         *  a directory device.
         */
        switch (chid) 
        {
            case ERR_EX:
            case ERR_NF:
            case ERR_BN:
            case ERR_BP:
            case ERR_NI:
                    break;
            default:
                    _oserr = chid;
                    errno = EOSERR;
                    return -1;
        }
        /*
         *-------------------------------------------------
         *          DEFAULT DIRECTORY HANDLING
         *
         *  If the name does not already start with a
         *  directory device name, then add the appropriate 
         *  default directory.
         *-------------------------------------------------
         */
        switch (mode & (O_PDIR | O_DDIR)) 
        {
            case O_PDIR:
            case (O_PDIR | O_DDIR):
                function = getcpd;
                break;
            case O_DDIR:
                function = getcdd;
                break;
            default:
                function = getcwd;
                break;
        }
        (void)(*function)(dp, sizeof(dp));
        if (_qlmknam( str, dp, name, MAXNAMELEN ) < 0) 
        {
            return -1;
        }
    }
    else 
    {
        (void) strcpy( str, name);
    }
    /*
     *---------------------------------------------------------------
     *          MAIN DIRECTORY DEVICE OPEN
     *--------------------------------------------------------------
     */
    ufbtype = D_DISK;
    /*
     *  Try and open an existing file in exclusive mode,
     *  (unless this is RD_ONLY mode with shared access)
     */
    if ((mode & (O_WRONLY | O_RDWR | O_RDONLY | O_EXCL)) == O_RDONLY) 
    {
        chid = -1;
    } 
    else 
    {
        if ((chid = io_open( str, OLD_EXCL)) >= 0) 
        {
            /*
             *  If O_CREAT and O_EXCL are both set, then it is
             *  an error if the file already exists.
             */
            if( (mode & (O_CREAT | O_EXCL))==(O_CREAT | O_EXCL)) 
            {
                (void) io_close( chid );
                errno = EEXIST;
                return -1;
            }
            /*
             *  If mode is O_TRUNC, then we close the file and take
             *  one of the following actions:
             *  a)  If we are not making a write mode open, then it is
             *      an error to try O_TRUNC, so report this back.
             *  b)  If we are making a write mode access, we delete the
             *      file, and pretend it does not exist!  This is to
             *      avoid making the assumption that the QDOS call to
             *      truncate a file works on this system.
             */
            if (mode & O_TRUNC) 
            {
                (void) io_close (chid);
                if (mode & (O_WRONLY | O_RDWR)) 
                {
                    (void) io_delete (str);
                    chid = -1;
                    mode |= O_CREAT;    /* Set permission to re-create the file */
                } 
                else 
                {
                    errno = EACCES;
                    return -1;
                }
            }
        }
    }
    /*
     *  See if we have still failed to open the file
     *  so far to make the last ditch attempts‘
     */
    if (chid < 0) 
    {
        switch (mode & (O_WRONLY | O_RDWR | O_RDONLY)) 
        {
            /*
             *  For RD_ONLY mode, we try and gain shared access
             */
            case O_RDONLY:
                if ((chid = io_open( str, OLD_SHARE)) < 0 ) 
                {
                    _oserr = chid;
                    errno = ENOENT;
                    return -1;
                }
                break;
            /*
             *  For O_WRONLY and O_RDWR modes we try and create the file
             *  as long as the O_CREAT flag is set.
             */
            default:
                if ((mode & O_CREAT) == 0) 
                {
                    errno = ENOENT;
                    return -1;
                }
                if ((chid = io_open( str, NEW_EXCL)) < 0 ) {
                    _oserr = chid;
                    errno = ENOENT;  /* Changed from EOSERR, EAJ June 1994 */
                    return -1;
                }
                break;
        }   /* end of swithc */
    }
    /*
     *  If append mode was specified, then ensure that
     *  we are initially positioned at EOF
     */
    if (mode & O_APPEND) 
    {
        (void) lseek (fd, 0L, SEEK_END);
    }
    /*
     *  Finally exit giving the fd for the file
     */
    uptr->ufbfh = chid;
    uptr->ufbtyp = ufbtype;
    uptr->ufbflg = ufbflags;
    return fd;
}

