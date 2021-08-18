
#ifndef IP_VAR_H
#define IP_VAR_H
struct ipovly {
caddr_t ih_next,ih_prev;
u_char ih_x1;
u_char ih_pr;
short ih_len;
struct in_addr ih_src;
struct in_addr ih_dst;
};
struct ipq {
struct ipq *next,*prev;
u_char ipq_ttl;
u_char ipq_p;
u_short ipq_id;
struct ipasfrag *ipq_next,*ipq_prev;
struct in_addr ipq_src,ipq_dst;
};
struct ipasfrag {
#if BYTE_ORDER == LITTLE_ENDIAN
u_char ip_hl:4;
u_char ip_v:4;
#endif
#if BYTE_ORDER == BIG_ENDIAN
u_char ip_v:4;
u_char ip_hl:4;
#endif
u_char ipf_mff;
short ip_len;
u_short ip_id;
short ip_off;
u_char ip_ttl;
u_char ip_p;
u_short ip_sum;
struct ipasfrag *ipf_next;
struct ipasfrag *ipf_prev;
};
#define MAX_IPOPTLEN 40
struct ipoption {
struct in_addr ipopt_dst;
char ipopt_list[MAX_IPOPTLEN];
};
struct ipstat {
long ips_total;
long ips_badsum;
long ips_tooshort;
long ips_toosmall;
long ips_badhlen;
long ips_badlen;
long ips_fragments;
long ips_fragdropped;
long ips_fragtimeout;
long ips_forward;
long ips_cantforward;
long ips_redirectsent;
long ips_noproto;
long ips_delivered;
long ips_localout;
long ips_odropped;
long ips_reassembled;
long ips_fragmented;
long ips_ofragments;
long ips_cantfrag;
};
#endif
