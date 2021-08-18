/**
*
* This module defines the error messages corresponding to the codes that
* can appear in _oserr.
*
* AMENDMENT HISTORY
* ~~~~~~~~~~~~~~~~~
*/

char *os_errlist[] = { 
                    "Unknown QDOS error",
/* ERR_NC -1   */   "Operation not complete",
/* ERR_NJ -2   */   "Invalid job",
/* ERR_OM -3   */   "Out of memory",
/* ERR_OR -4   */   "Out of range",
/* ERR_BO -5   */   "Buffer overflow",
/* ERR_NO -6   */   "Channel not open",
/* ERR_NF -7   */   "File or device not found",
/* ERR_EX -8   */   "File already exists",
/* ERR_IU -9   */   "File or device in use",
/* ERR_EF -10  */   "End of file",
/* ERR_DF -11  */   "Drive full",
/* ERR_BN -12  */   "Bad device name",
/* ERR_TE -13  */   "Transmission error",
/* ERR_FF -14  */   "Format failed",
/* ERR_BP -15  */   "Bad parameter",
/* ERR_FE -16  */   "File error",
/* ERR_XP -17  */   "Error in expression",
/* ERR_OV -18  */   "Arithmetic overflow",
/* ERR_NI -19  */   "Not implemented",
/* ERR_RO -20  */   "Device is read only",
/* ERR_BL -21  */   "Bad line in BASIC" };

        /* Highest valid error number */
int os_nerr = sizeof(os_errlist)/sizeof(char *) - 1;

