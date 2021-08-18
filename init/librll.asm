;
;       l i b r l l
;
;   Initial header for a RLL library.
;   The LD linker will fill in additional fields as required.
;
;   We currently cannot use the AS68 assembler as it cannot handle
;   label difference operands when the operands are in different
;   sections or files.
;
;   AMENDMENT HISTORY
;   ~~~~~~~~~~~~~~~~~
;   $Log$
;------------------------------------------------------------------------

    section TEXT


    section BSS

BSS_START:
