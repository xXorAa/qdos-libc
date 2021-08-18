/*
 *          _ e n v s e t u p
 *
 *   Create copy of environment for C program.  
 *
 *   Use environment from stack if passed,
 *   otherwise try to find pointer to SuperBasic 
 *   environment.  If no environment can be found
 *   to copy then create an empty one.
 *
 *   V 1.00 - 04.01.92 - DFN (Dave nash)
 *                              - Initial version.
 *   V 1.01 - 01.07.92 - EJ  (Erling Jacobsen)
 *                              - 'env' passed as a parameter
 *   V 1.02 - 21.07.92 - DJW  (Dave Walker)
 *                              - Corrected setting up default directories to
 *                                handle case when Toolkit 2 not present.
 *   V1.03 -  21.08.92 - RK  (Richard Kettelwell)
 *                              - Improvement to the code# *
 *
 *  22 Nov 93   DJW   - Altered set_dir() routine to use the _getcd() and
 *                      the _setcd() internal library routines.  In that
 *                      way it is not necessary for them to be aware of
 *                      how the mechanism bu which default directory 
 *                      information is really stored.
 */

#define __LIBRARY__

#include <qdos.h>
#include <basic.h>
#include <string.h>
#include <stdlib.h>

#ifdef __STDC__
#define _P_(params) params
#else
#define _P_(params) ()
#endif

static void set_dir _P_((char *, short *));

#undef _P_


/*======================================================================*/
void    _envsetup (env)
/*      ~~~~~~~~~
 *  This routine handles setting up the default set of
 *  environment variable information.
 *----------------------------------------------------------------------*/
  char * env;
{
    short   **p;
    char    *ptr;

    /*
     * look for environment magic number on stack
     */
    if( *(short *)env == ENV_MAGIC) {
#if 0
        env += 2;
        env = (char *)(*(long *)env);                           /* EJ */
#endif
        /* More efficent way of writing above two lines */
        env = *(char **)(env+2);                               /* RK */
    } else {
        /*
         *-----------------------------------------------
         *  No environment was passed.   It is therefore
         *  necessary to see if one has been set up in
         *  SuperBasic.    To do this, we search for a
         *  Name Table entry called '*ENV*'.   If present.
         *  this will point to the environment.
         *-----------------------------------------------
         */
        long  *bv_sa; 
        char  *bv_nlbas, *nlp;
        struct _NT_ENT  *bv_ntbas, *ntp;
      
        env = NULL;
        _super();                                                /* supervisor mode */ 
        bv_sa    = (long *)(((long *)_sys_var)[4] + 0x68);       /* BASIC area base */
        bv_ntbas = (struct _NT_ENT *)((char *)bv_sa + bv_sa[6]); /* nametable base  */
        ntp      = (struct _NT_ENT *)((char *)bv_sa + bv_sa[7]); /* nametable ptr   */ 
        bv_nlbas = (char *)bv_sa + bv_sa[8];                     /* namelist base   */
        /*
         * Scan the name table in reverse order for m/c proc *ENV*.  
         *  set envold to basic environment string if found.
         */
        for (--ntp; ntp >= bv_ntbas; ntp--)   {           /* scan nametable      */
            if ( ntp->name_type == NT_proc_mc
             &&  ntp->var_type  == VT_null)       {       /* M/C procedure ?     */
                nlp = ntp->name_ptr + bv_nlbas;           /* point to namelist   */ 
                if (strncmp("*ENV*", nlp + 1, (size_t)5) == 0) {  /* found *ENV* ?       */ 
                    env = (char *)(*(long *)(ntp->value_ptr + 2));  /* environment pointer  */
                    break;                                /* exit loop           */  
                }
            }
        }    
        _user();                                          /* return to user mode */
    }
   
    /*
     *--------------------------------------------------
     *  By now we will have found the environment if
     *  it existed either on the stack or in SuperBasic.
     *  If it was found, then copy it.
     *--------------------------------------------------
     */
    (void) putenv("");                                 /* make empty environment */  
    if (env != NULL )  {      
        for (ptr = env; *ptr; ptr += strlen(ptr) + 1) /* copy C environment  */
            (void) putenv(ptr);
    }
    /*
     *------------------------------------------------
     *  Now handle default directories.
     *
     *  These are now stored in the environment variables.
     *  We need to set up the default directories
     *  before any file i/o is attempted.
     *
     *  If Toolkit 2 is not loaded, then the default
     *  directories are set to 0 length strings.
     *------------------------------------------------
     */
    {
    static short pp = 0;
    p = (short **)(_sys_var + 0xAC);
    set_dir (_prog_use, p ? *p++ : &pp);
    set_dir (_data_use, p ? *p++ : &pp);
    set_dir (_spl_use,  p ? *p : &pp);
    }
    return;
}


/*================================================================  _SET_DIR */
static
void    set_dir (tag, dirptr)
/*      ~~~~~~~
 *  Internal routine to see if specified default directory set.
 *  If not, then attempt to get it from SuperBasic.
 *  If that also fails, use default value.
 *-------------------------------------------------------------------------*/
  char * tag;
  short * dirptr;
{
    char    dirstr[50];

    (void) _getcd(tag, dirstr, sizeof(dirstr));
    if (dirstr[0] == '\0' && *dirptr != 0) {
        (void) qlstr_to_c( dirstr, (struct QLSTR *)dirptr);
        _setcd (tag, dirstr);
    }
    return;
}


