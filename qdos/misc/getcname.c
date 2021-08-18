/*
 *          g e t c n a m e
 *
 *  Find the name attatched to a QDOS channel id.
 *  Returns:
 *      success     pointer to name
 *      failure     NULL
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  10 Jul 93   DJW   - Removed dependency on _getcdb() setting _oserr.
 *
 *  06 Sep 94   DJW   - Removed call to mt_inf().  Used global '_jobid'
 *                      variable instead.
 *
 *  10 Aug 95   DJW   - Removed the _super() and _user() calls as they
 *                      no longer seem to be necessary
 *
 *  04 Apr 98   DJW   - Removed check on channel block size.  Is not now
 *                      necessarily the same on all variants of QDOS/SMS.
 */

#define __LIBRARY__

#include <qdos.h>
#include <channels.h>
#include <string.h>

char *getcname  _LIB_F2_ ( chanid_t,    chid,
                           char *,      name)
{
    struct chan_defb *cp;
    struct fs_cdefb *cdefb;
    size_t l;

    if(iscon( chid, (timeout_t)0L ))
    {
        return (char *)NULL;
    }
    if( (long)(cdefb = (struct fs_cdefb *)_getcdb( chid )) < 0) 
    {
        _oserr = (int)(long)cdefb;
        return (char *)NULL;
    }

    cp = &cdefb->fs_cdef;

#if 0
    /* 
     *  Check if the channel is the correct size 
     */
    if( cp->ch_len != FSCDEF_SIZE) 
    {
        _oserr = ERR_BP;
        return (char *)NULL;
    }
#endif

    /*
     *   Copy the device name
     */
    (void) qlstr_to_c( name, &((struct QLDDEV_LINK *)cp->ch_drivr)->ldd_dname);
    /*
     *  Get the correct drive no.
     *  First we need the system variables
     */
    name[l=strlen(name)] = (char)('0'+
        ((struct physdef_block **)(_sys_var+0x100))[cdefb->fs_drive]->fs_drivn);
    /*
     *  Add the underscore
     */
    name[l + 1 ] = '_';
    (void) qlstr_to_c( &name[l+2], &cdefb->fs_name);

    return name;
}

