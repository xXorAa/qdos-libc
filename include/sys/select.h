
#ifndef _SYS_SELECT_H_
#define _SYS_SELECT_H_
#include <string.h>
#ifndef FD_SETSIZE
#define FD_SETSIZE 64
#endif
typedef struct
{
int fd[FD_SETSIZE];
short sts[FD_SETSIZE];
} fd_set;
void _fd_set(int,fd_set *);
void _fd_clr(int,fd_set *);
int _fd_isset(int,fd_set *);
#define FD_ZERO(set) ((void) memset((void *) (set),0,sizeof(fd_set)))
#define FD_SET(d,set) (_fd_set(d,set))
#define FD_CLR(d,set) (_fd_clr(d,set))
#define FD_ISSET(d,set) (_fd_isset(d,set))
int select (int n,fd_set *,fd_set *,fd_set *,struct timeval *);
#endif
