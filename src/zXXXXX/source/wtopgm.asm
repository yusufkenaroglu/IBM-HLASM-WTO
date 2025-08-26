//WTOPGM   JOB 1,NOTIFY=&SYSUID                                         00010062
//WTOPGM   EXEC ASMACL,MBR=WTOPGM                                       00020063
//C.SYSIN  DD *                                                         00030000
WTOPGM   TITLE 'WTO buffer pgm'                                         00040062
WTOPGM   CSECT                                                          00050062
*--------------------------------------------------------------------*  00060000
*        register equates                                            *  00070000
*--------------------------------------------------------------------*  00080000
R0       EQU   0                       register 0                       00090000
R1       EQU   1                       register 1                       00100001
R2       EQU   2                       register 2                       00110002
R3       EQU   3                       register 3                       00120003
R4       EQU   4                       register 4                       00130004
R5       EQU   5                       register 5                       00140005
R6       EQU   6                       register 6                       00150006
R7       EQU   7                       register 7                       00160007
R8       EQU   8                       register 8                       00170008
R9       EQU   9                       register 9                       00180009
R10      EQU   10                      register 10                      00190010
R11      EQU   11                      register 11                      00200011
R12      EQU   12                      register 12                      00210012
R13      EQU   13                      register 13                      00220013
R14      EQU   14                      register 14                      00230014
R15      EQU   15                      register 15                      00240015
BASEREG  EQU   12                      base register                    00250000
SAVEREG  EQU   13                      save area register               00260000
RETREG   EQU   14                      caller's return address          00270000
ENTRYREG EQU   15                      entry address                    00280000
RETCODE  EQU   15                      return code                      00290000
         EJECT                                                          00300000
*--------------------------------------------------------------------*  00310000
*        standard entry setup, save area chaining, establish         *  00320000
*        base register and addressibility                            *  00330000
*--------------------------------------------------------------------*  00340000
         USING WTOPGM,ENTRYREG         establish addressibility         00350062
         B     SETUP                   branch around eyecatcher         00360000
         DC    CL6'WTOPGM'             program name                     00370062
SETUP    STM   RETREG,BASEREG,12(SAVEREG)  save caller's registers      00380000
         BALR  BASEREG,R0              establish base register          00390000
         DROP  ENTRYREG                drop initial base register       00400000
         USING *,BASEREG               establish addressibilty          00410000
         LA    ENTRYREG,SAVEAREA       point to this program save area  00420000
         ST    SAVEREG,4(,ENTRYREG)    save address of caller           00430000
         ST    ENTRYREG,8(,SAVEREG)    save address of this program     00440000
         LR    SAVEREG,ENTRYREG        point to this program savearea   00450000
         EJECT                                                          00460000
*--------------------------------------------------------------------*  00470000
*        program body                                                *  00480000
*--------------------------------------------------------------------*  00490000
         L     6,=C'Begin'                                              00500001
         LA    6,=C'Begin'                                              00510001
LOOPINIT DS    0H                      halfword boundary alignment      00520000
         LGFI  R7,10                   load loop count (10, 64-bit)     00530070
LOOP     DS    0H                      halfword boundary alignment      00540000
         MVC   WTOTEXT(76),WTOMSG1     load buffer with message         00550001
         BAL   R3,DOMSG                call DOMSG subroutine to print   00560002
         BCT   R7,LOOP                 loop until R7 reaches 0          00570001
         J STOP1                       skip DOMSG subroutine when done  00580002
DOMSG    EQU   *                       HALFWORD BOUNDARY ALIGNMENT      00590070
         WTO   MF=(E,WTOBLOCK)         CALL WTO MACRO WITH BUFFER       00600071
         LTR   R15,R15                 IS REG-15 = ZERO?                00610072
         BNZ   ABEND4                  IF NOT, WTO ABEND                00620073
         BR    R3                      RETURN TO ADDR AT R3             00630074
STOP1    LH    7,HALFCON                                                00640001
STOP2    A     7,FULLCON                                                00650001
STOP3    ST    7,HEXCON                                                 00660001
         EJECT                                                          00670002
         J EXIT                                                         00680003
ABEND4   EQU   *                                                        00690004
         WTO   '* WTOPGM MLC, is ABENDING, RC=4...'                     00700005
         LGFI  RETCODE,4                                                00710006
*--------------------------------------------------------------------*  00720000
*        standard exit -  restore caller's registers and             *  00730000
*        return to caller                                            *  00740000
*--------------------------------------------------------------------*  00750000
EXIT     DS    0H                      halfword boundary alignment      00760000
         L     SAVEREG,4(,SAVEREG)     restore caller's save area addr  00770000
         L     RETREG,12(,SAVEREG)     restore return address register  00780000
         LM    R0,BASEREG,20(SAVEREG)  restore all regs. except RETCODE 00790000
         WTO   'Giving control back to system'                          00800001
         BR    RETREG                  return to caller                 00810000
         EJECT                                                          00820000
*--------------------------------------------------------------------*  00830000
*        storage and constant definitions.                           *  00840000
*        print output definition.                                    *  00850000
*--------------------------------------------------------------------*  00860000
SAVEAREA DC    18F'-1'                 register save area               00870000
FULLCON  DC    F'-1'                                                    00880001
HEXCON   DC    XL4'9ABC'                                                00890001
HALFCON  DC    H'32'                                                    00900001
         DS    0H            * ENSURE HALF-WORD ALIGNMENT               00910002
WTOBLOCK EQU   *                                                        00920003
         DC    H'80'         * For WTO, length of WTO buffer,           00930004
         DC    H'0'                     should be binary zeroes         00940005
WTOTEXT  DC    CL80'WTOPGM - WTO with user-coded buffer...'             00950006
WTOMSG1  DC    CL80'WTOPGM - MESSAGE 1'                                 00960007
WTOMSG2  DC    CL80'WTOPGM - MESSAGE 2'                                 00970008
WTOMSG3  DC    CL80'WTOPGM - MESSAGE 3'                                 00980099
         END   WTOPGM                                                   00990062
//GO      EXEC PGM=WTOPGM                                               01000062
//STEPLIB  DD DSN=&SYSUID..LOAD,DISP=SHR                                01010000
//PRINT    DD SYSOUT=*                                                  01020002
