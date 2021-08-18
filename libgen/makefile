#
#   Makefile for building the LIBGEN library for C68
#
#   Assumes that Default DATA directory is one containing source and objects

CC=cc
CFLAGS = -c -O -error=5 -warn=6 -maxerr=5 -Qstackopt=maximum

ASFLAGS = -c
CPPFLAGS = 
MAC = qmac

AS = cc
ASM = mac
LD = ld
RM = rm

S=_

I   =   $(P)INCLUDE_

.SUFFIXES : $(S)x $(S)s $(S)asm $(S)o _rel $(S)hdr $(S)h

SRC =       _cescint$(S)c     _hexint$(S)c      _octint$(S)c \
            _intcesc$(S)c     _streadd$(S)c     _stresiz$(S)c \
            basename$(S)c     bgets$(S)c        bufsplit$(S)c \
            copylist$(S)c     dirname$(S)c \
            gmatch$(S)c       pathfind$(S)c \
            strcadd$(S)c      strccpy$(S)c \
            streadd$(S)c      strecpy$(S)c      stresize$(S)c \
            strfind$(S)c      strrspn$(S)c      strtrns$(S)c

OBJS =      _cescint$(S)o     _hexint$(S)o      _octint$(S)o \
            _intcesc$(S)o     _streadd$(S)o     _stresiz$(S)o \
            basename$(S)o     bgets$(S)o        bufsplit$(S)o \
            copylist$(S)o     dirname$(S)o \
            gmatch$(S)o       pathfind$(S)o \
            strcadd$(S)o      strccpy$(S)o \
            streadd$(S)o      strecpy$(S)o      stresize$(S)o \
            strfind$(S)o      strrspn$(S)o      strtrns$(S)o

#  Not yet implemented
XOBJS =     isencrypt$(S)o \
            mkdirp$(S)o       rmdirp$(S)o \
            p2open$(S)o       p2close$(S)o \
            regcmp$(S)o       regex$(S)o \
            compile$(S)o      step$(S)o         advance$(S)

all:    libgen_a    testprog

libgen_a :   $(I)libgen$(S)h $(OBJS) libgen$(S)o slblist
    slb -crv libgen_a libgen$(S)o
    slb -crv -mslblist libgen_a

slblist :   $(OBJS) libgen$(S)o
        @slb -v -Lslblist_tmp $(OBJS)
        tsort slblist_tmp >slblist
        @rm -f libgen_a slblist_tmp wlist ylist
        @slb -v -Wwlist $(OBJS) libgen$(S)o
        @slb -v -Yylist $(OBJS) libgen$(S)o

testprog: testprog_c $(OBJS)
        cc -otestprog testprog$(S)c $(OBJS)

$(S)x$(S):
    cpp -P $(CPPFLAGS) $*$(S)x $*$(S)s
    $(AS) $(ASFLAGS) $*$(S)s
    $(RM) $*$(S)s

_x_s:
    cpp -A -dAS68 $(CPPFLAGS) $*_x $*_s

_c$(S):
    $(CC) $(CFLAGS) $<

_s$(S):
    $(AS) $(ASFLAGS) $<

_asm$(S)o:
    $(MAC) $*_asm -ERRORS $*_list -BIN $*$(S)o -NOWINDS

$(S)hdr$(S)h :
    packhdr $*$(S)hdr $*$(S)h

clean :
        @rm -fv $(OBJS)

clobber : clean
        @rm -fv libgen_a slblist wlist ylist

#-------------------------- Header file dependencies -------------------------


$(OBJS) :  $(I)libgen$(S)h

_streadd$(S)o :   $(I)libgen$(S)h    $(I)ctype$(S)h     $(I)string$(S)h    $(I)qdos$(S)h
basename$(S)o :   $(I)libgen$(S)h    $(I)string$(S)h
bufsplit$(S)o :   $(I)libgen$(S)h    $(I)string$(S)h
bgets$(S)o    :   $(I)libgen$(S)h    $(I)string$(S)h    $(I)stdlib$(S)h
copylist$(S)o :   $(I)libgen$(S)h    $(I)unistd$(S)h    $(I)sys_types$(S)h $(I)sys_stat$(S)h
dirname$(S)o  :   $(I)libgen$(S)h
gmatch$(S)o   :   $(I)libgen$(S)h
pathfind$(S)o :   $(I)libgen$(S)h    $(I)limits$(S)h    $(I)string$(S)h \
                  $(I)sys_stat$(S)h
strcadd$(S)o  :   $(I)libgen$(S)h    $(I)string$(S)h    $(I)qdos$(S)h
strccpy$(S)o  :   $(I)libgen$(S)h
streadd$(S)o  :   $(I)libgen$(S)h
strecpy$(S)o  :   $(I)libgen$(S)h
strfind$(S)o  :   $(I)libgen$(S)h    $(I)string$(S)h
strrspn$(S)o  :   $(I)libgen$(S)h    $(I)string$(S)h
strtrns$(S)o  :   $(I)libgen$(S)h

