#ifndef _SYS_SOCKET_H
#define	_SYS_SOCKET_H
/*
 *      socket.h header file
 *
 *  On QDOS the implementation of many routines is 'frigged'
 *  (at least currently).
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  14 Dec 96   DJW   - First version (based on version from KDW)
 */

/* socket types */
#define	SOCK_STREAM	1	/* stream (connection) socket */
#define	SOCK_DGRAM	2	/* datagram (connectionless) socket */
#define	SOCK_RAW	3	/* raw socket */
#define	SOCK_RDM	4	/* reliably-delivered message */
#define	SOCK_SEQPACKET	5	/* sequential packet socket */

/* supported address families */
#define	AF_UNSPEC	0
#define	AF_UNIX		1	/* Unix domain sockets */
#define	AF_INET		2	/* Internet IP Protocol */

struct sockaddr {
    unsigned short	sa_family;	/* address family, AF_xx */
    char		sa_data[14];	/* 14 bytes of protocol address */
};

/*
 * Function Prototypes.
 */
#ifdef __STDC__
#define _P_(params) params
#else
#define _P_(params)
#endif

int socket          _P_((int, int, int) );
int socketpair      _P_((int, int, int, int *) );
int bind            _P_((int, struct sockaddr *, int) );
int connect         _P_((int, struct sockaddr *, int) );
int listen          _P_((int, int) );
int accept          _P_((int, struct sockaddr *, int *) );
int getsockopt      _P_((int, int, int, const void *, int) );
int getsockname     _P_((int, struct sockaddr *, int *) );
int getpeername     _P_((int, struct sockaddr *, int *) );
int send            _P_((int, const void *, int, unsigned int) );
int recv            _P_((int, const void *, int, unsigned int) );
int sendto          _P_((int, const void *, int, unsigned int, const struct sockaddr *, int) );
int recvfrom        _P_((int, const void *, int, unsigned int, const struct sockaddr *, int *) );

#undef _P_

#endif /* _SYS_SOCKET_H */
