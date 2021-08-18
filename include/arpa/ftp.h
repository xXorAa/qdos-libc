
#ifndef _FTP_H_
#define _FTP_H_
#define PRELIM 1
#define COMPLETE 2
#define CONTINUE 3
#define TRANSIENT 4
#define ERROR 5
#define TYPE_A 1
#define TYPE_E 2
#define TYPE_I 3
#define TYPE_L 4
#ifdef FTP_NAMES
char *typenames[] = {"0","ASCII","EBCDIC","Image","Local"};
#endif
#define FORM_N 1
#define FORM_T 2
#define FORM_C 3
#ifdef FTP_NAMES
char *formnames[] = {"0","Nonprint","Telnet","Carriage-control"};
#endif
#define STRU_F 1
#define STRU_R 2
#define STRU_P 3
#ifdef FTP_NAMES
char *strunames[] = {"0","File","Record","Page"};
#endif
#define MODE_S 1
#define MODE_B 2
#define MODE_C 3
#ifdef FTP_NAMES
char *modenames[] = {"0","Stream","Block","Compressed"};
#endif
#define REC_ESC'\377'
#define REC_EOR'\001'
#define REC_EOF'\002'
#define BLK_EOR 0x80
#define BLK_EOF 0x40
#define BLK_ERRORS 0x20
#define BLK_RESTART 0x10
#define BLK_BYTECOUNT 2
#endif
