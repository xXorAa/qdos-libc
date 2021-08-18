
#ifndef TCP_H
#define TCP_H
typedef u_long tcp_seq;
struct tcphdr {
u_short th_sport;
u_short th_dport;
tcp_seq th_seq;
tcp_seq th_ack;
#if BYTE_ORDER == LITTLE_ENDIAN
u_char th_x2:4;
u_char th_off:4;
#endif
#if BYTE_ORDER == BIG_ENDIAN
u_char th_off:4;
u_char th_x2:4;
#endif
u_char th_flags;
#define TH_FIN 0x01
#define TH_SYN 0x02
#define TH_RST 0x04
#define TH_PUSH 0x08
#define TH_ACK 0x10
#define TH_URG 0x20
u_short th_win;
u_short th_sum;
u_short th_urp;
};
#define TCPOPT_EOL 0
#define TCPOPT_NOP 1
#define TCPOPT_MAXSEG 2
#define TCP_MSS 512
#define TCP_MAXWIN 65535
#define TCP_NODELAY 0x01
#define TCP_MAXSEG 0x02
#endif
