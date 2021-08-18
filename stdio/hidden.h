/*				h i d d e n . h
 *
 * (C) Copyright C E Chew
 *
 * Feel free to copy, use and distribute this software provided:
 *
 *	1. you do not pretend that you wrote it
 *	2. you leave this copyright notice intact.
 *
 * This file hides the system library names in the implementor's namespace.
 */

#ifndef	HIDDEN_H
#define HIDDEN_H

# ifdef		HIDDENLIBC
/*  define _exit	_exit*/
#   define chmod	_chmod
#   define close	_close
#   define dup		_dup
#   define dup2		_dup2
#   define geteuid	_geteuid
#   define getpid	_getpid
#   define getpwuid	_getpwuid
#   define getuid	_getuid
#   define isatty	_isatty
#   define link		_link
#   define lseek	_lseek
#   define open		_open
#   define read		_read
#   define stat		_stat
#   define umask	_umask
#   define unlink	_unlink
#   define write	_write

#   define sys_errlist	_sys_errlist
#   define sys_nerr	_sys_nerr
# endif
#endif
