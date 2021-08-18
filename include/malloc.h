/*
 * (c) Copyright 1990, 1991 Conor P. Cahill (uunet!virtech!cpcahil).  
 * You may copy, distribute, and use this software as long as this
 * copyright statement is not removed.
 */
/*
 * $Id: malloc.h,v 1.7 92/04/07 08:01:55 minix Exp $
 */

#include <sys/types.h>

#ifndef _DEBUG_MALLOC_INC
#define _DEBUG_MALLOC_INC 1

/*
 * The following lines will probably need to be changed depending
 * upon the OS to which this library is ported.  Typically, older BSD
 * systems will need:
 *
 *		typedef char	DATATYPE;
 *		typedef int	SIZETYPE;
 *		typedef int	VOIDTYPE;
 *
 * System V style systems with compilers that understand void will usually
 * use:
 *
 *		typedef char	DATATYPE;
 *		typedef int	SIZETYPE;
 *		typedef void	VOIDTYPE;
 *
 * ANSI-C and/or c++ compilers will usually use:
 *
 *		typedef void	DATATYPE;
 *		typedef int	SIZETYPE;
 *		typedef void	VOIDTYPE;
 *
 * (Note: while the library can be linked with c++ modules, it itself 
 *  cannot be compiled with c++ - yet.  This header file has been modified
 *  so that it can be included by C++ modules that use malloc)
 * 
 * And some other systems will require sizetype to be one of the following:
 * 
 * 		typedef unsigned int	SIZETYPE;
 * or
 *
 *		typedef size_t		SIZETYPE;
 *
 * Because I am lazy, I have setup #ifdefs for the few systems that I normally
 * test the library on (so if you are on one of these systems, you are lucky
 * and don't have to worry about changing it - hopefully)
 * 
 * NOTE: for those of you who are wondering why I dont just use a command line
 * option on the compiler (set via the makefile) to determint these settings:
 * the reason is that this file must be able to be included in existing 
 * software modules with no changes to the code and with as little changes
 * as possible to the command line.  It is easier to edit this file once, when
 * you install the system, than have to specify three -Ds on each compile 
 * when it is used.
 *
 * NOTE2: if void is not supported, then you also need to disable or remove
 * the VOIDCAST #define
 */

#if __hpux	/* HP/UX (at least 8.0 and above) */
		typedef	void	DATATYPE;
		typedef size_t	SIZETYPE;
		typedef void	VOIDTYPE;
#else
#if i386
#if __STDC__ || __cplusplus
		typedef void		DATATYPE;
		typedef unsigned int	SIZETYPE;
		typedef void		VOIDTYPE;
#else
		typedef char		DATATYPE;
		typedef int		SIZETYPE;
		typedef void		VOIDTYPE;
#endif /* __STDC__ */
#else  /* i386     */
#if _IBMR2
		typedef void		DATATYPE;
		typedef unsigned long	SIZETYPE;
		typedef void		VOIDTYPE;
#else  /* _IBMR2   */
/*
 * you need to define other entries here
 */
		typedef char	DATATYPE;
		typedef size_t	SIZETYPE;
		typedef void	VOIDTYPE;
#endif /* _IBMR2   */
#endif /* i386     */
#endif /* __hpux   */

/*
 * Comment out the following line if your compiler doesn't support the VOID
 * data type.
 */
#define VOIDCAST (void)

/*
 * since we redefine much of the stuff that is #defined in string.h and 
 * memory.h, we should do what we can to make sure that they don't get 
 * included after us.  This is typically accomplished by a special symbol
 * (similar to _DEBUG_MALLOC_INC defined above) that is #defined when the
 * file is included.  Since we don't want the file to be included we will
 * #define the symbol ourselves.  These will typically have to change from
 * one system to another.  I have put in several standard mechanisms used to
 * support this mechanism, so hopefully you won't have to modify this file.
 */
#ifndef _H_STRING
#define _H_STRING		1
#endif 
#ifndef __STRING_H
#define __STRING_H		1
#endif 
#ifndef _STRING_H_
#define _STRING_H_		1
#endif 
#ifndef _STRING_INCLUDED
#define _STRING_INCLUDED	1
#endif
#ifndef _H_MEMORY
#define _H_MEMORY		1
#endif
#ifndef __MEMORY_H
#define __MEMORY_H		1
#endif
#ifndef _MEMORY_H_
#define _MEMORY_H_		1
#endif
#ifndef _MEMORY_INCLUDED
#define _MEMORY_INCLUDED	1
#endif

/*
 * Malloc warning/fatal error handler defines...
 */
#define M_HANDLE_DUMP	0x80  /* 128 */
#define M_HANDLE_IGNORE	0
#define M_HANDLE_ABORT	1
#define M_HANDLE_EXIT	2
#define M_HANDLE_CORE	3
	
/*
 * Mallopt commands and defaults
 *
 * the first four settings are ignored by the debugging mallopt, but are
 * here to maintain compatibility with the system malloc.h.
 */
#define M_MXFAST	1		/* ignored by mallopt		*/
#define M_NLBLKS	2		/* ignored by mallopt		*/
#define M_GRAIN		3		/* ignored by mallopt		*/
#define M_KEEP		4		/* ignored by mallopt		*/
#define MALLOC_WARN	100		/* set malloc warning handling	*/
#define MALLOC_FATAL	101		/* set malloc fatal handling	*/
#define MALLOC_ERRFILE	102		/* specify malloc error file	*/
#define MALLOC_CKCHAIN	103		/* turn on chain checking	*/
#define MALLOC_FILLAREA	104		/* turn off area filling	*/
#define MALLOC_LOWFRAG	105		/* use best fit allocation mech	*/

union malloptarg
{
	int	  i;
	char	* str;
};

/*
 * Malloc warning/fatal error codes
 */

#define M_CODE_CHAIN_BROKE	1	/* malloc chain is broken	*/
#define M_CODE_NO_END		2	/* chain end != endptr		*/
#define M_CODE_BAD_PTR		3	/* pointer not in malloc area	*/
#define M_CODE_BAD_MAGIC	4	/* bad magic number in header	*/
#define M_CODE_BAD_CONNECT	5	/* chain poingers corrupt	*/
#define M_CODE_OVERRUN		6	/* data overrun in malloc seg	*/
#define M_CODE_REUSE		7	/* reuse of freed area		*/
#define M_CODE_NOT_INUSE	8	/* pointer is not in use	*/
#define M_CODE_NOMORE_MEM	9	/* no more memory available	*/
#define M_CODE_OUTOF_BOUNDS	10	/* gone beyound bounds 		*/
#define M_CODE_FREELIST_BAD	11	/* inuse segment on freelist	*/

#ifndef __stdcargs
#if  __STDC__ || __cplusplus
#define __stdcargs(a) a
#else
#define __stdcargs(a) ()
#endif
#endif

#if __cplusplus
extern "C" {
#endif

VOIDTYPE	  malloc_dump __stdcargs((int));
VOIDTYPE	  malloc_list __stdcargs((int,unsigned long, unsigned long));
int		  mallopt __stdcargs((int, union malloptarg));
DATATYPE	* debug_calloc __stdcargs((const char *,int,SIZETYPE,SIZETYPE));
VOIDTYPE	  debug_cfree __stdcargs((const char *, int, DATATYPE *));
VOIDTYPE	  debug_free __stdcargs((const char *, int, DATATYPE *));
DATATYPE	* debug_malloc __stdcargs((const char *,int, SIZETYPE));
DATATYPE	* debug_realloc __stdcargs((const char *,int,
					    DATATYPE *,SIZETYPE));
unsigned long	  DBmalloc_size __stdcargs((const char *,int,unsigned long *));
int		  DBmalloc_chain_check __stdcargs((const char *,int,int));

/*
 * memory(3) related prototypes
 */
DATATYPE 	* DBmemccpy __stdcargs((const char *file, int line,
					DATATYPE *ptr1, const DATATYPE *ptr2,
					int ch, SIZETYPE len));
DATATYPE 	* DBmemchr __stdcargs((const char *file, int line,
					const DATATYPE *ptr1, int ch,
					SIZETYPE len));
DATATYPE	* DBmemmove __stdcargs((const char *file, int line,
					DATATYPE *ptr1, const DATATYPE *ptr2,
					SIZETYPE len));
DATATYPE	* DBmemcpy __stdcargs((const char *file, int line,
					DATATYPE *ptr1, const DATATYPE *ptr2,
					SIZETYPE len));
int		  DBmemcmp __stdcargs((const char *file, int line,
					const DATATYPE *ptr1,
					const DATATYPE *ptr2, SIZETYPE len));
DATATYPE	* DBmemset __stdcargs((const char *file, int line,
					DATATYPE *ptr1, int ch, SIZETYPE len));
DATATYPE	* DBbcopy __stdcargs((const char *file, int line,
					const DATATYPE *ptr2, DATATYPE *ptr1,
					SIZETYPE len));
DATATYPE 	* DBbzero __stdcargs((const char *file, int line,
					DATATYPE *ptr1, SIZETYPE len));
int		  DBbcmp __stdcargs((const char *file, int line,
					const DATATYPE *ptr2,
					const DATATYPE *ptr1, SIZETYPE len));

/*
 * string(3) related prototypes
 */
char		* DBstrcat __stdcargs((const char *file,int line, char *str1,
					const char *str2));
char		* DBstrdup __stdcargs((const char *file, int line,
					const char *str1));
char		* DBstrncat __stdcargs((const char *file, int line, char *str1,
					const char *str2, SIZETYPE len));
int		  DBstrcmp __stdcargs((const char *file, int line,
					const char *str1, const char *str2));
int		  DBstrncmp __stdcargs((const char *file, int line,
					const char *str1, const char *str2,
					SIZETYPE len));
char		* DBstrcpy __stdcargs((const char *file, int line, char *str1,
					const char *str2));
char		* DBstrncpy __stdcargs((const char *file, int line, char *str1,
					const char *str2, SIZETYPE len));
SIZETYPE	  DBstrlen __stdcargs((const char *file, int line,
					const char *str1));
char		* DBstrchr __stdcargs((const char *file, int line,
					const char *str1, int c));
char		* DBstrrchr __stdcargs((const char *file, int line,
					const char *str1, int c));
char		* DBindex __stdcargs((const char *file, int line,
					const char *str1, int c));
char		* DBrindex __stdcargs((const char *file, int line,
					const char *str1, int c));
char		* DBstrpbrk __stdcargs((const char *file, int line,
					const char *str1, const char *str2));
SIZETYPE	  DBstrspn __stdcargs((const char *file, int line,
					const char *str1, const char *str2));
SIZETYPE	  DBstrcspn __stdcargs((const char *file, int line,
					const char *str1, const char *str2));
char		* DBstrstr __stdcargs((const char *file, int line,
					const char *str1, const char *str2));
char		* DBstrtok __stdcargs((const char *file, int line, char *str1,
					const char *str2));

#if __cplusplus
};
#endif

/*
 * Macro which enables logging of the file and line number for each allocation
 * so that it is easier to determine where the offending malloc comes from.
 *
 * NOTE that only code re-compiled with this include file will have this 
 * additional info.  Calls from libraries that have not been recompiled will
 * just have a null string for this info.
 */
#ifndef IN_MALLOC_CODE

/*
 * allocation functions
 */
#define malloc(len)		debug_malloc( __FILE__,__LINE__, (len))
#define realloc(ptr,len)	debug_realloc(__FILE__,__LINE__, (ptr), (len))
#define calloc(numelem,size)	debug_calloc(__FILE__,__LINE__,(numelem),(size))
#define cfree(ptr)		debug_cfree(__FILE__,__LINE__,(ptr))
#define free(ptr)		debug_free(__FILE__,__LINE__,(ptr))
#define malloc_size(histptr)	DBmalloc_size(__FILE__,__LINE__,(histptr))
#define malloc_chain_check(todo) DBmalloc_chain_check(__FILE__,__LINE__,(todo))

/*
 * memory(3) related functions
 */
#define memccpy(ptr1,ptr2,ch,len) DBmemccpy(__FILE__,__LINE__,ptr1,ptr2,ch,len)
#define memchr(ptr1,ch,len)	  DBmemchr(__FILE__,__LINE__,ptr1,ch,len)
#define memmove(ptr1,ptr2,len)    DBmemmove(__FILE__,__LINE__,ptr1, ptr2, len)
#define memcpy(ptr1,ptr2,len)     DBmemcpy(__FILE__, __LINE__, ptr1, ptr2, len)
#define memcmp(ptr1,ptr2,len)     DBmemcmp(__FILE__,__LINE__,ptr1, ptr2, len)
#define memset(ptr1,ch,len)       DBmemset(__FILE__,__LINE__,ptr1, ch, len)
#define bcopy(ptr2,ptr1,len)      DBbcopy(__FILE__,__LINE__,ptr2,ptr1,len)
#define bzero(ptr1,len)           DBbzero(__FILE__,__LINE__,ptr1,len)
#define bcmp(ptr2,ptr1,len)       DBbcmp(__FILE__, __LINE__, ptr2, ptr1, len)

/*
 * string(3) related functions
 */
#define index(str1,c)		  DBindex(__FILE__, __LINE__, str1, c)
#define rindex(str1,c)		  DBrindex(__FILE__, __LINE__, str1, c)
#define strcat(str1,str2)	  DBstrcat(__FILE__,__LINE__,str1,str2)
#define strchr(str1,c)		  DBstrchr(__FILE__, __LINE__, str1,c)
#define strcmp(str1,str2)	  DBstrcmp(__FILE__, __LINE__, str1, str2)
#define strcpy(str1,str2)	  DBstrcpy(__FILE__, __LINE__, str1, str2)
#define strcspn(str1,str2)	  DBstrcspn(__FILE__, __LINE__, str1,str2)
#define strdup(str1)		  DBstrdup(__FILE__, __LINE__, str1)
#define strlen(str1)		  DBstrlen(__FILE__, __LINE__, str1)
#define strncat(str1,str2,len)	  DBstrncat(__FILE__, __LINE__, str1,str2,len)
#define strncpy(str1,str2,len)	  DBstrncpy(__FILE__,__LINE__,str1,str2,len)
#define strncmp(str1,str2,len)	  DBstrncmp(__FILE__, __LINE__, str1,str2,len)
#define strpbrk(str1,str2)	  DBstrpbrk(__FILE__, __LINE__, str1,str2)
#define strrchr(str1,c)		  DBstrrchr(__FILE__,__LINE__,str1,c)
#define strspn(str1,str2)	  DBstrspn(__FILE__, __LINE__, str1,str2)
#define strstr(str1,str2)	  DBstrstr(__FILE__, __LINE__, str1, str2)
#define strtok(str1,str2)	  DBstrtok(__FILE__, __LINE__, str1, str2)

#endif

#endif /* _DEBUG_MALLOC_INC */

/*
 * $Log:	malloc.h,v $
 * Revision 1.7  92/04/07  08:01:55  minix
 * Usenet patchlevel 7
 * 
 * Revision 1.20  1992/01/28  21:42:25  cpcahil
 * changes for the ibmRS6000
 *
 * Revision 1.19  1992/01/28  18:05:37  cpcahil
 * misc fixes for patch 7
 *
 * Revision 1.18  1992/01/22  16:21:35  cpcahil
 * added code to prevent inclusions of string.h and memory.h after malloc.h
 * was included.
 *
 * Revision 1.17  1992/01/10  17:26:46  cpcahil
 * fixed prototypes use of void.
 *
 * Revision 1.16  1992/01/10  16:53:39  cpcahil
 * added more info on sizetype and datatype. added support for overriding
 * use of void type.
 *
 * Revision 1.15  1992/01/09  17:19:11  cpcahil
 * put the close brace in the correct position.
 *
 * Revision 1.14  1992/01/09  17:12:36  cpcahil
 * added code to support inclusion in C++ modules
 *
 * Revision 1.13  1991/12/31  21:31:26  cpcahil
 * changes for patch 6.  See CHANGES file for more info
 *
 * Revision 1.12  1991/12/26  22:31:29  cpcahil
 * added check to make sure file is not included twice.
 *
 * Revision 1.11  1991/12/06  17:58:46  cpcahil
 * added cfree() for compatibility with some wierd systems
 *
 * Revision 1.10  91/12/06  08:54:18  cpcahil
 * cleanup of __STDC__ usage and addition of CHANGES file
 * 
 * Revision 1.9  91/12/04  09:23:40  cpcahil
 * several performance enhancements including addition of free list
 * 
 * Revision 1.8  91/12/02  19:10:11  cpcahil
 * changes for patch release 5
 * 
 * Revision 1.7  91/11/25  14:42:00  cpcahil
 * Final changes in preparation for patch 4 release
 * 
 * Revision 1.6  91/11/24  00:49:28  cpcahil
 * first cut at patch 4
 * 
 * Revision 1.5  91/11/20  11:54:10  cpcahil
 * interim checkin
 * 
 * Revision 1.4  90/08/29  22:23:38  cpcahil
 * fixed mallopt to use a union as an argument.
 * 
 * Revision 1.3  90/05/11  11:04:10  cpcahil
 * took out some extraneous lines
 * 
 * Revision 1.2  90/05/11  00:13:09  cpcahil
 * added copyright statment
 * 
 * Revision 1.1  90/02/23  07:09:03  cpcahil
 * Initial revision
 * 
 */
