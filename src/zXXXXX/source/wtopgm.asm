//WTOPGM   JOB 1,NOTIFY=&SYSUID                                         00010099
//WTOPGM   EXEC ASMACL,MBR=WTOPGM                                       00020099
//C.SYSIN  DD *                                                         00030099
WTOPGM   TITLE 'WTO literal pgm'                                        00040099
WTOPGM   CSECT                                                          00050099
*--------------------------------------------------------------------*  00060099
*        register equates                                            *  00070099
*--------------------------------------------------------------------*  00080099
R0       EQU   0                       register 0                       00090099
R1       EQU   1                       register 1                       00100099
R2       EQU   2                       register 2                       00110099
R3       EQU   3                       register 3                       00120099
R4       EQU   4                       register 4                       00130099
R5       EQU   5                       register 5                       00140099
R6       EQU   6                       register 6                       00150099
R7       EQU   7                       register 7                       00160099
R8       EQU   8                       register 8                       00170099
R9       EQU   9                       register 9                       00180099
R10      EQU   10                      register 10                      00190099
R11      EQU   11                      register 11                      00200099
R12      EQU   12                      register 12                      00210099
R13      EQU   13                      register 13                      00220099
R14      EQU   14                      register 14                      00230099
R15      EQU   15                      register 15                      00240099
BASEREG  EQU   12                      base register                    00250099
SAVEREG  EQU   13                      save area register               00260099
RETREG   EQU   14                      caller's return address          00270099
ENTRYREG EQU   15                      entry address                    00280099
RETCODE  EQU   15                      return code                      00290099
         EJECT                                                          00300099
*--------------------------------------------------------------------*  00310099
*        standard entry setup, save area chaining, establish         *  00320099
*        base register and addressibility                            *  00330099
*--------------------------------------------------------------------*  00340099
         USING WTOPGM,ENTRYREG         establish addressibility         00350099
         B     SETUP                   branch around eyecatcher         00360099
         DC    CL6'WTOPGM'             program name                     00370099
SETUP    STM   RETREG,BASEREG,12(SAVEREG)  save caller's registers      00380099
         BALR  BASEREG,R0              establish base register          00390099
         DROP  ENTRYREG                drop initial base register       00400099
         USING *,BASEREG               establish addressibilty          00410099
         LA    ENTRYREG,SAVEAREA       point to this program save area  00420099
         ST    SAVEREG,4(,ENTRYREG)    save address of caller           00430099
         ST    ENTRYREG,8(,SAVEREG)    save address of this program     00440099
         LR    SAVEREG,ENTRYREG        point to this program savearea   00450099
         EJECT                                                          00460099
*--------------------------------------------------------------------*  00470099
*        program body                                                *  00480099
*--------------------------------------------------------------------*  00490099
         L     6,=C'Begin'                                              00500099
         LA    6,=C'Begin'                                              00510099
LOOPINIT DS    0H                      halfword boundary alignment      00520099
         LGFI  R7,10                   load loop count (10, 64-bit)     00530099
LOOP     DS    0H                      halfword boundary alignment      00540099
         WTO   'WTOPGM - HELLO WORLD!' literal message to print         00550099
         BCT   R7,LOOP                 loop until R7 reaches 0          00560099
STOP1    LH    7,HALFCON                                                00570099
STOP2    A     7,FULLCON                                                00580099
STOP3    ST    7,HEXCON                                                 00590099
         EJECT                                                          00600099
*--------------------------------------------------------------------*  00610099
*        standard exit -  restore caller's registers and             *  00620099
*        return to caller                                            *  00630099
*--------------------------------------------------------------------*  00640099
EXIT     DS    0H                      halfword boundary alignment      00650099
         L     SAVEREG,4(,SAVEREG)     restore caller's save area addr  00660099
         L     RETREG,12(,SAVEREG)     restore return address register  00670099
         LM    R0,BASEREG,20(SAVEREG)  restore all regs. except RETCODE 00680099
         WTO   'Giving control back to system'                          00690099
         BR    RETREG                  return to caller                 00700099
         EJECT                                                          00710099
*--------------------------------------------------------------------*  00720099
*        storage and constant definitions.                           *  00730099
*        print output definition.                                    *  00740099
*--------------------------------------------------------------------*  00750099
SAVEAREA DC    18F'-1'                 register save area               00760099
FULLCON  DC    F'-1'                                                    00770099
HEXCON   DC    XL4'9ABC'                                                00780099
HALFCON  DC    H'32'                                                    00790099
         END   WTOPGM                                                   00800099
//GO      EXEC PGM=WTOPGM                                               00810099
//STEPLIB  DD DSN=&SYSUID..LOAD,DISP=SHR                                00820099
//PRINT    DD SYSOUT=*                                                  00830099
