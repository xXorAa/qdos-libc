/* 
 *      s i g i n i t
 *
 *  Routine used to initialise the signal handling system
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  25 Oct 95   DJW   - Merged in the 'checksig_c' file as part of structuring
 *                      routines so that a dummy version is called instead if
 *                      signal handling is suppressed by the programmer.
 *
 *  03 Jan 96   DJW   - Added error handling if signal handler absent.
 *
 *  15 May 96   RZ    - Changed to use new handler initialisation call
 *
 *  18 Mar 98   DJW   - Declaration of _sigch and _h_init_flags moved
 *                      here instead of letting them be in own files.  Means
 *                      that this and the other routines (including new vectors 
 *                      mentioned below) will be automatically pulled into any
 *                      program that calls any of the library signal handling 
 *                      routines (that use any of the underlying signal structures).
 *                    - Vectors _SigInitVector and _SigCheckVector added as
 *                      part of enhancement to not include signal handling
 *                      initialisation code unless there is at least one call
 *                      to a signal routine somewhere within the program.
 */

#define __LIBRARY__

#include <sys/signal.h>
#include <sms.h>
#include <qdos.h>
#include <stdio.h>

extern  char *  _SPbase;

/* 
 *  make sure it doesn't contain a valid channel by accident 
 */
chanid_t _sigch=-1;

unsigned short   _hinit_flags = HI_UVAL | HI_SYSC;

/*
 *  Signal handler initialisation
 */

void _Signals_Init _LIB_F0_ (void)
{
    struct SIG_HIMSG imsg;
    struct SIG_INFO  inf;
    chanid_t  sch;
    int err;
#ifdef SIGDEBUG
    union VERS {
             char vrs[5];
             long vers;
            } version;
#endif /* SIGDEBUG */

    sch = io_open("*SIGNAL_R",(long)NULL);

    if (sch<0)  goto exit;

    imsg.magic= SIG_MAGIC;         /* '%MSG' */
    imsg.len  = sizeof(imsg);
    imsg.type = M_HINIT;
    imsg.txi  = _hinit_flags;
    imsg.jobid= -1;

    imsg.hi_nsigs = _NSIG;
    imsg.hi_stack = ((long)_SPbase)+200;

    if ((err=io_sstrg(sch,-1,&imsg,sizeof(imsg))) < 0)
    {
        goto exit;
    }

#ifdef SIGDEBUG
    _sigdebugch=io_open("con_",0);
    sigprintf("handler channel %ld,\t init result %d\n",_sigch,err);
#endif /* SIGDEBUG */
    err = io_fstrg(sch,-1,&inf,sizeof(inf));
    if(err >= 12)
    {
         _sigvec = (_sigvec_t)inf.sigvec;
    }

#ifdef SIGDEBUG
    version.vers=inf.vers;
    version.vrs[4]=(char)0;
    sigprintf("version: %s sigvec addr %d",version.vrs,_sigvec);
#endif /* SIGDEBUG */

 exit:
    if (sch < 0 || err < 12) 
    {
        (void) _SigNoImp(0);
        if (__SigNoCnt < -1) 
        {
            (void) sms_frjb (-1,++__SigNoCnt);
        }
        else
        {
            return;
        }
    }
    _sigch=sch;
    (void)(*_sigvec)(sch,7,0,NULL,&_defsigrp);

    return;
}

/*
 *  Support routine used within signal implementation for C68
 */

static
int _CheckSig _LIB_F0_(void)
{
#ifdef SIGDEBUG
   sigprintf("calling _CheckSig\n");
#endif /* SIGDEBUG */
    return (*_sigvec)(_sigch,6);
}

/*
 *  Vectors that need to end up being defined if there are
 &  any calls to signal handling in the program.
 */
extern void (*_SigInitVector)(void) = _Signals_Init;
extern int  (*_SigCheckVector)(void) = _CheckSig;

