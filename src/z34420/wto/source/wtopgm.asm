WTOPGM   TITLE 'WTO count pgm'
WTOPGM   CSECT
*--------------------------------------------------------------------*
*        register equates                                            *
*--------------------------------------------------------------------*
               YREGS                   register equates
BASEREG  EQU   12                      base register
SAVEREG  EQU   13                      save area register
RETREG   EQU   14                      caller's return address
ENTRYREG EQU   15                      entry address
RETCODE  EQU   15                      return code
         EJECT
*--------------------------------------------------------------------*
*        standard entry setup, save area chaining, establish         *
*        base register and addressibility                            *
*--------------------------------------------------------------------*
         USING WTOPGM,ENTRYREG         establish addressibility
         B     SETUP                   branch around eyecatcher
         DC    CL6'WTOPGM'             program name
SETUP    STM   RETREG,BASEREG,12(SAVEREG)  save caller's registers
         BALR  BASEREG,R0              establish base register
         DROP  ENTRYREG                drop initial base register
         USING *,BASEREG               establish addressibilty
         LA    ENTRYREG,SAVEAREA       point to this program save area
         ST    SAVEREG,4(,ENTRYREG)    save address of caller
         ST    ENTRYREG,8(,SAVEREG)    save address of this program
         LR    SAVEREG,ENTRYREG        point to this program savearea
         EJECT
*--------------------------------------------------------------------*
*        program body                                                *
*--------------------------------------------------------------------*
         L     6,=C'Begin'
         LA    6,=C'Begin'
LOOPINIT DS    0H                      halfword boundary alignment
         LFI   R7,15                   load loop count (15, FWORD)
         CFI   R7,1                    is loop count positive?
         BL    ABENDLO                 abend if loop count not positive
         CFI   R7,99                   is loop count too large?
         BH    ABENDHI                 abend if loop count too large
LOOP     DS    0H                      halfword boundary alignment
         CVD   R7,PACKED               convert binary to packed dec.
         MVC   ZONED,MASK              move the pattern to zoned buffer
         ED    ZONED,PACKED            fmt packed into zoned w/pattern
         MVC   WTOTEXT(L'ZONED),ZONED  move LOOPCNT into WTO buffer
         MVC   WTOTEXT(L'WTOMSG1),WTOMSG1 move message into WTO buffer
         BAL   R3,DOMSG                call DOMSG subroutine to print
         BCT   R7,LOOP                 loop until R7 reaches 0
         J STOP1                       skip DOMSG subroutine when done
DOMSG    DS    0H                      HALFWORD BOUNDARY ALIGNMENT
         WTO   MF=(E,WTOBLOCK)         CALL WTO MACRO WITH BUFFER
         LTR   RETCODE,RETCODE         DID WTO END WITH CC=0?
         BNZ   ABEND4                  IF NOT, WTO ABEND
         BR    R3                      RETURN TO ADDR AT R3
STOP1    LH    7,HALFCON
STOP2    A     7,FULLCON
STOP3    ST    7,HEXCON
         WTO   '* WTOPGM MLC, is ENDING, CC=0...'
         J EXIT
ABEND4   EQU   *
         WTO   '* WTOPGM MLC, is ABENDING, CC=4...'
         LFI   RETCODE,4              set MAXCC to 4
         J EXIT
ABENDHI  EQU   *
         WTO   '* WTOPGM LOOP COUNT TOO LARGE...'
         LFI   RETCODE,2              set MAXCC to 2
         J EXIT
ABENDLO  EQU   *
         WTO   '* WTOPGM LOOP COUNT TOO SMALL...'
         LFI   RETCODE,1              set MAXCC to 1
*--------------------------------------------------------------------*
*   standard exit - restore caller's registers and return to caller  *
*--------------------------------------------------------------------*
EXIT     DS    0H                      halfword boundary alignment
         L     SAVEREG,4(,SAVEREG)     restore caller's save area addr
         L     RETREG,12(,SAVEREG)     restore return address register
         LM    R0,BASEREG,20(SAVEREG)  restore all regs. except RETCODE
         BR    RETREG                  return to caller
         EJECT
*--------------------------------------------------------------------*
*        storage and constant definitions.                           *
*        print output definition.                                    *
*--------------------------------------------------------------------*
SAVEAREA DC    18F'-1'                 register save area
FULLCON  DC    F'-1'
HEXCON   DC    XL4'9ABC'
HALFCON  DC    H'32'
         DS    0H            * ENSURE HALF-WORD ALIGNMENT
PACKED   DS    PL16          * 16-digit for register content (LOOPCNT)
ZONED    DS    CL16          * 16-character space
MASK     DC    X'40202020202020202020202020202020'
WTOBLOCK EQU   *
         DC    H'80'         * For WTO, length of WTO buffer,
         DC    H'0'                     should be binary zeroes
WTOTEXT  DC    80C' '
WTOMSG1  DC    C'WTOPGM - LOOP:'
         LTORG
         END   WTOPGM
