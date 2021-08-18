
#ifndef IP_H
#define IP_H
#define IPVERSION 4
struct ip {
#if 1
u_char ip_v:4;
u_char ip_hl:4;
#endif
u_char ip_tos;
short ip_len;
u_short ip_id;
short ip_off;
#define IP_DF 0x4000
#define IP_MF 0x2000
u_char ip_ttl;
u_char ip_p;
u_short ip_sum;
struct in_addr ip_src,ip_dst;
};
#define IP_MAXPACKET 65535
#define IPTOS_LOWDELAY 0x10
#define IPTOS_THROUGHPUT 0x08
#define IPTOS_RELIABILITY 0x04
#define IPTOS_PREC_NETCONTROL 0xe0
#define IPTOS_PREC_INTERNETCONTROL 0xc0
#define IPTOS_PREC_CRITIC_ECP 0xa0
#define IPTOS_PREC_FLASHOVERRIDE 0x80
#define IPTOS_PREC_FLASH 0x60
#define IPTOS_PREC_IMMEDIATE 0x40
#define IPTOS_PREC_PRIORITY 0x20
#define IPTOS_PREC_ROUTINE 0x10
#define IPOPT_COPIED(o) ((o)&0x80)
#define IPOPT_CLASS(o) ((o)&0x60)
#define IPOPT_NUMBER(o) ((o)&0x1f)
#define IPOPT_CONTROL 0x00
#define IPOPT_RESERVED1 0x20
#define IPOPT_DEBMEAS 0x40
#define IPOPT_RESERVED2 0x60
#define IPOPT_EOL 0
#define IPOPT_NOP 1
#define IPOPT_RR 7
#define IPOPT_TS 68
#define IPOPT_SECURITY 130
#define IPOPT_LSRR 131
#define IPOPT_SATID 136
#define IPOPT_SSRR 137
#define IPOPT_OPTVAL 0
#define IPOPT_OLEN 1
#define IPOPT_OFFSET 2
#define IPOPT_MINOFF 4
struct ip_timestamp {
u_char ipt_code;
u_char ipt_len;
u_char ipt_ptr;
#if 1
u_char ipt_oflw:4;
u_char ipt_flg:4;
#endif
union ipt_timestamp {
u_long ipt_time[1];
struct ipt_ta {
struct in_addr ipt_addr;
u_long ipt_time;
} ipt_ta[1];
} ipt_timestamp;
};
#define IPOPT_TS_TSONLY 0
#define IPOPT_TS_TSANDADDR 1
#define IPOPT_TS_PRESPEC 3
#define IPOPT_SECUR_UNCLASS 0x0000
#define IPOPT_SECUR_CONFID 0xf135
#define IPOPT_SECUR_EFTO 0x789a
#define IPOPT_SECUR_MMMM 0xbc4d
#define IPOPT_SECUR_RESTR 0xaf13
#define IPOPT_SECUR_SECRET 0xd788
#define IPOPT_SECUR_TOPSECRET 0x6bc5
#define MAXTTL 255
#define IPFRAGTTL 60
#define IPTTLDEC 1
#define IP_MSS 576
#endif
