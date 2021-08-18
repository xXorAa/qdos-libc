#
#   Makefile for the IEEE support modules for c68
#
#   The following special values can be used within the DEFINES
#   settings:
#       -DLONG_DOUBLE   Ask for long double (96 bit FP) routines
#       -DHW_FPU        Ask for Hardware FPU support.
#                       (currently only supported for QDOS)
#       -DMOTOROLA      Generate assembler directives in Motorola style
#                       (this is also the default).
#       -DACK           Generate assembler directives in ACK style
#                       (also used by AS68 under QDOS)
#------------------------------------------------------------------------

# DEFINES = -DHW_FPU -DACK -DLONG_DOUBLE -DQDOS
DEFINES = -DHW_FPU -DACK -DQDOS

CPPFLAGS =

AS = cc -c
CC = cc -c $(DEFINES)
AR = ar
LIB = /usr/lib
CCFLAGS =
LDFLAGS = -ms
ASFLAGS =
LIBS = -lm

#----------------------------------------------------------
#   Values for use on QDOS
S=_
CCFLAGS= -Qmaxerr=1
AR=slb
#----------------------------------------------------------
#   Values for use on LINUX
# S=.               AR=slb
#----------------------------------------------------------

.SUFFIXES : $(S)x $(S)o $(S)h

SRC=Xerror$(S)s Xnorm4$(S)s Xnorm8$(S)s \
    sfcmp$(S)s      dfcmp$(S)s      lfcmp$(S)s \
    Ysftst$(S)s     Ydftst$(S)s     Ylftst$(S)s \
    Ysfadd$(S)s     Ydfadd$(S)s     Ylfadd$(S)o \
    Ysfdiv$(S)s     Ydfdiv$(S)s \
    Ysfmul$(S)s     Ydfmul$(S)s \
    Ysfneg$(S)s     Ydfneg$(S)s     Ylfneg$(S)s \
    Ysfinc$(S)s     Ydfinc$(S)s \
    Yasdivsf$(S)s   Yasdivdf$(S)s   Yasdivlf$(S)s \
    Yasmulsf$(S)s   Yasmuldf$(S)s   Yasmullf$(S)s \
    Yasopsf$(S)s    Yasopdf$(S)s    Yasoplf$(S)s \
    Ysfltosf$(S)s   Ydfltodf$(S)s \
    Ysfutosf$(S)s   Ydfutodf$(S)s \
    Ysftoul$(S)s    Ydftoul$(S)s \
    Ysftol$(S)s     Ydftol$(S)s     Ylftol$(S)s \
    Ysftodf$(S)s \
                    Ydftosf$(S)s \
    Ysftolf$(S)s    Ydftolf$(S)s \
    frexp$(S)s      ldexp$(S)s \
    modf$(S)s       modff$(S)s \
    FPcheck$(S)s \
    ieeeconf$(S)h   Makefile

#   LF routines not yet implemented that need doing!
SRC_LF= Ylfdiv$(S)s Ylfltodf$(S)s Ylfmul$(S)s Ylfinc$(S)s \
        Ylftosf$(S)s Ylfutolf$(S)s Ylfutolf$(S)s 

OBJ=Xerror$(S)o Xnorm4$(S)o Xnorm8$(S)o \
    sfcmp$(S)o      dfcmp$(S)o      lfcmp$(S)o \
    Ysftst$(S)o     Ydftst$(S)o     Ylftst$(S)o \
    Ysfadd$(S)o     Ydfadd$(S)o     Ylfadd$(S)o \
    Ysfdiv$(S)o     Ydfdiv$(S)o \
    Ysfmul$(S)o     Ydfmul$(S)o \
    Ysfneg$(S)o     Ydfneg$(S)o     Ylfneg$(S)o \
    Ysfinc$(S)o     Ydfinc$(S)o \
    Yasdivsf$(S)o   Yasdivdf$(S)o \
    Yasmulsf$(S)o   Yasmuldf$(S)o \
    Yasopsf$(S)o    Yasopdf$(S)o \
    Ysfltosf$(S)o   Ydfltodf$(S)o \
    Ysfutosf$(S)o   Ydfutodf$(S)o \
    Ysftoul$(S)o    Ydftoul$(S)o \
    Ysftol$(S)o     Ydftol$(S)o     Ylftol$(S)o \
    Ysftodf$(S)o \
                    Ydftosf$(S)o \
    Ysftolf$(S)o    Ydftolf$(S)o \
    frexp$(S)o ldexp$(S)o modf$(S)o modff$(S)o FPcheck$(S)o

#   long double routines that are not yet ready
#    Ylfdiv$(S)o Ylfmul$(S)o Ylfinc$(S)o \
#    Yasdivlf$(S)o Yasmullf$(S)o Yasoplf$(S)o \
#    Ylfltolf$(S)o Ylfutolf$(S)o Ylftoul$(S)o Ylftosf$(S)o Ylftodf$(S)o \

#   coldfire support routines that are not yet completed
#       $(IEEE)Xascdiv_o    $(IEEE)Xasucdiv_o \
#       $(IEEE)Xassdiv_o    $(IEEE)Xasusdiv_o \
#       $(IEEE)Xsdiv_o      $(IEEE)Xusdiv_o

#   Modules that will only be needed if using an old
#   old version of the compiler befor the parameter passing
#   mechanism was changed for IEEE support routines.

OLDSRC=asdiv$(S)s asmul$(S)s \
    dfadd$(S)s dfcmp$(S)s dfdiv$(S)s dfltodf$(S)s dfmul$(S)s \
    dfneg$(S)s dftol$(S)s dftosf$(S)s dftoul$(S)s dftst$(S)s dfutodf$(S)s \
    sfadd$(S)s sfcmp$(S)s sfdiv$(S)s sfltosf$(S)s sfmul$(S)s \
    sfneg$(S)s sftodf$(S)s sftol$(S)s sftoul$(S)s sftst$(S)s sfutosf$(S)s 

#   Old objects.
#   Only needed if backwards compatibility
#   with old libraries is needed.
OLDOBJ=asdiv$(S)o asmul$(S)o \
    dfadd$(S)o dfdiv$(S)o dfltodf$(S)o dfmul$(S)o \
    dfneg$(S)o dftol$(S)o dftosf$(S)o dftoul$(S)o dftst_o dfutodf$(S)o \
    sfadd$(S)o sfdiv$(S)o sfltosf$(S)o sfmul$(S)o \
    sfneg$(S)o sftodf$(S)o sftol$(S)o sftoul$(S)o sftst$(S)o sfutosf$(S)o

# all : $(OBJ) $(OLDOBJ) ieeetest fputest
all : $(OBJ) ieeetest fputest

#
#   Default rules
#
$(S)x$(S)o:
    $(CC) $(CPPFLAGS) $(ASFLAGS) $*$(S)x

# $(S)s$(S)o :
# 	$(AS) $<

#	The following command line MUST include the library you use
#	for printing floating point numbers.  

ieeetest :	ieeetest$(S)c $(OBJ)
	cc $(CCFLAGS) $(LDFLAGS) -o ieeetest ieeetest$(S)c $(OBJ) $(LIBS)

fputest : fputest$(S)c $(OBJ)
	cc -V $(CCFLAGS) $(LDFLAGS) -fpu=yes -o fputest fputest$(S)c $(OBJ) $(LIBS)

zipsrc:
	zip libieee$(S)zip $(SRC)

#----------------------------------------------------------------------
#       dependancies

$(OBJ) : ieeeconf$(S)h
$(OLDOBJ) : ieeeconf$(S)h

