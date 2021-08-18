*   This is a dummy file to insert at the start of a library to
*   get a comment into it.   It also means that examination of the
*   binary program can tell what versions of the libraries were used.
*
*   It is assembled with the Quanta QMAC assembler as this is the only
*   QL assembler that I know of that supports all of the following:
*       a)  Allows comments to be inserted into the SROFF output
*       b)  Allows long label names with all characters significant
*       c)  Allows leading underscores in names.
*
*   AMENDMENT HISTORY
*   ~~~~~~~~~~~~~~~~~
*   10 Mar 96   DJW   - First version
*

    SECTION TEXT

    COMMENT C68 libfpu_a v4.20d

    XDEF    LIBFPU_VER
LIBFPU_VER:    dc.b    'C68 libfpu_a v4.20d',0

    END

