#                                                  
#   Makefile to build the C68 LIBC_A Standard C library using the qdos-gcc
#   cross-compiler
#
#   The following macro definitions are used:
#
#       NOT_REACHED     Inserted at points which it is not ever expected to
#                       reach because of program logic.  In particular this
#                       is used in default branches of switch statements
#                       where the default is never expected to be taken.
#                       It will not actually generate code unless NDEBUG
#                       is also undefined.
#
#       NDEBUG          standard ANSI defined macro for controlling whether
#                       assert statements actually generate code or not.
#                       A debugging library would have this defined, but
#                       a production library optimised for performance and
#                       size would not.
#
#   CHANGE HISTORY
#   ~~~~~~~~~~~~~~
#   July 1998   DJW   - Removed option to include old IEEE routines.
#                       Assume need for backwards compatibility expired.
#
#   September 2000	TG - Adaptation to qdos-gcc cross-compiler.
#   1st October 2000	TG - Changed for qdos-gcc math specific functions.


P = /usr/local/qdos/bin/
I = ./include/
LIBDIR = /usr/local/qdos/lib/

CC = /usr/local/qdos/bin/cc
AS = /usr/local/qdos/bin/as
MAC = /usr/local/qdos/bin/qmac
LD = /usr/local/qdos/bin/ld
SLB = /usr/local/qdos/bin/slb
CP = cp
RM = rm
FIND = find

# Settings to _not_ include debug code
DEFINES = "-DNOT_REACHED=assert(0)" -DNDEBUG

# -DQDOS and -DAS68 are mandatory. -DHW_FPU enables the hardware FPU support.
# -DGCC_MATH enables the qdos-gcc specific math functions (used as a work around
# for math+stack related bug in gcc); these functions do not tidy up the stack
# on exit. By defining GCC_MATH_FULL as well, _all_ C68 functions get their
# corresponding GCC counterparts (but so far these functions are not used by
# qdos-gcc).
ASDEFINES = -DQDOS -DAS68 -DHW_FPU -DGCC_MATH #-DGCC_MATH_FULL

# Use of -fno-omit-frame-pointer is mandatory when the -DGCC_MATH work around
# not unused, and until qdos-gcc got fixed.
OPTFLAGS = -O2 -fno-omit-frame-pointer #-fno-strength-reduce

CCFLAGS = -c -I$(I) $(DEFINES)
ASFLAGS = -V

.SUFFIXES : .x .s .asm .o .rel .hdr .h

# Installation directory.
LIBDIR = /usr/local/qdos/lib/
INCDIR = /usr/local/qdos/include/

#   Program Initialisation routines
IN = init/
#   C68 initial startup modules
CRTOBJ = $(IN)crt.o         $(IN)crtrll.o   $(IN)crespr.o  $(IN)asmstart.o 

INIT_RLL = $(IN)callRLM.o   $(IN)thingtrap.o

INIT =  $(INIT_RLL) \
        $(IN)_cmdchans.o    $(IN)_envsetup.o    $(IN)_initcon.o \
        $(IN)_stdchans.o    $(IN)_stkchans.o \
        $(IN)cmdexpand.o \
        $(IN)condefault.o   $(IN)conqpac.o      $(IN)contitle.o  \
        $(IN)libxt.o        $(IN)super.o

#   Character testing and conversion routines
CH = ctype/
CTYPE_RLL = $(CH)ctype.o    \
        $(CH)isalnum.o  $(CH)isalpha.o  $(CH)isascii.o  $(CH)iscntrl.o \
        $(CH)iscsym.o   $(CH)iscsymf.o  $(CH)isdigit.o  $(CH)isgraph.o \
        $(CH)islower.o  $(CH)isprint.o  $(CH)ispunct.o  $(CH)isspace.o \
        $(CH)isupper.o  $(CH)isxdigit.o \
        $(CH)toascii.o  $(CH)tolower.o  $(CH)toupper.o     

CTYPE = $(CTYPE_RLL)
# 
#   Default constants
DF = defaults/
#
#  N.B. We can put into RLL any read only values that
#       are NOT referenced by other RLL routines
#
DEFAULTS_RLL = \
            $(DF)copyright.o \
            $(DF)libm.o         $(DF)libcurses.o    $(DF)libdebug.o  \
            $(DF)liblist.o      $(DF)librll.o \
            $(DF)libsocket.o    $(DF)libsroff.o \
            $(DF)libmalloc.o    $(DF)libvt.o \
            $(DF)progname.o \
            $(DF)qopenin.o      $(DF)qopenout.o \
            $(DF)slash.o        $(DF)stack.o        $(DF)stkmargin.o \
            $(DF)timeout.o      $(DF)version.o

DEFAULTSX = $(DF)C_exc.o        $(DF)C_hex.o

DEFAULT =   $(DEFAULTS_RLL)     $(DF)cmdnames.o \
            $(DF)cmdchans.o     $(DF)cmdparams.o    $(DF)cmdwild.o \
            $(DF)condetails.o   $(DF)conname.o      $(DF)consetup.o \
            $(DF)defprior.o \
            $(DF)endmsg.o       $(DF)endtimeout.o \
            $(DF)fmode.o \
            $(DF)mneed.o        $(DF)memqdos.o      $(DF)memincr.o \
            $(DF)memmax.o       $(DF)nsems.o \
            $(DF)openvector.o   $(DF)pipesize.o \
            $(DF)readkbd.o      $(DF)stkchans.o \
            $(DF)ufbs.o         $(DF)uiomode.o

#           $(DF)openvector.o 

#   Routines from dirent.h header
DIR = dirent/
DIRENT =    $(DIR)closedir.o    $(DIR)opendir.o     $(DIR)readdir.o \
            $(DIR)rewinddir.o   $(DIR)seekdir.o     $(DIR)telldir.o

#   Routines from fcntl.h header
F = fcntl/
FCNTL =   $(F)_chkufb.o     $(F)_conread.o  $(F)_conwrite.o \
          $(F)_creat.o      $(F)_doopene.o  $(F)_gettimo.o \
          $(F)_modefd.o     $(F)_modeufb.o  $(F)_modetab.o \
          $(F)_newufb.o     $(F)_open.o     $(F)_openufb.o \
          $(F)creat.o       $(F)fcntl.o \
          $(F)fdmode.o      $(F)iomode.o \
          $(F)open.o        $(F)opene.o     $(F)qopen.o     $(F)Xopen.o 

#   Routines from libgen.h header that are in both LIBC_A and LIBGEN_A
G = libgen/
GEN_RLL =   $(G)_cescint.o  $(G)_hexint.o   $(G)_octint.o   $(G)_intcesc.o \
            $(G)_streadd.o  $(G)gmatch.o  \
            $(G)strcadd.o   $(G)strccpy.o  \
            $(G)strtrns.o 
GEN =   $(GEN_RLL)

#   Group file handling
GR = grp/
GRP_RLL =
GRP =   $(GRP_RLL) \
        $(GR)getgrent.o     $(GR)getgrnam.o     $(GR)getgrgid.o

LC = locale/
LOCALE =    $(LC)setlocale.o

#   Miscellaneous stuff with no other home
MS = misc/
MISC_RLL =  $(MS)iscon.o    $(MS)wait.o
MISC =      $(MISC_RLL) \
            $(MS)assert.o   $(MS)cachestate.o \
            $(MS)cCallRLM.o $(MS)fopene.o  \
            $(MS)pclose.o   $(MS)popen.o \
            $(MS)rename.o

#   Miscellaneous not used
MISCX =     $(MS)cprintf.o  $(MS)cscanf.o

#   Password file handling
PW = pwd/
PWD_RLL =
PWD =   $(PWD_RLL) \
        $(PW)getpwent.o     $(PW)getpwnam.o     $(PW)getpwuid.o

SJ = setjmp/
SETJMP = $(SJ)setjmp.o

#   Signal handling
SIG = signal/

#   Routines that need to be in a particular relationship
#   relative to the rest of the library.

SIGSTART  = $(SIG)alarm.o       $(SIG)fraise.o \
        $(SIG)kill.o        $(SIG)pause.o       $(SIG)psignal.o \
        $(SIG)raiseu.o      $(SIG)sendsig.o \
        $(SIG)signal.o      $(SIG)sigset.o \
        $(SIG)sigaction.o   $(SIG)sigaddset.o \
        $(SIG)sigcleanup.o \
        $(SIG)sigdebug.o    $(SIG)sigdelset.o \
        $(SIG)sigemptyset.o $(SIG)sigfillset.o  $(SIG)sighold.o \
        $(SIG)sigignore.o   $(SIG)siginit.o     $(SIG)sigismember.o  \
        $(SIG)siglongjmp.o \
        $(SIG)signocnt.o    $(SIG)signoimp.o    $(SIG)signomsg.o \
        $(SIG)sigpause.o    $(SIG)sigpending.o  $(SIG)sigprintf.o \
        $(SIG)sigprocmask.o $(SIG)sigrelse.o \
        $(SIG)sigsetjmp.o   $(SIG)sigsuspend.o \
        $(SIG)sigtimer.o  

SIGSTARTX = $(SIG)sigstart.o $(SIG)siginit.o 

SIGEND =    $(SIG)sigstart.o $(SIG)sigstartx.o \
            $(SIG)sigcheck.o $(SIG)sigcheckx.o \
            $(SIG)sigch.o    $(SIG)signoimpx.o

SIGENDX = $(SIG)checknosig.o

# SIGNAL_RLL = $(SIG)onsigkill.o  $(SIG)sigdefault.o
SIGNAL=     $(SIG)sigdefpri.o $(SIG)sigvec.o    $(SIG)raise.o

# SIGNAL_RLL = $(SIG)onsigkill.o  $(SIG)sigdefault.o
# SIGNAL= $(SIGNAL_RLL) \
#        $(SIG)alarm.o       $(SIG)fraise.o \
#        $(SIG)kill.o        $(SIG)pause.o       $(SIG)psignal.o \
#        $(SIG)raise.o       $(SIG)raiseu.o      $(SIG)sendsig.o \
#        $(SIG)signal.o      $(SIG)sigset.o \
#        $(SIG)sigaction.o   $(SIG)sigaddset.o \
#        $(SIG)sigcleanup.o  $(SIG)sigcurrent.o \
#        $(SIG)sigdefpri.o   $(SIG)sigdelset.o \
#        $(SIG)sigemptyset.o $(SIG)sigfillset.o  $(SIG)sighold.o \
#        $(SIG)sigignore.o   $(SIG)sigismember.o $(SIG)siglongjmp.o \
#        $(SIG)signocnt.o    $(SIG)signoimp.o    $(SIG)signomsg.o \
#        $(SIG)sigpause.o    $(SIG)sigpending.o  $(SIG)sigprintf.o \
#        $(SIG)sigprocmask.o $(SIG)sigrelse.o    $(SIG)sigsamask.o \
#        $(SIG)sigsetjmp.o   $(SIG)sigsuspend.o \
#        $(SIG)sigtimer.o    $(SIG)siguval.o

#   Earl chew's stdio package
IO = stdio/
STDIO_RLL = 
STDIO = $(STDIO_RLL) \
        $(IO)_allocbuf.o $(IO)_bfs.o    $(IO)_bread.o   $(IO)_bwrite.o \
        $(IO)_err.o     $(IO)_fgetlx.o  $(IO)_file.o \
        $(IO)_fopen.o   $(IO)_freebuf.o $(IO)_in.o      $(IO)_ioread.o \
        $(IO)_iowrite.o $(IO)_ipow10.o  $(IO)_open3.o   $(IO)_os.o \
        $(IO)_out.o     $(IO)_rlbf.o    $(IO)_stdio.o \
        $(IO)_update.o  $(IO)_utoa.o    $(IO)_vfprintf.o $(IO)_vfscanf.o \
        $(IO)_vscanf.o  $(IO)_vsscanf.o $(IO)_xassert.o $(IO)_z_cvt.o \
        $(IO)_z_tvc.o   $(IO)_zatexit.o $(IO)_zerr.o    $(IO)_zout.o \
        $(IO)_zrlbf.o   $(IO)_zwrapup.o \
        $(IO)atexit.o   $(IO)clearerr.o $(IO)exit.o     $(IO)fclose.o \
        $(IO)fdopen.o   $(IO)feof.o     $(IO)ferror.o   $(IO)fflush.o \
        $(IO)fgetc.o    $(IO)fgetpos.o  $(IO)fgets.o    $(IO)fileno.o \
        $(IO)fopen.o    $(IO)fprintf.o  $(IO)fputc.o    $(IO)fputs.o \
        $(IO)fread.o    $(IO)freopen.o  $(IO)fscanf.o   $(IO)fseek.o \
        $(IO)fsetpos.o  $(IO)ftell.o    $(IO)fwrite.o   $(IO)getc.o \
        $(IO)getchar.o  $(IO)gets.o     $(IO)getw.o     $(IO)perror.o \
        $(IO)printf.o   $(IO)putc.o     $(IO)putchar.o  $(IO)puts.o \
        $(IO)putw.o     $(IO)remove.o   $(IO)rewind.o   $(IO)scanf.o \
        $(IO)setbuf.o   $(IO)setvbuf.o  $(IO)sprintf.o  $(IO)sscanf.o \
        $(IO)tempnam.o  $(IO)tmpfile.o  $(IO)tmpnam.o \
        $(IO)ungetc.o   $(IO)vfprintf.o $(IO)vprintf.o  $(IO)vsprintf.o
#   Routines that are not used
STDIOX = $(IO)_rename.o  $(IO)_errlist.o

#IO = ESTDIO34_
#STDIO_RLL = \
#        $(IO)_errlist.o
#STDIO = $(STDIO_RLL) \
#        $(IO)_allocbuf.o    $(IO)_bfs.o         $(IO)_bread.o \
#        $(IO)_bwrite.o      $(IO)_cclose.o      $(IO)_clseek.o \
#        $(IO)_cread.o       $(IO)_cwrite.o      $(IO)_dup_2.o \
#        $(IO)_eputs.o       $(IO)_err.o \
#        $(IO)_errno.o       $(IO)_fcloseall.o   $(IO)_fgetlx.o \
#        $(IO)_file.o        $(IO)_fopen.o       $(IO)_freebuf.o \
#        $(IO)_fropen.o      $(IO)_funopen.o     $(IO)_fwopen.o \
#        $(IO)_in.o          $(IO)_ioread.o      $(IO)_iowrite.o \
#        $(IO)_ipow10.o      $(IO)_open_3.o      $(IO)_os.o \
#        $(IO)_out.o         $(IO)_rlbf.o \
#        $(IO)_setvbuf.o     $(IO)_snprintf.o    $(IO)_stdio.o \
#        $(IO)_update.o      $(IO)_utoa.o        $(IO)_vfprintf.o \
#        $(IO)_vfscanf.o     $(IO)_vscanf.o      $(IO)_vsnprintf.o \
#        $(IO)_vsscanf.o     $(IO)_xassert.o     $(IO)_z_cvt.o \
#        $(IO)_z_tvc.o       $(IO)_zatexit.o     $(IO)_zerr.o \
#        $(IO)_zmalloc.o     $(IO)_zout.o        $(IO)_zrlbf.o \
#        $(IO)_zwrapup.o     $(IO)abort.o        $(IO)atexit.o \
#        $(IO)clearerr.o     $(IO)ctermid.o      $(IO)cuserid.o \
#        $(IO)exit.o         $(IO)fclose.o       $(IO)fdopen.o \
#        $(IO)feof.o         $(IO)ferror.o       $(IO)fflush.o \
#        $(IO)fgetc.o        $(IO)fgetpos.o      $(IO)fgets.o \
#        $(IO)fileno.o       $(IO)fopen.o        $(IO)fprintf.o \
#        $(IO)fputc.o        $(IO)fputs.o        $(IO)fread.o \
#        $(IO)freopen.o      $(IO)fscanf.o       $(IO)fseek.o \
#        $(IO)fsetpos.o      $(IO)ftell.o        $(IO)fwrite.o \
#        $(IO)getc.o         $(IO)getchar.o      $(IO)gets.o \
#        $(IO)getw.o         $(IO)perror.o       $(IO)printf.o \
#        $(IO)putc.o         $(IO)putchar.o      $(IO)puts.o \
#        $(IO)putw.o         $(IO)remove.o       $(IO)rewind.o \
#        $(IO)scanf.o        $(IO)setbuf.o       $(IO)setvbuf.o \
#        $(IO)sprintf.o      $(IO)sscanf.o       $(IO)tmpfile.o \
#        $(IO)tmpnam.o       $(IO)ungetc.o       $(IO)vfprintf.o \
#        $(IO)vprintf.o      $(IO)vsprintf.o
##   Routines that are not used
#ESTDIOX = $(IO)_re_name.o

#   Routines defined in sys/stat.h
ST   =   stat/
STAT_RLL =
STAT =  $(STAT_RLL)  \
        $(ST)_fstat.o  $(ST)_stat.o \
        $(ST)chmod.o   $(ST)fchmod.o    $(ST)fstat.o    $(ST)lstat.o  \
        $(ST)mkdir.o   $(ST)mkfifo.o    $(ST)mknod.o \
        $(ST)stat.o    $(ST)umask.o

#   Routines defined in stdlib.h
STD = stdlib/
STDLIB_RLL= $(STD)abs.o         $(STD)atof.o        $(STD)atoi.o \
            $(STD)atol.o        $(STD)div.o         $(STD)itoa.o \
            $(STD)labs.o        $(STD)ldiv.o \
            $(STD)mblen.o       $(STD)mbstowcs.o    $(STD)mbtowc.o \
            $(STD)wcstombs.o    $(STD)wctomb.o
STDLIB= $(STDLIB_RLL) \
        $(STD)_abort.o  $(STD)_calloc.o $(STD)_putenv.o \
        $(STD)_qsort.o  $(STD)_realloc.o \
        $(STD)_strtod.o $(STD)_strtoul.o \
        $(STD)abort.o   $(STD)bsearch.o $(STD)calloc.o  $(STD)free.o \
        $(STD)getenv.o  $(STD)getopt.o  $(STD)getpass.o  \
        $(STD)isatty.o  $(STD)malloc.o  $(STD)mktemp.o \
        $(STD)putenv.o  $(STD)qsort.o   $(STD)rand.o    $(STD)realloc.o \
        $(STD)strtod.o  $(STD)strtod_aux.o \
        $(STD)strtol.o  $(STD)strtoul.o \
        $(STD)system.o  $(STD)ttyname.o

#   String handling routines (defined in string.h and memory.h)
S =  string/
STRING_RLL= \
        $(S)_memcmp.o   $(S)_memcpy.o   $(S)_memset.o \
        $(S)_strcat.o   $(S)_strcpy.o   $(S)_strlen.o \
        $(S)bcmp.o      $(S)bcopy.o     $(S)bzero.o \
        $(S)memccpy.o   $(S)memchr.o    $(S)memcmp.o \
        $(S)memcpy.o    $(S)memmove.o   $(S)memset.o  \
        $(S)stccpy.o    $(S)stpblk.o    $(S)stpcpy.o \
        $(S)strbpl.o \
        $(S)strcat.o    $(S)strchr.o    $(S)strcmp.o    $(S)strcoll.o \
        $(S)strcpy.o    $(S)strcspn.o   $(S)strerror.o \
        $(S)strfnd.o \
        $(S)stricmp.o   $(S)strins.o \
        $(S)strlen.o    $(S)strlwr.o \
        $(S)strmfe.o    $(S)strmfn.o    $(S)strmfp.o \
        $(S)strncat.o   $(S)strncmp.o   $(S)strncpy.o   $(S)strnicmp.o \
        $(S)strpbrk.o   $(S)strpos.o \
        $(S)strrchr.o   $(S)strrev.o    $(S)strrpbrk.o  $(S)strrpos.o \
        $(S)strspn.o    $(S)strstr.o    $(S)strrstr.o \
        $(S)strtok.o    $(S)strupr.o    $(S)strxfrm.o   $(S)syserr.o

STRINGX = $(S)strstrip.o    $(S)strrstip.o 
STRING = $(STRING_RLL) \
        $(S)strdup.o

#   Termios routines
TM = termios/
TERMIOS_RLL =
TERMIOS = $(TERMIOS_RLL) \

#   Time routines
T = time/
TIME_RLL =  $(T)_timeconst.o    $(T)_timetext.o \
            $(T)_time.o \
            $(T)clock.o         $(T)gmtime.o \
            $(T)time.o          $(T)times.o
TIME =  $(TIME_RLL) \
        $(T)_asctime.o \
        $(T)asctime.o       $(T)ctime.o         $(T)difftime.o \
        $(T)jdate.o         $(T)mktime.o \
        $(T)strftime.o      $(T)utime.o

#   Routines in unistd.h
USTD = unistd/
UNISTD_RLL = $(USTD)getpid.o $(USTD)getuid.o    $(USTD)sleep.o  
UNISTD= $(UNISTD_RLL) \
        $(USTD)_cd.o        $(USTD)_chdir.o     $(USTD)_close.o \
        $(USTD)_dup2.o      $(USTD)_exit.o      $(USTD)_forkexec.o \
        $(USTD)_read.o      $(USTD)_unlink.o    $(USTD)_write.o \
        $(USTD)access.o     $(USTD)chdir.o      $(USTD)chown.o \
        $(USTD)close.o      $(USTD)dup.o        $(USTD)dup2.o \
        $(USTD)execl.o      $(USTD)execlp.o \
        $(USTD)execv.o      $(USTD)execvp.o \
        $(USTD)forkl.o      $(USTD)forklp.o \
        $(USTD)forkv.o      $(USTD)forkvp.o     $(USTD)fpathconf.o \
        $(USTD)fsync.o      $(USTD)ftruncate.o \
        $(USTD)getcwd.o     $(USTD)getlogin.o  \
        $(USTD)link.o       $(USTD)lsbrk.o      $(USTD)lseek.o \
        $(USTD)openpipe.o   $(USTD)pathconf.o \
        $(USTD)read.o       $(USTD)rmdir.o \
        $(USTD)sbrk.o       $(USTD)stime.o      $(USTD)sync.o \
        $(USTD)truncate.o   $(USTD)unlink.o     $(USTD)write.o

#   QDOS  Miscellaneous
Q = qdos/misc/
QMISC_RLL = $(Q)_cstrql.o       $(Q)_dtoqlfp.o \
            $(Q)_getcdb.o       $(Q)_isfscdb.o  \
            $(Q)chchown.o       $(Q)fnmatch.o \
            $(Q)getchown.o      $(Q)getsddata.o     $(Q)getsysvar.o \
            $(Q)isdevice.o      $(Q)isdirchid.o     $(Q)isdirdev.o \
            $(Q)itoqlfp.o       $(Q)ltoqlfp.o \
            $(Q)oserrlist.o     $(Q)qdos1.o         $(Q)qdos2.o \
            $(Q)qdos3.o         $(Q)qinstrn.o       $(Q)qlfptod.o\
            $(Q)qlfptof.o       $(Q)qlstrtoc.o \
            $(Q)qstrcat.o       $(Q)qstrchr.o \
            $(Q)qstrcmp.o       $(Q)qstrcpy.o \
            $(Q)qstricmp.o      $(Q)qstrlen.o \
            $(Q)qstrncat.o      $(Q)qstrncmp.o \
            $(Q)qstrnicmp.o     $(Q)qstrncpy.o \
            $(Q)waitfor.o       $(Q)wtoqlfp.o

QMISC = $(QMISC_RLL) \
        $(Q)_fqstat.o   $(Q)_getcd.o    $(Q)_mkname.o   $(Q)_stackerr.o \
        $(Q)argfree.o   $(Q)argpack.o   $(Q)argunpk.o \
        $(Q)beep.o      $(Q)chddir.o    $(Q)chpdir.o    $(Q)conget.o \
        $(Q)fgetchid.o  $(Q)fqstat.o    $(Q)fusechid.o \
        $(Q)getcdd.o    $(Q)getchid.o   $(Q)getcpd.o    $(Q)getcname.o \
        $(Q)isnoclose.o $(Q)keyrow.o    $(Q)openqdir.o \
        $(Q)poserr.o \
        $(Q)qdirread.o  $(Q)qdirsort.o \
        $(Q)qforkl.o    $(Q)qforklp.o   $(Q)qforkv.o    $(Q)qforkvp.o \
        $(Q)qlmknam.o   $(Q)qstat.o \
        $(Q)readqdir.o \
        $(Q)sound.o     $(Q)stackchk.o  $(Q)stackrep.o \
        $(Q)usechid.o

#   QDOS Trap 1
Q1 = qdos/trap1/
TRAP1_RLL = $(Q1)mtactiv.o \
        $(Q1)mtalchp.o  $(Q1)mtalloc.o  $(Q1)mtalres.o  $(Q1)mtbaud.o \
        $(Q1)mtcjob.o   $(Q1)mtclock.o  $(Q1)mtdmode.o  $(Q1)mtinf.o \
        $(Q1)mtipcom.o  $(Q1)mtjinf.o   $(Q1)mtlink.o   $(Q1)mtlnkfr.o \
        $(Q1)mtprior.o  $(Q1)mtrechp.o  $(Q1)mtreljb.o  $(Q1)mtrjob.o \
        $(Q1)mtshrink.o $(Q1)mtsusjb.o  $(Q1)mttrans.o  $(Q1)mttrapv.o \
        $(Q1)smscach.o  $(Q1)smslldm.o  $(Q1)smslset.o  $(Q1)smsiopr.o \
        $(Q1)smsmptr.o  $(Q1)smspset.o  $(Q1)smssevt.o  $(Q1)smswevt.o

TRAP1 = $(TRAP1_RLL)
#   QDOS Trap 2
Q2 = qdos/trap2/
TRAP2_RLL = $(Q2)ioclose.o  $(Q2)iodelete.o $(Q2)ioformat.o $(Q2)ioopen.o \
            $(Q2)ioa_sown.o # $(Q2)ioa_cnam.o 
TRAP2 = $(TRAP2_RLL)

#   QDOS Trap 3
Q3 = qdos/trap3/
TRAP3_RLL = $(Q3)Cextop.o \
        $(Q3)fsdate.o   $(Q3)fsldsv.o   $(Q3)fsmdinf.o  $(Q3)fsmkdir.o \
        $(Q3)fsmisc.o   $(Q3)fspos.o    $(Q3)fsposab.o  $(Q3)fsrename.o \
        $(Q3)ioedlin.o  $(Q3)iofbyte.o  $(Q3)iomisc.o  \
        $(Q3)sdextop.o  $(Q3)sdfount.o \
        $(Q3)sdgraph.o  $(Q3)sdigraph.o $(Q3)sdmisc.o 
TRAP3 = $(TRAP3_RLL)

#   QDOS Vectors
QV = qdos/vect/
QVECT_RLL = \
        $(QV)cndate.o   $(QV)cnito.o \
        $(QV)ioqueue.o  $(QV)ioserio.o  $(QV)ioserq.o  \
        $(QV)mmalloc.o  $(QV)mmalchp.o  $(QV)mmlnkfr.o  $(QV)mmrechp.o \
        $(QV)utcstr.o   $(QV)uterr.o \
        $(QV)utlink.o   $(QV)utmint.o   $(QV)utmtext.o  $(QV)utopen.o \
        $(QV)utunlnk.o  $(QV)utwind.o
QVECT = $(QVECT_RLL)

#   THINGS specific routines
TH = things/
THINGS_RLL= $(TH)bt_frame.o     $(TH)bt_prpos.o     $(TH)hotkey.o \
            $(TH)smsfthg.o      $(TH)smslthg.o \
            $(TH)smsnthg.o      $(TH)smsnthu.o      $(TH)smsrthg.o \
            $(TH)smsuthg.o      $(TH)smszthg.o

THINGS =   $(THINGS_RLL) 

#   Lattice compatibility routines
LT = lattice/
#   Ones for which we do have source
LATTICE_RLL= 

LATTICE=$(LATTICE_RLL) \
        $(LT)dqsort.o   $(LT)envunpk.o  $(LT)fqsort.o \
        $(LT)getch.o    $(LT)getfnl.o   $(LT)getmem.o   $(LT)getml.o \
        $(LT)kbhit.o    $(LT)lqsort.o   $(LT)putch.o \
        $(LT)rlsmem.o   $(LT)rlsml.o    $(LT)setnbf.o \
        $(LT)sizmem.o   $(LT)sqsort.o   $(LT)tqsort.o

#   Routines for which we have no source but do have useable object !
LATOBJ= $(LT)stchi.o    $(LT)stchl.o    $(LT)stcid.o    $(LT)stcih.o \
        $(LT)stcio.o    $(LT)stcld.o    $(LT)stclh.o    $(LT)stclo.o \
        $(LT)stcpm.o    $(LT)stcpma.o   $(LT)stcud.o    $(LT)stculd.o \
        $(LT)CXD33.o    $(LT)CXM33.o
#   Lattice routines not included or supported (yet)
LATTICEX =  $(LT)fqsort.o \
            $(LT)stcarg.o   $(LT)stcdi.o    $(LT)stcdl.o \
            $(LT)stcis.o

#   Pointer Interface routines
QP = qdos/qptr/
QPTR_RLL=   $(QP)iop/flim.o      $(QP)iop/lblb.o \
            $(QP)iop/outl.o      $(QP)iop/pick.o      $(QP)iop/pinf.o \
            $(QP)iop/rptr.o      $(QP)iop/rpxl.o      $(QP)iop/slnk.o \
            $(QP)iop/spry.o      $(QP)iop/sptr.o  \
            $(QP)iop/svpw.o      $(QP)iop/swdf.o \
            $(QP)iop/wblb.o      $(QP)iop/wrst.o \
            $(QP)iop/wsav.o      $(QP)iop/wspt.o \
            $(QP)readmove.o \
            $(QP)wm/action.o  \
            $(QP)wm/chwin.o      $(QP)wm/cluns.o \
            $(QP)wm/drbdr.o \
            $(QP)wm/ename.o      $(QP)wm/erstr.o \
            $(QP)wm/findv.o      $(QP)wm/fsize.o \
            $(QP)wm/idraw.o \
            $(QP)wm/mdraw.o      $(QP)wm/mhit.o       $(QP)wm/msect.o \
            $(QP)wm/pansc.o      $(QP)wm/rptrt.o \
            $(QP)wm/setup.o      $(QP)wm/smenu.o \
            $(QP)wm/stob.o       $(QP)wm/swdef.o      $(QP)wm/swind.o \
            $(QP)wm/wdraw.o \
            $(QP)sprite/arrow.o \
            $(QP)sprite/cf1.o    $(QP)sprite/cf2.o \
            $(QP)sprite/cf3.o    $(QP)sprite/cf4.o \
            $(QP)sprite/f1.o     $(QP)sprite/f2.o     $(QP)sprite/f3.o \
            $(QP)sprite/f4.o     $(QP)sprite/f5.o     $(QP)sprite/f6.o \
            $(QP)sprite/f7.o     $(QP)sprite/f8.o     $(QP)sprite/f9.o \
            $(QP)sprite/f10.o \
            $(QP)sprite/hand.o \
            $(QP)sprite/insg.o   $(QP)sprite/insl.o \
            $(QP)sprite/left.o \
            $(QP)sprite/move.o \
            $(QP)sprite/size.o   $(QP)sprite/sleep.o \
            $(QP)sprite/wake.o \
            $(QP)sprite/zero.o \
            $(QP)ioppick.o       $(QP)trap15.o

QPTR= $(QPTR_RLL)


#   C68 Compiler Support routines
SP   = lib68k/
IEEE = libieee/

C68OBJ_RLL= \
        $(SP)Xalloca32.o  $(SP)Xdiv.o       $(SP)Xmul.o \
        $(SP)Xbfasop.o    $(SP)Xbfget.o     $(SP)Xbfput.o \
	$(SP)GXmul.o      $(SP)GXdiv.o \
        $(IEEE)Xnorm4.o   $(IEEE)Xnorm8.o \
        $(IEEE)sfcmp.o	  $(IEEE)dfcmp.o \
        $(IEEE)Yasdivsf.o $(IEEE)Yasdivdf.o \
        $(IEEE)Yasmulsf.o $(IEEE)Yasmuldf.o \
        $(IEEE)Yasopsf.o  $(IEEE)Yasopdf.o \
        $(IEEE)Ysfadd.o   $(IEEE)Ydfadd.o  \
        $(IEEE)Ysfdiv.o   $(IEEE)Ydfdiv.o \
        $(IEEE)Ysfmul.o   $(IEEE)Ydfmul.o \
        $(IEEE)Ysfneg.o   $(IEEE)Ydfneg.o  \
        $(IEEE)Ysfinc.o   $(IEEE)Ydfinc.o  \
        ${IEEE}Ysftst.o   ${IEEE}Ydftst.o \
        $(IEEE)Ysftodf.o  $(IEEE)Ydftosf.o \
        $(IEEE)Ysfltosf.o $(IEEE)Ydfltodf.o \
        $(IEEE)Ysfutosf.o $(IEEE)Ydfutodf.o \
        $(IEEE)Ysftol.o   $(IEEE)Ydftol.o  \
        $(IEEE)Ysftoul.o  $(IEEE)Ydftoul.o \
        $(IEEE)FPcheck.o \
        $(IEEE)GYdfadd.o  $(IEEE)GYdfdiv.o   $(IEEE)GYdfltodf.o \
        $(IEEE)GYdfmul.o  $(IEEE)GYdftol.o   $(IEEE)GYdftosf.o \
        $(IEEE)GYsfadd.o  $(IEEE)GYsfdiv.o   $(IEEE)GYsfltosf.o \
        $(IEEE)GYsfmul.o  $(IEEE)GYsftodf.o  $(IEEE)GYsftol.o

#       $(SP)Xlldiv.o	  $(SP)Xllmul.o     $(SP)Xllshift.o

#   long double support routines that are not yet ready for use
#        $(IEEE)XNorm12.o)\
#        $(IEEE)lfcmp.o \
#        $(IEEE)Ysftolf.o \
#        $(IEEE)Ydftolf.o \
#        $(IEEE)Yasdivlf.o \
#        $(IEEE)Yasmullf.o \
#        $(IEEE)Yasoplf.o \
#        $(IEEE)Ylfadd.o  \
#        $(IEEE)Ylfdiv.o \
#        $(IEEE)Ylfmul.o \
#        $(IEEE)Ylfneg.o \
#        $(IEEE)Ylfinc.o \
#        $(IEEE)Ylftst.o \
#        $(IEEE)Ylftosf.o \
#        $(IEEE)Ylftodf.o \
#        $(IEEE)Ylfltolf.o \
#        $(IEEE)Ylfutolf.o \
#        $(IEEE)Ylftol.o \
#        $(IEEE)Ylftoul.o 

#   coldfire support routines that are not yet completed
#       $(IEEE)Xascdiv.o \
#       $(IEEE)Xasucdiv.o \
#       $(IEEE)Xassdiv.o \
#       $(IEEE)Xasusdiv.o \
#       $(IEEE)Xsdiv.o  \
#       $(IEEE)Xusdiv.o

# C68OBJ= $(C68OBJ_RLL) $(C68OLD) \

C68OBJ= $(C68OBJ_RLL) \
        $(SP)stackcheck.o $(SP)stmttrace.o \
        $(IEEE)frexp.o  $(IEEE)ldexp.o  $(IEEE)modf.o   $(IEEE)modff.o \
        $(IEEE)Xerror.o 

#   Old c68 routines retained for compatibility with old libraries

# C68OLD =$(SP)Xdivs.o   $(SP)Xdivu.o $(SP)Xmuls.o     $(SP)Xmulu.o 
C68OLD= $(IEEE)asdiv.o   $(IEEE)asmul.o   $(IEEE)asop.o \
        $(IEEE)dfadd.o   $(IEEE)dfdiv.o  $(IEEE)dfltodf.o \
        $(IEEE)dfneg.o   $(IEEE)dfmul.o   $(IEEE)dftol.o  $(IEEE)dftosf.o \
        $(IEEE)dftoul.o  $(IEEE)dftst.o   $(IEEE)dfutodf.o \
        $(IEEE)sfadd.o   $(IEEE)sfdiv.o  $(IEEE)sfltosf.o \
        $(IEEE)sfmul.o   $(IEEE)sfneg.o   $(IEEE)sftodf.o $(IEEE)sftol.o \
        $(IEEE)sftoul.o  $(IEEE)sftst.o   $(IEEE)sfutosf.o \

MFFP = libmffp/
#   Motoroloa MFFP routines
#       $(MFFP)fpadd.o  $(MFFP)fpcmp.o  $(MFFP)fpconv.o \
#       $(MFFP)fpdiv.o  $(MFFP)fpmult.o
#   A list of all the headers used by C68.  We need to check that
#   the 'packed' version is more recent than the full commented
#   version

#   This is a special library that is pulled in if hardware in-line
#   floating point instructions have been generated.  It is used to
#   ensure that such programs are not run on systems that do not
#   have such support.

LIBFPU =    $(IN)libfpu.o

LIBXT  =    $(IN)libxt.o

LIBXA  =    $(IN)libxa.o

LIBXC  =    $(IN)libxc.o

HEADERS =   $(I)arpa/ftp.h      $(I)arpa/inet.h     $(I)arpa/telnet.h \
            $(I)ansicondef.h    $(I)assert.h        $(I)basic.h \
            $(I)channels.h  $(I)ctype.h     $(I)curses.h \
            $(I)debug.h     $(I)dirent.h  \
            $(I)errno.h     $(I)fcntl.h     $(I)float.h \
            $(I)grp.h \
            $(I)iso646.h \
            $(I)langinfo.h  $(I)libgen.h    $(I)limits.h    $(I)locale.h \
            $(I)malloc.h    $(I)math.h      $(I)memory.h \
            $(I)netdb.h     $(I)nice.h      $(I)nl_types.h \
            $(I)netinet/in.h    $(I)netinet/in_systm.h \
            $(I)netinet/ip.h    $(I)netinet/ip_icmp.h   $(I)netinet/ip_var.h \
            $(I)netinet/tcp.h   $(I)netinet/udp.h \
            $(I)pwd.h \
            $(I)qdos.h      $(I)qptr.h \
            $(I)rll.h \
            $(I)setjmp.h        $(I)signal.h        $(I)sms.h \
            $(I)sockaddrcom.h   $(I)sroff.h \
            $(I)std.h       $(I)stdarg.h     $(I)stddef.h \
            $(I)stdlib.h    $(I)stdio.h      $(I)string.h  \
            $(I)sys/math.h  $(I)sys/qlib.h \
            $(I)sys/bsdtypes.h  $(I)sys/file.h \
            $(I)sys/ioctl.h     $(I)sys/param.h \
            $(I)sys/select.h    $(I)sys/signal.h    $(I)sys/socket.h   \
            $(I)sys/stat.h      $(I)sys/sysdefs.h   $(I)sys/trapdefs.h \
            $(I)sys/times.h     $(I)sys/types.h     $(I)sys/wait.h \
            $(I)term.h      $(I)termios.h    $(I)things.h    $(I)time.h \
            $(I)un.h        $(I)unctrl.h    $(I)unistd.h     $(I)utime.h   \
            $(I)varargs.h \
            $(I)wchar.h     $(I)wctype.h

all :   libc.a  libfpu.a libxt.a libxa.a libxc.a

# all :   libc.a libc.rll

#
#   Standard C library.
#
LIBOBJASM = $(THINGS)  $(QVECT)   $(TRAP1)  $(TRAP2)  $(TRAP3)  $(QPTR)

LIBOBJ =    $(QMISC)    $(LATTICE)  $(CTYPE)    $(GEN)    $(GRP) \
            $(TIME)     $(SIGNAL)   $(STDLIB)   $(PWD)    $(FCNTL) \
            $(DIRENT)   $(UNISTD)   $(STRING)   $(STAT)   $(SETJMP) \
            $(LOCALE)   $(TERMIOS)  $(MISC)     $(DEFAULT)  $(INIT)

#
#   These functions must ALWAYS be at the start of the
#   LIBC librayr in exactly the order given
#
LIBSTART = $(DF)Cstart.o $(IN)Cinit.o $(SIGSTART)


#
#   These functions must ALWAYS be at the end of the LIBC_A
#   library in exactly the order given.   This is so that
#   we can supply alternative implementations of some key
#   vectors if no explicit library calls inside program.
#

LIBEND = $(SIGEND) $(DF)reloc.o

pre_comp:
	./precomp

libc.a : pre_comp $(HEADERS) $(C68OBJ) $(LIBOBJASM) $(LIBOBJ)\
         $(STDIO) $(LIBSTART) $(LIBEND) $(IN)libc.o \
         slbstart slblist slbend wlist ylist wlist.rll ylist.rll
	$(RM) -f libc.a
	$(SLB) -crv libc.a $(IN)libc.o 
	$(SLB) -crv -mslbstart libc.a
	$(SLB) -crv -mslblist libc.a
	$(SLB) -crv -mslbend libc.a

libfpu.a : $(LIBFPU)
	$(SLB) -crv libfpu.a $(LIBFPU)

libxa.a  : $(LIBXA)
	$(SLB) -crv libxa.a $(LIBXA)

libxc.a  : $(LIBXC)
	$(SLB) -crv libxc.a $(LIBXC)

libxt.a  : $(LIBXT)
	$(SLB) -crv libxt.a $(LIBXT)

$(IN)crt.x      :  $(IN)crtjob.x    $(IN)crtdata.x \
                   $(IN)proctype.x  $(IN)cache.x
#	@touch  $(IN)crt.x

$(IN)crt.o      :  $(IN)crt.x       $(IN)relocGST.x $(IN)relocLD.x \
                   $(IN)proctype.x  $(IN)cache.x    $(IN)Cinit.x \
                   $(IN)crtjob.x    $(IN)crtdata.x 
#	$(CC) -c -I$(C)init/ $(IN)crt.x

$(IN)crespr.x   :  $(IN)crtdata.x   $(IN)proctype.x  $(IN)cache.x
#	@touch  $(IN)crespr.x

$(IN)crespr.o   :  $(IN)crespr.x    $(IN)relocGST.x $(IN)relocLD.x
#	$(CC) -c -I$(C)init/ $(IN)crespr.x

$(IN)crtrll.x   :  $(IN)crtjob.x    $(IN)crtdata.x \
                   $(IN)callRLM.x   $(IN)thingtrap.x
#	@touch  $(IN)crtrll.x

$(IN)crtrll.o   :  $(IN)crtrll.x
#	$(CC) -c -I$(C)init/ $(IN)crtrll.x

$(IN)asmstart.o : $(IN)asmstart.x
#	$(CC) -c $(IN)asmstart.x

$(IN)qlstart.o  :  $(IN)crt.x       $(IN)relocGST.x $(IN)relocLD.x \
                   $(IN)proctype.x  $(IN)cache.x    $(IN)Cinit.x \
                   $(IN)crtjob.x    $(IN)crtdata.x 
	$(CP) -f $(IN)crt.x $(IN)qlstart.x
	$(AS) $(ASFLAGS) -DGST $(IN)qlstart.x -o $(IN)qlstart.o
	$(RM) -f $(IN)qlstart.x

wlist : slblist slbstart slbend $(IN)crt.o
	@$(SLB) -vU -Wwlist -mslblist $(IN)crt.o \
                        $(LIBSTART) $(IN)libc.o $(LIBEND)

ylist : slblist slbstart
	@$(SLB) -vU -Yylist -mslbstart -mslblist -mslbend $(IN)crt.o $(IN)libc.o

slblist: init
	@$(SLB) -v -Lslblist.tmp $(C68OBJ) $(LIBOBJASM) $(LIBOBJ) $(STDIO)
	tsort slblist.tmp >slblist
	@rm -fv libc.a slblist.tmp wlist wlist.rll ylist ylist.rll

slbstart : $(LIBSTART)
	@$(SLB) -v -Lslbstart.tmp $(LIBSTART)
	tsort slbstart.tmp >slbstart
	@rm -fv slbstart.tmp

slbend : $(LIBEND)
	@$(SLB) -v -Lslbend.tmp $(LIBEND)
	tsort slbend.tmp >slbend
	@rm -fv slbend.tmp

#
#   RLL version of C library
#   (contains subset of routines in full C library)
#
LIBOBJ_RLL= $(THINGS_RLL)   $(QVECT_RLL)    $(TRAP1_RLL)    $(TRAP2_RLL) \
            $(TRAP3_RLL)    $(QPTR_RLL)     $(QMISC_RLL)    $(LATTICE_RLL) \
            $(CTYPE_RLL)    $(GEN_RLL)      $(TIME_RLL)     $(SIGNAL) \
            $(STDLIB_RLL)   $(PWD_RLL)      $(FCNTL_RLL)    $(DIRENT_RLL) \
            $(UNISTD_RLL)   $(STRING_RLL)   $(STAT_RLL)     $(TERMIOS_RLL) \
            $(MISC_RLL)     $(DEFAULT_RLL)  $(INIT_RLL)     $(C68OBJ_RLL)

libc.rll : libc.a $(IN)libcrll.o wlist.rll ylist.rll
	ld -R -S $(IN)libcrll.o $(C68OBJ) $(LIBOBJ_RLL)

slblist.rll:
	@$(SLB) -v -Lslblist.tmp $(LIBOBJ_RLL)
	tsort slblist.tmp >slblist.rll
	@rm -fv libc.a slblist.tmp wlist wlist.rll ylist ylist.rll

wlist.rll : $(LIBOBJ_RLL)
	@$(SLB) -vU -Wwlist.rll $(LIBOBJ_RLL)

ylist.rll : $(LIBOBJ_RLL) 
	@$(SLB) -v -Yylist.rll $(LIBOBJ_RLL)


#
#   The following have special rules so that they can be compiled
#   with additional compiler options.  That is because these
#   routines are recursive, and so should not be used with
#   lazy stack optimisation as they could use excessive stack space,
#   or their names begin with undersocre and they change the stack.

$(G)gnmatch.o : $(G)gmatch.c
	$(CC) $(CCFLAGS) -O1 $(G)gmatch.c -o $(G)gmatch.o

$(IN)_envsetup.o : $(IN)_envsetup.c
	$(CC) $(CCFLAGS) -O1 $(IN)_envsetup.c -o $(IN)_envsetup.o

$(STD)_qsort.o : $(STD)_qsort.x
	$(AS) $(ASFLAGS) $(STD)_qsort.x -o $(STD)_qsort.o

# $(Q)getcname.o : $(Q)getcname.c
#    $(CC) -Qstackopt=minimum $(CCFLAGS) $(Q)getcname.c

$(Q)isdirchid.o : $(Q)isdirchid.c
	$(CC) $(CCFLAGS) -O1 $(Q)isdirchid.c -o $(Q)isdirchid.o

$(Q)isdirdev.o : $(Q)isdirdev.c
	$(CC) $(CCFLAGS) -O1 $(Q)isdirdev.c -o $(Q)isdirdev.o

# $(ST)_fakeino.o : $(ST)_fakeino.c
#    $(CC) -Qstackopt=minimum $(CCFLAGS) $(ST)_fakeino.c

#
#   Default rules
#
.x.o:
	$(AS) $(ASFLAGS) $(ASDEFINES) $< -o $@
#	$(CC) $(CCFLAGS) $<

#.x,v.o :
#    $(CO) -p $(COFLAGS) $< >$*.x
#    $(CC) $(CCFLAGS) $*.x
#    $(RM) $(RMFLAGS) $*.x

.c.o:
	$(CC) $(CCFLAGS) $(OPTFLAGS) $< -o $@

#.c,v.o :
#    $(CO) -p $(COFLAGS) $< >$*.c
#    $(CC) -Qstackopt=maximum $(CCFLAGS) $*.c
#    $(RM) $(RMFLAGS) $*.c

.s.o:
	$(AS) $(ASFLAGS) $(ASDEFINES) $< -o $@

#.s,v.o :
#    $(CO) -p $(COFLAGS) $< >$*.s
#    $(AS) $(ASFLAGS) $*.s
#    $(RM) $(RMFLAGS) $*.s

.asm.o:
	$(MAC) $< -ERRORS $*.list -BIN $@ -NOWINDS

.hdr.h:
	packhdr $< $@

#
#   The following are used to allow only a sub-section 
#   of the library to be recompiled.  This is particularily
#   useful in development and test modes
#
header: $(HEADERS)

crt:	$(CRTOBJ)

ctype:	$(CTYPE)

default:$(DEFAULT)

dirent: $(DIRENT)

fcntl:	$(FCNTL)

gen:	$(GEN)

grp:	$(GRP)

init:	$(CRTOBJ) $(INIT)

misc:	$(MISC)

pwd:	$(PWD)

signal: $(SIGNAL)

stdio:	$(STDIO)
#	echo "Run Makefile in STDIO directory"

termios:$(TERMIOS)

time:	$(TIME)

string: $(STRING)

stdlib: $(STDLIB)

stat:	$(STAT)

unistd: $(UNISTD)

trap1:	$(TRAP1)

trap2:	$(TRAP2)

trap3:	$(TRAP3)

qmisc:	$(QMISC)

qvect:	$(QVECT)

things: $(THINGS)

qptr:	$(QPTR)

lattice:$(LATTICE)

#
#   Standard utility capabilities
#
install: libc.a $(IN)crt.o $(IN)crespr.o $(IN)qlstart.o
	$(CP) -f libc.a $(LIBDIR)libc.a
	$(CP) -rf $(I)* $(INCDIR)
# Although the following should work, the modules are untested. It is better
# to use v4.24i crt.o/crespr.o/qlstart.o then...
#
#	$(RM) -f $(LIBDIR)crt.o $(LIBDIR)crespr.o $(LIBDIR)qlstart.o
#	$(SLB) -cr $(LIBDIR)crt.o $(IN)crt.o
#	$(SLB) -cr $(LIBDIR)crespr.o $(IN)crespr.o
#	$(SLB) -cr $(LIBDIR)qlstart.o $(IN)qlstart.o
	$(CP) -f $(IN)crt.o $(LIBDIR)crt.o
	$(CP) -f $(IN)crespr.o $(LIBDIR)crespr.o
	$(CP) -f $(IN)qlstart.o $(LIBDIR)qlstart.o

clean:
	$(FIND) . -name "*.o" -exec rm {} \;

distclean: clean
	$(RM) -f lib*.a wlist* ylist* slb*

install-includes:
	$(CP) -rf $(I)* $(INCDIR)

#------------------------ Header file dependencies -------------------------
#   This section identifies all depenedencies of the files making up the
#   library on local and system header files.  The accuracy of these
#   dependencies is important to avoid having to rebuild the whole of
#   the library if a single header changes.
#----------------------------------------------------------------------------

$(I)qdos.h      : $(I)sys/qlib.h
$(I)sms.h       : $(I)sys/qlib.h
$(I)sys/qlib.h  : $(I)limits.h $(I)sys/types.h

#   Initialisation routines
$(IN)_bss.o     :  
$(IN)crt.o      :   
$(IN)crespr.o   :   
$(IN)qlstart.o  :   
$(IN)_cmdchans.o:   $(I)qdos.h      $(I)fcntl.h     $(I)stdlib.h    $(I)string.h
$(IN)_cmdline.o :   $(I)qdos.h      $(I)stdlib.h
$(IN)_cmdparse.o :  $(I)qdos.h      $(I)ctype.h     $(I)string.h    $(I)stdlib.h
$(IN)_envsetup.o:   $(I)qdos.h      $(I)basic.h     $(I)string.h    $(I)stdlib.h
$(IN)_initcon.o:    $(I)qdos.h
$(IN)_stdchans.o :  $(I)qdos.h      $(I)fcntl.h     $(I)string.h    $(I)stdlib.h
$(IN)_stkchans.o:   $(I)qdos.h      $(I)fcntl.h
$(IN)cmdexpand.o:   $(I)qdos.h      $(I)stdlib.h    $(I)string.h    $(I)errno.h
$(IN)cmdnowild.o:   $(I)qdos.h      $(I)stdlib.h
$(IN)condefault.o:  $(I)qdos.h
$(IN)conqpac.o :    $(I)qdos.h      $(I)qptr.h
$(IN)contitle.o :   $(I)qdos.h  $(I)string.h
#   Default routine
$(DF)cmdchans.o :   $(I)qdos.h
$(DF)cmdparams.o:   $(I)qdos.h
$(DF)cmdwild.o  :   $(I)qdos.h
$(DF)consetup.o :   $(I)qdos.h
$(DF)readkbd.o  :   $(I)qdos.h
$(DF)stkchans.o :   $(I)qdos.h
#   Memory routines (BSD compatible)
$(M)bcmp.o      :   $(I)memory.h
$(M)bcopy.o     :   $(I)memory.h
$(M)bzero.o     :   $(I)memory.h
#   Earl chew's stdio package
# $(IO)stdiolib.h :   $(IO)config.h   $(IO)site.h
# $(IO)stdiolib.h :   $(IO)config.h   $(IO)site.h   \
#                     $(I)errno.h     $(I)fcntl.h     $(I)limits.h \
#                     $(I)stdio.h     $(I)time.h      $(I)unistd.h \
#                     $(I)sys/stat.h  $(I)sys/types.h
#       touch $(IO)stdiolib.h
# $(IO)_allocbuf.o:   $(IO)stdiolib.h
# $(IO)_bfs.o     :   $(IO)stdiolib.h
# $(IO)_bread.o   :   $(IO)stdiolib.h
# $(IO)_bwrite.o  :   $(IO)stdiolib.h
# $(IO)_err.o     :   $(IO)stdiolib.h
# $(IO)_errlist.o :   $(IO)stdiolib.h $(IO)errlist.h
# $(IO)_fgetlx.o  :   $(IO)stdiolib.h
# $(IO)_file.o    :   $(IO)stdiolib.h
# $(IO)_fopen.o   :   $(IO)stdiolib.h
# $(IO)_freebuf.o :   $(IO)stdiolib.h
# $(IO)_in.o      :   $(IO)stdiolib.h
# $(IO)_ioread.o  :   $(IO)stdiolib.h
# $(IO)_iowrite.o :   $(IO)stdiolib.h
# $(IO)_ipow10.o  :   $(IO)stdiolib.h
# $(IO)_open3.o   :   $(IO)stdiolib.h
# $(IO)_os.o      :   $(IO)stdiolib.h
# $(IO)_out.o     :   $(IO)stdiolib.h
# $(IO)_rename.o  :   $(IO)stdiolib.h
# $(IO)_rlbf.o    :   $(IO)stdiolib.h
# $(IO)_stdio.o   :   $(IO)stdiolib.h
# $(IO)_update.o  :   $(IO)stdiolib.h
# $(IO)_utoa.o    :   $(IO)stdiolib.h
# $(IO)_vfprintf.o:   $(IO)stdiolib.h
# $(IO)_vfscanf.o :   $(IO)stdiolib.h
# $(IO)_vscanf.o  :   $(IO)stdiolib.h
# $(IO)_vsscanf.o :   $(IO)stdiolib.h
# $(IO)_xassert.o :   $(IO)stdiolib.h
# $(IO)_z_cvt.o   :   $(IO)stdiolib.h
# $(IO)_z_tvc.o   :   $(IO)stdiolib.h
# $(IO)_zatexit.o :   $(IO)stdiolib.h
# $(IO)_zerr.o    :   $(IO)stdiolib.h
# $(IO)_zout.o    :   $(IO)stdiolib.h
# $(IO)_zrlbf.o   :   $(IO)stdiolib.h
# $(IO)_zwrapup.o :   $(IO)stdiolib.h
# $(IO)atexit.o   :   $(IO)stdiolib.h
# $(IO)clearerr.o :   $(IO)stdiolib.h
# $(IO)exit.o     :   $(IO)stdiolib.h
# $(IO)fclose.o   :   $(IO)stdiolib.h
# $(IO)fdopen.o   :   $(IO)stdiolib.h
# $(IO)feof.o     :   $(IO)stdiolib.h
# $(IO)ferror.o   :   $(IO)stdiolib.h
# $(IO)fflush.o   :   $(IO)stdiolib.h
# $(IO)fgetc.o    :   $(IO)stdiolib.h
# $(IO)fgetpos.o  :   $(IO)stdiolib.h
# $(IO)fgets.o    :   $(IO)stdiolib.h
# $(IO)fileno.o   :   $(IO)stdiolib.h
# $(IO)fopen.o    :   $(IO)stdiolib.h
# $(IO)fprintf.o  :   $(IO)stdiolib.h
# $(IO)fputc.o    :   $(IO)stdiolib.h
# $(IO)fputs.o    :   $(IO)stdiolib.h
# $(IO)fread.o    :   $(IO)stdiolib.h
# $(IO)freopen.o  :   $(IO)stdiolib.h
# $(IO)fscanf.o   :   $(IO)stdiolib.h
# $(IO)fseek.o    :   $(IO)stdiolib.h
# $(IO)fsetpos.o  :   $(IO)stdiolib.h
# $(IO)ftell.o    :   $(IO)stdiolib.h
# $(IO)fwrite.o   :   $(IO)stdiolib.h
# $(IO)getc.o     :   $(IO)stdiolib.h
# $(IO)getchar.o  :   $(IO)stdiolib.h
# $(IO)gets.o     :   $(IO)stdiolib.h
# $(IO)getw.o     :   $(IO)stdiolib.h
# $(IO)perror.o   :   $(IO)stdiolib.h
# $(IO)printf.o   :   $(IO)stdiolib.h
# $(IO)putc.o     :   $(IO)stdiolib.h
# $(IO)putchar.o  :   $(IO)stdiolib.h
# $(IO)puts.o     :   $(IO)stdiolib.h
# $(IO)putw.o     :   $(IO)stdiolib.h
# $(IO)remove.o   :   $(IO)stdiolib.h
# $(IO)rewind.o   :   $(IO)stdiolib.h
# $(IO)scanf.o    :   $(IO)stdiolib.h
# $(IO)setbuf.o   :   $(IO)stdiolib.h
# $(IO)setvbuf.o  :   $(IO)stdiolib.h
# $(IO)sprintf.o  :   $(IO)stdiolib.h
# $(IO)sscanf.o   :   $(IO)stdiolib.h
# $(IO)tmpfile.o  :   $(IO)stdiolib.h
# $(IO)tmpnam.o   :   $(IO)stdiolib.h
# $(IO)ungetc.o   :   $(IO)stdiolib.h
# $(IO)vfprintf.o :   $(IO)stdiolib.h
# $(IO)vprintf.o  :   $(IO)stdiolib.h
# $(IO)vsprintf.o :   $(IO)stdiolib.h
#   Character testing and conversion routines
$(CH)ctype.o    :   $(I)ctype.h
$(CH)isalnum.o  :   $(I)ctype.h
$(CH)isalpha.o  :   $(I)ctype.h
$(CH)isascii.o  :   $(I)ctype.h
$(CH)iscntrl.o  :   $(I)ctype.h
$(CH)iscsym.o   :   $(I)ctype.h
$(CH)iscsymf.o  :   $(I)ctype.h
$(CH)isdigit.o  :   $(I)ctype.h
$(CH)isgraph.o  :   $(I)ctype.h
$(CH)islower.o  :   $(I)ctype.h
$(CH)isprint.o  :   $(I)ctype.h
$(CH)ispunct.o  :   $(I)ctype.h
$(CH)isspace.o  :   $(I)ctype.h
$(CH)isupper.o  :   $(I)ctype.h
$(CH)isxdigit.o :   $(I)ctype.h
$(CH)toascii.o  :   $(I)ctype.h
$(CH)tolower.o  :   $(I)ctype.h
$(CH)toupper.o  :   $(I)ctype.h
#   dirent.h routines
$(DIR)closedir.o:   $(I)dirent.h
$(DIR)opendir.o :   $(I)qdos.h      $(I)dirent.h    $(I)string.h    $(I)stdlib.h \
                    $(I)errno.h
$(DIR)readdir.o :   $(I)qdos.h      $(I)dirent.h    $(I)errno.h     $(I)string.h
$(DIR)rewinddir.o:  $(I)dirent.h
$(DIR)seekdir.o :   $(I)dirent.h
$(DIR)telldir.o :   $(I)dirent.h
#   fcntl.h routines
$(F)_chkufb.o   :   $(I)fcntl.h     $(I)errno.h
$(F)_conread.o  :   $(I)fcntl.h     $(I)qdos.h
$(F)_conwrite.o :   $(I)fcntl.h     $(I)qdos.h      $(I)string.h
$(F)_creat.o    :   $(I)fcntl.h
$(F)_doopene.o  :   $(I)qdos.h
$(F)_newufb.o   :   $(I)fcntl.h     $(I)stdlib.h    $(I)string.h    $(I)errno.h
$(F)_open.o     :   $(I)fcntl.h     $(I)qdos.h      $(I)ctype.h \
                    $(I)errno.h     $(I)unistd.h
$(F)_openufb.o  :   $(I)fcntl.h     $(I)errno.h
$(F)fcntl.o     :   $(I)fcntl.h     $(I)errno.h
$(F)fdmode.o    :   $(I)qdos.h      $(I)fcntl.h     $(I)stdio.h     $(I)errno.h
$(F)iomode.o    :   $(I)fcntl.h
$(F)opene.o     :   $(I)qdos.h      $(I)fcntl.h
$(F)qopen.o     :   $(I)fcntl.h     $(I)libgen.h   $(I)string.h     $(I)sys/stat.h
#   libgen.h routines
$(G)_streadd.o  :   $(I)libgen.h    $(I)ctype.h     $(I)string.h    $(I)qdos.h
$(G)gmatch.o    :   $(I)libgen.h
$(G)strcadd.o   :   $(I)libgen.h    $(I)string.h    $(I)qdos.h
$(G)strccpy.o   :   $(I)libgen.h
$(G)strtrns.o   :   $(I)libgen.h
#   Routines from grp.h
$(GR)getgrent.o :   $(I)grp.h       $(I)stddef.h
$(GR)getgrnam.o:    $(I)grp.h       $(I)string.h
$(GR)getgrgid.o :   $(I)grp.h       $(I)stddef.h
#   Lattice compatibility routines
$(LT)dqsort.o   :   $(I)stdlib.h
$(LT)envunpk.o  :   $(I)stdlib.h    $(I)string.h    $(I)unistd.h
$(LT)fqsort.o   :   $(I)stdlib.h    $(I)sys/types.h
$(LT)getch.o   :    $(I)qdos.h
$(LT)getfnl.o   :   $(I)qdos.h      $(I)errno.h     $(I)string.h
$(LT)getmem.o   :   $(I)stdlib.h
$(LT)getml.o    :
$(LT)kbhit.o    :   $(I)qdos.h
$(LT)lqsort.o   :   $(I)stdlib.h
$(LT)putch.o    :   $(I)qdos.h
$(LT)rlsmem.o   :
$(LT)rlsml.o    :   $(I)unistd.h    $(I)assert.h    $(I)errno.h     $(I)qdos.h
$(LT)setnbf.o   :   $(I)stdio.h
$(LT)sizmem.o   :
$(LT)sqsort.o   :   $(I)stdlib.h
$(LT)tqsort.o   :   $(I)stdlib.h    $(I)string.h
#   Routines from locale.h
$(LC)setlocale.o:   $(I)locale.h    $(I)limits.h
#   Miscellaneous stuff with no other home
$(MS)assert.o  :    $(I)assert.h    $(I)qdos.h      $(I)string.h    $(I)unistd.h
$(MS)cprintf.o :    $(I)stdio.h     $(I)qdos.h
$(MS)cscanf.o  :    $(I)stdio.h     $(I)qdos.h
$(MS)fopene.o   :   $(I)stdio.h     $(I)fcntl.h
$(MS)frexp.o   :    $(I)float.h     $(I)math.h
$(MS)iscon.o   :
$(MS)ldexp.o   :    $(I)float.h     $(I)math.h      $(I)errno.h
$(MS)matherr.o :    $(I)math.h
$(MS)modf.o    :    $(I)float.h     $(I)math.h
$(MS)pclose.o  :    $(I)unistd.h    $(I)qdos.h      $(I)stdio.h \
                    $(I)fcntl.h     $(I)errno.h
$(MS)popen.o   :    $(I)unistd.h    $(I)qdos.h      $(I)stdio.h \
                    $(I)errno.h     $(I)fcntl.h     $(I)stdlib.h
$(MS)rename.o  :    $(I)qdos.h      $(I)stdio.h     $(I)errno.h
$(MS)wait.o    :
#   Routines from pwd.h
$(PW)getpwent.o :   $(I)pwd.h       $(I)stddef.h
$(PW)getpwnam.o:    $(I)pwd.h       $(I)string.h
$(PW)getpwuid.o :   $(I)pwd.h       $(I)stddef.h
#Routines froms etjmp.h
$(SJ)setjmp.o:
#   Routines from signal.h
$(SIG)_current.o    : $(I)signal.h  $(I)sys/signal.h $(I)unistd.h
$(SIG)_default.o    : $(I)signal.h  $(I)sys/signal.h
$(SIG)_onsigkill.o  : $(I)signal.h  $(I)sys/signal.h $(I)qdos.h $(I)errno.h
$(SIG)_samask.o     : $(I)sys/signal.h
$(SIG)_uval.o       : $(I)sys/signal.h
$(SIG)_signal.o     : $(I)signal.h  $(I)sys/signal.h
$(SIG)alarm.o       : $(I)signal.h  $(I)sys/signal.h $(I)unistd.h  $(I)qdos.h
$(SIG)checksig.o    : $(I)signal.h  $(I)sys/signal.h
$(SIG)kill.o        : $(I)signal.h  $(I)sys/signal.h
$(SIG)pause.o       : $(I)unistd.h  $(I)errno.h     $(I)qdos.h
$(SIG)psignal.o     : $(I)signal.h  $(I)string.h    $(I)stdlib.h    $(I)stdio.h
$(SIG)raise.o       : $(I)signal.h  $(I)sys/signal.h $(I)unistd.h
$(SIG)sendsig.o     : $(I)signal.h  $(I)sys/signal.h
$(SIG)sigaction.o   : $(I)signal.h  $(I)sys/signal.h
$(SIG)sigaddset.o   : $(I)signal.h  $(I)sys/signal.h $(I)errno.h
$(SIG)sigcurrent.o  : $(I)signal.h  $(I)sys/signal.h
$(SIG)sigdelset.o   : $(I)signal.h  $(I)sys/signal.h $(I)errno.h
$(SIG)sigdefault.o  : $(I)signal.h  $(I)sys/signal.h
$(SIG)sigemptyset.o : $(I)signal.h  $(I)sys/signal.h
$(SIG)sigfillset.o  : $(I)signal.h  $(I)sys/signal.h
$(SIG)sighold.o     : $(I)signal.h  $(I)sys/signal.h
$(SIG)sigignore.o   : $(I)signal.h
$(SIG)siginit.o     : $(I)signal.h  $(I)sys/signal.h
$(SIG)sigismember.o : $(I)signal.h  $(I)sys/signal.h $(I)errno.h
$(SIG)siglongjmp.o  : $(I)signal.h  $(I)sys/signal.h $(I)setjmp.h
$(SIG)signal.o      : $(I)signal.h  $(I)sys/signal.h $(I)errno.h
$(SIG)sigpause.o    : $(I)signal.h  $(I)sys/signal.h
$(SIG)sigpending.o  : $(I)signal.h  $(I)sys/signal.h
$(SIG)sigprocmaks.o : $(I)signal.h  $(I)sys/signal.h
$(SIG)sigrelse.o    : $(I)signal.h  $(I)sys/signal.h
$(SIG)sigset.o      : $(I)signal.h  $(I)sys/signal.h $(I)errno.h
$(SIG)sigsetjmp.o   : $(I)signal.h  $(I)sys/signal.h $(I)setjmp.h
$(SIG)sigsuspend.o  : $(I)signal.h  $(I)sys/signal.h $(I)errno.h     $(I)sms.h
$(SIG)timer.o       : $(I)signal.h  $(I)sys/signal.h

#   Routines from sys/stat.h
$(ST)_fakeino.o : $(I)sys/stat.h $(I)qdos.h     $(I)channels.h
$(ST)_fstat.o   : $(I)sys/stat.h $(I)qdos.h     $(I)channels.h  $(I)fcntl.h \
                  $(I)string.h   $(I)errno.h
$(ST)_stat.o    : $(I)sys/stat.h $(I)qdos.h     $(I)errno.h     $(I)fcntl.h \
                  $(I)string.h   $(I)unistd.h
$(ST)chmod.o    : $(I)sys/stat.h $(I)qdos.h     $(I)fcntl.h     $(I)unistd.h
$(ST)fchmod.o   : $(I)sys/stat.h $(I)qdos.h     $(I)errno.h     $(I)fcntl.h \
                  $(I)unistd.h  
$(ST)fstat.o    : $(I)sys/stat.h $(I)errno.h    $(I)fcntl.h
$(ST)mkdir.o    : $(I)sys/stat.h $(I)qdos.h     $(I)fcntl.h     $(I)errno.h \
                  $(I)unistd.h   $(I)string.h   $(I)limits.h
$(ST)mkfifo.o   : $(I)sys/stat.h 
$(ST)mknod.o    : $(I)sys/stat.h $(I)fcntl.h    $(I)errno.h     $(I)unistd.h \
                  $(I)sys/types.h
$(ST)umask.o    : $(I)sys/stat.h $(I)sys/types.h
#   String handling routines
$(S)_memcmp.o   : $(I)string.h    $(I)stddef.h
$(S)_memcpy.o   : $(I)string.h    $(I)memory.h  $(I)stddef.h
$(S)_memset.o   : $(I)string.h    $(I)memory.h  $(I)stddef.h
$(S)_strcat.o   : $(I)string.h
$(S)_strcpy.o   : $(I)string.h  $(I)limits.h
$(S)_strlen.o   : $(I)string.h
$(S)memccpy.o   : $(I)string.h    $(I)sys/types.h
$(S)memchr.o    : $(I)string.h    $(I)stddef.h
$(S)stccpy.o    : $(I)string.h
$(S)stpblk.o    : $(I)string.h    $(I)ctype.h
$(S)stpcpy.o    : $(I)string.h
$(S)strbpl.o    : $(I)string.h
$(S)strchr.o    : $(I)string.h  $(I)limits.h
$(S)strcmp.o    : $(I)string.h
$(S)strcoll.o   : $(I)string.h
$(S)strcspn.o   : $(I)string.h  $(I)sys/types.h
$(S)strdup.o    : $(I)string.h  $(I)stdlib.h
$(S)strerror.o  : $(I)string.h
$(G)strfnd.o    : $(I)string.h    $(I)ctype.h
$(S)stricmp.o   : $(I)string.h  $(I)ctype.h
$(S)strins.o    : $(I)string.h
$(S)strlwr.o    : $(I)string.h  $(I)ctype.h
$(S)strmfe.o    : $(I)string.h
$(S)strmfn.o    : $(I)string.h
$(S)strmfp.o    : $(I)string.h
$(S)strncat.o   : $(I)string.h  $(I)sys/types.h
$(S)strncmp.o   : $(I)string.h  $(I)sys/types.h
$(S)strncpy.o   : $(I)string.h  $(I)sys/types.h
$(S)strnicmp.o  : $(I)string.h  $(I)ctype.h     $(I)sys/types.h
$(S)strpbrk.o   : $(I)string.h
$(S)strrchr.o   : $(I)string.h  $(I)limits.h
$(S)strpos.o    : $(I)string.h 
$(S)strrev.o    : $(I)string.h
$(S)strrpos.o   : $(I)string.h
$(S)strrstrip.o : $(I)string.h
$(S)strspn.o    : $(I)string.h  $(I)sys/types.h
$(S)strstr.o    : $(I)string.h
$(S)strstrip.o  : $(I)string.h
$(S)strtok.o    : $(I)string.h
$(S)strupr.o    : $(I)string.h    $(I)ctype.h
$(S)strxfrm.o   : $(I)string.h
$(S)syserr.o    :
#   stdlib routines
$(STD)_abort.o  :   $(I)stdlib.h    $(I)signal.h
$(STD)_calloc.o :   $(I)stdlib.h    $(I)string.h    $(I)assert.h
$(STD)_putenv.o :   $(I)stdlib.h    $(I)string.h    $(I)unistd.h  $(I)qdos.h
$(STD)_qsort.o  :   $(I)stdlib.h    $(I)string.h
$(STD)_realloc.o:   $(I)stdlib.h    $(I)string.h 
$(STD)_strtod.o :   $(I)stdlib.h    $(I)ctype.h     $(I)errno.h \
                    $(I)math.h      $(I)stddef.h
$(STD)_strtoul.o:   $(I)stdlib.h    $(I)ctype.h   $(I)errno.h     $(I)limits.h
$(STD)abs.o     :   $(I)stdlib.h
$(STD)atof.o    :   $(I)stdlib.h
$(STD)atoi.o    :   $(I)stdlib.h
$(STD)atol.o    :   $(I)stdlib.h
$(STD)bsearch.o :   $(I)stdlib.h
$(STD)div.o     :   $(I)stdlib.h
$(STD)free.o    :   $(I)stdlib.h    $(I)qdos.h      $(I)assert.h
$(STD)getenv.o  :   $(I)stdlib.h    $(I)string.h    $(I)unistd.h
$(STD)getopt.o  :   $(I)stdlib.h    $(I)stdio.h     $(I)stddef.h    $(I)string.h
$(STD)getpass.o :   $(I)stdlib.h    $(I)string.h    $(I)limits.h \
                    $(I)errno.h     $(I)qdos.h
$(STD)isatty.o  :   $(I)stdlib.h    $(I)qdos.h      $(I)fcntl.h
$(STD)itoa.o    :   $(I)stdlib.h    $(I)qdos.h
$(STD)labs.o    :   $(I)stdlib.h
$(STD)ldiv.o    :   $(I)stdlib.h
$(STD)malloc.o  :   $(I)stdlib.h    $(I)assert.h    $(I)unistd.h    $(I)qdos.h
$(STD)mktemp.o  :   $(I)stdlib.h    $(I)string.h    $(I)qdos.h
$(STD)rand.o    :   $(I)stdlib.h
$(STD)strtod_aux.o: 
$(STD)strtol.o  :   $(I)stdlib.h    $(I)ctype.h
$(STD)system.o  :   $(I)stdlib.h    $(I)qdos.h      $(I)errno.h\
                    $(I)stdio.h     $(I)string.h    $(I)unistd.h
$(STD)ttyname.o :   $(I)stdlib.h    $(I)fcntl.h
$(STD)wcstombs.o:   $(I)stdlib.h    $(I)string.h
$(STD)mbstowcs.o:   $(I)stdlib.h    $(I)string.h
$(STD)mblen.o   :   $(I)stdlib.h
$(STD)wctomb.o  :   $(I)stdlib.h
$(STD)mbtowc.o  :   $(I)stdlib.h
#   Time routines
$(T)_timeconst.o:   $(I)time.h
$(T)_timetext.o :   $(I)time.h
$(T)_asctime.o  :   $(I)time.h      $(I)stdio.h
$(T)_time.o     :   $(I)time.h      $(I)qdos.h
$(T)clock.o     :   $(I)time.h
$(T)ctime.o     :   $(I)time.h
$(T)difftime.o  :   $(I)time.h
$(T)gmtime.o    :   $(I)time.h
$(T)jdate.o     :   $(I)time.h
$(T)localtime.o :   $(I)time.h
$(T)mktime.o    :   $(I)time.h      $(I)ctype.h     $(I)limits.h    \
                    $(I)stdlib.h    $(I)string.h
$(T)strftime.o  :   $(I)time.h      $(I)string.h    $(I)stdio.h
$(T)times.o     :   $(I)sys/times.h
$(T)utime.o     :   $(I)utime.h     $(I)qdos.h      $(I)fcntl.h     $(I)errno.h \
                    $(I)time.h      $(I)unistd.h
#   termios.h routines
$(TM)cfgetisp.o :   $(I)termios.h
$(TM)cfgetosp.o :   $(I)termios.h
$(TM)cfsetisp.o :   $(I)termios.h
$(TM)cfsetosp.o :   $(I)termios.h
#   unistd.h routines
$(USTD)_cd.o    :   $(I)qdos.h      $(I)string.h    $(I)errno.h  \
                    $(I)stdlib.h    $(I)libgen.h
$(USTD)_chdir.o :   $(I)unistd.h    $(I)qdos.h
$(USTD)_close.o :   $(I)unistd.h    $(I)qdos.h      $(I)fcntl.h     $(I)errno.h
$(USTD)_dup2.o  :   $(I)unistd.h    $(I)qdos.h      $(I)fcntl.h     $(I)errno.h
$(USTD)_exit.o  :   $(I)unistd.h    $(I)qdos.h      $(I)string.h
$(USTD)_forkexec.o: $(I)unistd.h    $(I)qdos.h      $(I)fcntl.h \
                    $(I)string.h    $(I)errno.h
$(USTD)_fsync.o :   $(I)unistd.h    $(I)qdos.h      $(I)fcntl.h     $(I)errno.h
$(USTD)_read.o  :   $(I)unistd.h    $(I)qdos.h      $(I)fcntl.h     \
                    $(I)errno.h     $(I)stdlib.h \
                    $(I)signal.h    $(I)sys/signal.h
$(USTD)_unlink.o:   $(I)unistd.h    $(I)qdos.h      $(I)errno.h
$(USTD)_write.o :   $(I)unistd.h    $(I)qdos.h      $(I)fcntl.h \
                    $(I)errno.h     $(I)signal.h    $(I)sys/signal.h
$(USTD)access.o :   $(I)unistd.h    $(I)errno.h     $(I)sys/stat.h
$(USTD)chown.o  :   $(I)unistd.h    $(I)sys/stat.h
$(USTD)dup.o    :   $(I)unistd.h    $(I)qdos.h      $(I)fcntl.h     $(I)errno.h
$(USTD)execl.o  :   $(I)unistd.h    $(I)qdos.h
$(USTD)execlp.o :   $(I)unistd.h    $(I)qdos.h
$(USTD)execv.o  :   $(I)unistd.h    $(I)qdos.h
$(USTD)execvp.o :   $(I)unistd.h    $(I)qdos.h
$(USTD)forkl.o  :   $(I)unistd.h    $(I)qdos.h
$(USTD)forklp.o :   $(I)unistd.h    $(I)qdos.h
$(USTD)forkv.o  :   $(I)unistd.h    $(I)qdos.h
$(USTD)forkvp.o :   $(I)unistd.h    $(I)qdos.h
$(USTD)fpathconf.o: $(I)unistd.h    $(I)errno.h
$(USTD)fsync.o :    $(I)unistd.h
$(USTD)ftruncate.o: $(I)unistd.h    $(I)qdos.h      $(I)fcntl.h     $(I)errno.h
$(USTD)getcwd.o :   $(I)unistd.h    $(I)qdos.h
$(USTD)getlogin.o : $(I)unistd.h
$(USTD)getpid.o  :
$(USTD)getuid.o  :
$(USTD)link.o   :   $(I)unistd.h    $(I)errno.h     $(I)sys/stat.h
$(USTD)lsbrk.o  :   $(I)unistd.h    $(I)qdos.h      $(I)errno.h \
                    $(I)assert.h    $(I)signal.h    $(I)sys/signal.h
$(USTD)lseek.o  :   $(I)unistd.h    $(I)qdos.h      $(I)fcntl.h     $(I)errno.h
$(USTD)openpipe.o:  $(I)unistd.h    $(I)qdos.h      $(I)fcntl.h     $(I)errno.h
$(USTD)pathconf.o : $(I)unistd.h    $(I)errno.h
$(USTD)rmdir.o  :   $(I)unistd.h    $(I)errno.h     $(I)sys/stat.h  $(I)sys/types.h
$(USTD)sbrk.o   :   $(I)unistd.h
$(USTD)sleep.o  :   $(I)unistd.h    $(I)qdos.h      $(I)time.h 
$(USTD)stime.o  :   $(I)unistd.h    $(I)qdos.h
$(USTD)sync.o   :   $(I)unistd.h
$(USTD)truncate.o:  $(I)unistd.h    $(I)fcntl.h
#   QDOS Miscellaneous
$(Q)_dtoqlfp.o  :   $(I)float.h
$(Q)_fqstat.o   :   $(I)qdos.h
$(Q)_getcd.o    :   $(I)qdos.h      $(I)stdlib.h    $(I)string.h    $(I)errno.h
$(Q)_mkname.o   :   $(I)qdos.h      $(I)unistd.h    $(I)string.h    $(I)errno.h
$(Q)_stackerr.o :   $(I)qdos.h      $(I)string.h    $(I)stdio.h $(I)stdlib.h
$(Q)argfree.o   :   $(I)qdos.h      $(I)stdlib.h
$(Q)argpack.o   :   $(I)qdos.h      $(I)libgen.h    $(I)string.h    $(I)stdlib.h
$(Q)argunpack.o :   $(I)qdos.h      $(I)ctype.h     $(I)libgen.h \
                    $(I)stdlib.h    $(I)string.h
$(Q)beep.o      :   $(I)qdos.h
$(Q)chchown.o   :
$(Q)chddir.o    :   $(I)qdos.h
$(Q)chpdir.o    :   $(I)qdos.h
$(Q)conget.o    :   $(I)qdos.h
$(Q)fgetchid.o  :   $(I)qdos.h      $(I)stdio.h
$(Q)fnmatch.o   :   $(I)qdos.h      $(I)libgen.h    $(I)ctype.h     $(I)string.h
$(Q)fqstat.o    :   $(I)qdos.h      $(I)fcntl.h 
$(Q)fusechid.o  :   $(I)qdos.h      $(I)stdio.h
$(Q)getcdd.o    :   $(I)qdos.h
$(Q)getchid.o   :   $(I)qdos.h      $(I)fcntl.h
$(Q)getchown.o  :
$(Q)getcname.o  :   $(I)qdos.h      $(I)channels.h  $(I)string.h
$(Q)getcpd.o    :   $(I)qdos.h
$(Q)isdevice.o  :   $(I)qdos.h 
$(Q)isdirchid.o :   $(I)qdos.h      $(I)channels.h
$(Q)isdirdev.o  :   $(I)qdos.h      $(I)string.h
$(Q)isnoclose.o :   $(I)qdos.h      $(I)fcntl.h
$(Q)itoqlfp.o   :
$(Q)keyrow.o    :   $(I)qdos.h
$(Q)ltoqlfp.o   :
$(Q)openqdir.o  :   $(I)qdos.h      $(I)errno.h
$(Q)poserr.o    :   $(I)qdos.h      $(I)stdio.h     $(I)errno.h
$(Q)qdirread.o  :   $(I)qdos.h      $(I)stdlib.h    $(I)string.h    $(I)errno.h
$(Q)qdos1.o     :
$(Q)qdos2.o     :
$(Q)qdos3.o     :
$(Q)qdirsort.o  :   $(I)qdos.h      $(I)ctype.h     $(I)string.h
$(Q)qforkl.o    :   $(I)qdos.h
$(Q)qforklp.o   :   $(I)qdos.h
$(Q)qforkv.o    :   $(I)qdos.h
$(Q)qforkvp.o   :   $(I)qdos.h
$(Q)qinstrn.o   :
$(Q)qlfptod.o   :   $(I)float.h
$(Q)qlfptof.o   :   $(I)qdos.h      $(I)float.h
$(Q)qlmknam.o   :   $(I)string.h    $(I)libgen.h    $(I)errno.h
$(Q)qlstrtoc.o  :
$(Q)qstrcat.o   :   $(I)qdos.h      $(I)string.h
$(Q)qstrchr.o   :   $(I)qdos.h      $(I)string.h
$(Q)qstrcmp.o   :   $(I)qdos.h
$(Q)qstrcpy.o   :   $(I)qdos.h      $(I)string.h
$(Q)qstricmp.o  :   $(I)qdos.h
$(Q)qstrlen.o   :   $(I)qdos.h      $(I)string.h
$(Q)qstrncat.o  :   $(I)qdos.h      $(I)string.h
$(Q)qstrncmp.o  :   $(I)qdos.h
$(Q)qstrncpy.o  :   $(I)qdos.h      $(I)string.h
$(Q)qstrnicmp.o :   $(I)qdos.h
$(Q)qstat.o     :   $(I)qdos.h      $(I)fcntl.h     $(I)unistd.h
$(Q)readqdir.o  :   $(I)qdos.h      $(I)string.h    $(I)errno.h
$(Q)stackchk.o  :   $(I)qdos.h
$(Q)stackrep.o  :   $(I)qdos.h
$(Q)sound.o     :   $(I)qdos.h      $(I)std.h
$(Q)usechid.o   :   $(I)qdos.h      $(I)fcntl.h
$(Q)waitfor.o   :
$(Q)wtoqlfp.o   :

$(QP)readmove.o :   $(I)qdos.h      $(I)qptr.h      $(I)channels.h
                                                         
