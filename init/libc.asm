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
*   31 Mar 94   DJW   - Added 2 underscores to name.
*
*   16 Sep 94   DJW   - Removed all underscores from name to make completely
*                       invisible at the C level.
*
*   28 May 98   DJW   - Updated version number to 4.24a
*   18 Jul 98   DJW   - Updated version number to 4.24b
*   21 Jul 98   DJW   - Updated version number to 4.24c
*   08 Aug 98   DJW   - Updated version number to 4.24d
*   30 Aug 98   DJW   - Updated version number to 4.24e
*   31 Oct 98   DJW   - Updated version number to 4.24f
*   20 Mar 99   DJW   - Updated version number to 4.24g
*   25 Sep 99   DJW   - Updated version number to 4.24h
*   06 Feb 00   DJW   - Updated version number to 4.24i due to _vfscanf() fix
*   22 Sep 00   TG    - Updated version number to 4.24.1 (libc_a port to qdos-gcc)
*   25 Sep 00   TG    - Updated version number to 4.24.2
*   27 Sep 00   TG    - Updated version number to 4.24.3
*   13 Oct 00   TG    - Updated version number to 4.24.4

    SECTION TEXT

    COMMENT C68 libc.a v4.24.5 (gcc)

    XDEF    LIBC_VER

LIBC_VER:    dc.b    'C68 libc.a v4.24.5 (gcc)'

    END

