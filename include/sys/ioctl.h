
#ifndef SYS_IOCTL_H
#define SYS_IOCTL_H
#define IOCPARM_MASK 0x1fff
#define IOCPARM_LEN(x) (((x) >> 16) & IOCPARM_MASK)
#define IOCBASECMD(x) ((x) & ~IOCPARM_MASK)
#define IOCGROUP(x) (((x) >> 8) & 0xff)
#define IOCPARM_MAX 4096
#define IOC_VOID 0x20000000
#define IOC_OUT 0x40000000
#define IOC_IN 0x80000000
#define IOC_INOUT (IOC_IN|IOC_OUT)
#define IOC_DIRMASK 0xe0000000
#define _IOC(inout,group,num,len) \
(inout | ((len & IOCPARM_MASK) << 16) | ((group) << 8) | (num))
#define _IO(g,n) _IOC(IOC_VOID,(g),(n),0)
#define _IOR(g,n,t) _IOC(IOC_OUT,(g),(n),sizeof(t))
#define _IOW(g,n,t) _IOC(IOC_IN,(g),(n),sizeof(t))
#define _IOWR(g,n,t) _IOC(IOC_INOUT,(g),(n),sizeof(t))
#define SIOCATMARK _IOR('s',7,long)
#define SIOCSPGRP _IOW('s',8,long)
#define SIOCGPGRP _IOR('s',9,long)
#define SIOCADDRT _IOW('r',10,struct ortentry)
#define SIOCDELRT _IOW('r',11,struct ortentry)
#define SIOCSIFADDR _IOW('I',12,struct ifreq)
#define OSIOCGIFADDR _IOWR('I',13,struct ifreq)
#define SIOCGIFADDR _IOWR('I',33,struct ifreq)
#define SIOCSIFDSTADDR _IOW('I',14,struct ifreq)
#define OSIOCGIFDSTADDR _IOWR('I',15,struct ifreq)
#define SIOCGIFDSTADDR _IOWR('I',34,struct ifreq)
#define SIOCSIFFLAGS _IOW('I',16,struct ifreq)
#define SIOCGIFFLAGS _IOWR('I',17,struct ifreq)
#define OSIOCGIFBRDADDR _IOWR('I',18,struct ifreq)
#define SIOCGIFBRDADDR _IOWR('I',35,struct ifreq)
#define SIOCSIFBRDADDR _IOW('I',19,struct ifreq)
#define OSIOCGIFCONF _IOWR('I',20,struct ifconf)
#define SIOCGIFCONF _IOWR('I',36,struct ifconf)
#define OSIOCGIFNETMASK _IOWR('I',21,struct ifreq)
#define SIOCGIFNETMASK _IOWR('I',37,struct ifreq)
#define SIOCSIFNETMASK _IOW('I',22,struct ifreq)
#define SIOCGIFMETRIC _IOWR('I',23,struct ifreq)
#define SIOCSIFMETRIC _IOW('I',24,struct ifreq)
#define SIOCDIFADDR _IOW('I',25,struct ifreq)
#define SIOCAIFADDR _IOW('I',26,struct ifaliasreq)
#define SIOCSARP _IOW('I',30,struct arpreq)
#define OSIOCGARP _IOWR('I',31,struct arpreq)
#define SIOCGARP _IOWR('I',38,struct arpreq)
#define SIOCDARP _IOW('I',32,struct arpreq)
#define SIOCSSANATAGS _IOW('I',64,struct wiretype_parameters)
#define SIOCGSANATAGS _IOR('I',65,struct wiretype_parameters)
#define SIOCGARPT _IOWR('I',66,struct arptabreq)
#endif
