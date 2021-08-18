
#ifndef IN_H
#define IN_H
#ifndef ntohl
#define ntohl(x) (x)
#define ntohs(x) (x)
#define htonl(x) (x)
#define htons(x) (x)
#define NTOHL(x) (x)
#define NTOHS(x) (x)
#define HTONL(x) (x)
#define HTONS(x) (x)
#endif
#define IPPROTO_IP 0
#define IPPROTO_ICMP 1
#define IPPROTO_GGP 3
#define IPPROTO_TCP 6
#define IPPROTO_EGP 8
#define IPPROTO_PUP 12
#define IPPROTO_UDP 17
#define IPPROTO_IDP 22
#define IPPROTO_TP 29
#define IPPROTO_EON 80
#define IPPROTO_RAW 255
#define IPPROTO_MAX 256
#define IPPORT_RESERVED 1024
#define IPPORT_USERRESERVED 5000
struct in_addr {
u_long s_addr;
};
#define IN_CLASSA(i) (((long)(i) & 0x80000000) == 0)
#define IN_CLASSA_NET 0xff000000
#define IN_CLASSA_NSHIFT 24
#define IN_CLASSA_HOST 0x00ffffff
#define IN_CLASSA_MAX 128
#define IN_CLASSB(i) (((long)(i) & 0xc0000000) == 0x80000000)
#define IN_CLASSB_NET 0xffff0000
#define IN_CLASSB_NSHIFT 16
#define IN_CLASSB_HOST 0x0000ffff
#define IN_CLASSB_MAX 65536
#define IN_CLASSC(i) (((long)(i) & 0xe0000000) == 0xc0000000)
#define IN_CLASSC_NET 0xffffff00
#define IN_CLASSC_NSHIFT 8
#define IN_CLASSC_HOST 0x000000ff
#define IN_CLASSD(i) (((long)(i) & 0xf0000000) == 0xe0000000)
#define IN_MULTICAST(i) IN_CLASSD(i)
#define IN_EXPERIMENTAL(i) (((long)(i) & 0xe0000000) == 0xe0000000)
#define IN_BADCLASS(i) (((long)(i) & 0xf0000000) == 0xf0000000)
#define INADDR_ANY (u_long)0x00000000
#define INADDR_BROADCAST (u_long)0xffffffff
#if !defined(KERNEL) || defined(AMITCP)
#define INADDR_NONE 0xffffffff
#endif
#define IN_LOOPBACKNET 127
struct sockaddr_in {
u_short sin_family;
u_short sin_port;
struct in_addr sin_addr;
char sin_zero[8];
};
struct ip_opts {
struct in_addr ip_dst;
char ip_opts[40];
};
#define IP_OPTIONS 1
#define IP_HDRINCL 2
#define IP_TOS 3
#define IP_TTL 4
#define IP_RECVOPTS 5
#define IP_RECVRETOPTS 6
#define IP_RECVDSTADDR 7
#define IP_RETOPTS 8
#endif
