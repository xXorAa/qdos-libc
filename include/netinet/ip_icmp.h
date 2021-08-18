
#ifndef IP_ICMP_H
#define IP_ICMP_H
struct icmp {
u_char icmp_type;
u_char icmp_code;
u_short icmp_cksum;
union {
u_char ih_pptr;
struct in_addr ih_gwaddr;
struct ih_idseq {
n_short icd_id;
n_short icd_seq;
} ih_idseq;
int ih_void;
} icmp_hun;
#define icmp_pptr icmp_hun.ih_pptr
#define icmp_gwaddr icmp_hun.ih_gwaddr
#define icmp_id icmp_hun.ih_idseq.icd_id
#define icmp_seq icmp_hun.ih_idseq.icd_seq
#define icmp_void icmp_hun.ih_void
union {
struct id_ts {
n_time its_otime;
n_time its_rtime;
n_time its_ttime;
} id_ts;
struct id_ip {
struct ip idi_ip;
} id_ip;
u_long id_mask;
char id_data[1];
} icmp_dun;
#define icmp_otime icmp_dun.id_ts.its_otime
#define icmp_rtime icmp_dun.id_ts.its_rtime
#define icmp_ttime icmp_dun.id_ts.its_ttime
#define icmp_ip icmp_dun.id_ip.idi_ip
#define icmp_mask icmp_dun.id_mask
#define icmp_data icmp_dun.id_data
};
#define ICMP_MINLEN 8
#define ICMP_TSLEN (8 + 3 * sizeof (n_time))
#define ICMP_MASKLEN 12
#define ICMP_ADVLENMIN (8 + sizeof (struct ip) + 8)
#define ICMP_ADVLEN(p) (8 + ((p)->icmp_ip.ip_hl << 2) + 8)
#define ICMP_ECHOREPLY 0
#define ICMP_UNREACH 3
#define ICMP_UNREACH_NET 0
#define ICMP_UNREACH_HOST 1
#define ICMP_UNREACH_PROTOCOL 2
#define ICMP_UNREACH_PORT 3
#define ICMP_UNREACH_NEEDFRAG 4
#define ICMP_UNREACH_SRCFAIL 5
#define ICMP_SOURCEQUENCH 4
#define ICMP_REDIRECT 5
#define ICMP_REDIRECT_NET 0
#define ICMP_REDIRECT_HOST 1
#define ICMP_REDIRECT_TOSNET 2
#define ICMP_REDIRECT_TOSHOST 3
#define ICMP_ECHO 8
#define ICMP_TIMXCEED 11
#define ICMP_TIMXCEED_INTRANS 0
#define ICMP_TIMXCEED_REASS 1
#define ICMP_PARAMPROB 12
#define ICMP_TSTAMP 13
#define ICMP_TSTAMPREPLY 14
#define ICMP_IREQ 15
#define ICMP_IREQREPLY 16
#define ICMP_MASKREQ 17
#define ICMP_MASKREPLY 18
#define ICMP_MAXTYPE 18
#define ICMP_INFOTYPE(type) \
((type) == ICMP_ECHOREPLY || (type) == ICMP_ECHO || \
(type) == ICMP_TSTAMP || (type) == ICMP_TSTAMPREPLY || \
(type) == ICMP_IREQ || (type) == ICMP_IREQREPLY || \
(type) == ICMP_MASKREQ || (type) == ICMP_MASKREPLY)
#endif
