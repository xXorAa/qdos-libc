
#ifndef _SYS_UN_H
#define _SYS_UN_H 1
#include <string.h>
#include <sockaddrcom.h>
struct sockaddr_un
{
__SOCKADDR_COMMON (sun_);
char sun_path[108];
};
#define SUN_LEN(ptr) ((size_t) (((struct sockaddr_un *) 0)->sun_path) \
+ strlen ((ptr)->sun_path))
#endif
