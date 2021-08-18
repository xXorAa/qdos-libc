
#ifndef UDP_H
#define UDP_H
struct udphdr {
u_short uh_sport;
u_short uh_dport;
short uh_ulen;
u_short uh_sum;
};
#endif
