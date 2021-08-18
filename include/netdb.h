#ifndef NETDB_H
#define NETDB_H
struct hostent {
char *h_name;
char **h_aliases;
int h_addrtype;
int h_length;
char **h_addr_list;
#define h_addr h_addr_list[0]
};
struct netent {
char *n_name;
char **n_aliases;
int n_addrtype;
unsigned long n_net;
};
struct servent {
char *s_name;
char **s_aliases;
int s_port;
char *s_proto;
};
struct protoent {
char *p_name;
char **p_aliases;
int p_proto;
};
#define HOST_NOT_FOUND 1
#define TRY_AGAIN 2
#define NO_RECOVERY 3
#define NO_DATA 4
#define NO_ADDRESS NO_DATA
#endif
