
#ifndef _SOCKADDRCOM_H
#define _SOCKADDRCOM_H 1
typedef unsigned short int sa_family_t;
#define __SOCKADDR_COMMON(sa_prefix) \
sa_family_t sa_prefix##family
#define __SOCKADDR_COMMON_SIZE (sizeof (unsigned short int))
#endif
