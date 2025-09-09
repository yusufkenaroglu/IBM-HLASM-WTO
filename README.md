# IBM HLASM WTO - Write-To-Operator Operations with IBM High Level Assembler

[![License](https://img.shields.io/github/license/yusufkenaroglu/IBM-HLASM-WTO)](LICENSE)
[![Language](https://img.shields.io/badge/language-IBM%20HLASM%20%7C%20JCL-blue)](https://www.ibm.com/products/high-level-assembler-and-toolkit-feature)

## Overview

This repository contains IBM High Level Assembler (HLASM) programs demonstrating Write-To-Operator (WTO) macro operations. The main program `WTOPGM` showcases system console messaging with loop control, numeric formatting, and subroutine calls in a mainframe environment.

## Repository Structure

```
zXXXXX/
├── wto/
│   ├── source/
│   │   └── wtopgm.asm          # Main HLASM WTO program
│   └── jcl/
│       ├── asm.jcl             # Assembly job
│       └── run.jcl             # Execution job
└── jcl/
    └── alloc001.jcl            # Dataset allocation
```

## Program Features

The `WTOPGM` program demonstrates:

- **WTO macro operations** for printing text to the console
- **Subroutine programming** with caller/callee linkage
- **Binary-decimal conversion** and decimal formatting
- **Loop control** with BCT (Branch on Count) instruction
- **Input validation** with range checking (1-99)
- **Edit mask formatting** for EBCDIC output
- **Error handling** with return codes

## Key Code Snippets

### WTO Operations with DOMSG Subroutine
```asm
* Format and display message using subroutine
         CVD   R7,PACKED               convert binary to packed dec.
         MVC   ZONED,MASK              move the pattern to zoned buffer
         ED    ZONED,PACKED            fmt packed into zoned w/pattern
         MVC   WTOTEXT(L'ZONED),ZONED  move LOOPCNT into WTO buffer
         MVC   WTOTEXT(L'WTOMSG1),WTOMSG1 move message into WTO buffer
         BAL   R3,DOMSG                call DOMSG subroutine to print
         BCT   R7,LOOP                 loop until R7 reaches 0

DOMSG    DS    0H                      HALFWORD BOUNDARY ALIGNMENT
         WTO   MF=(E,WTOBLOCK)         CALL WTO MACRO WITH BUFFER
         LTR   RETCODE,RETCODE         DID WTO END WITH CC=0?
         BNZ   ABEND4                  IF NOT, WTO ABEND
         BR    R3                      RETURN TO ADDR AT R3
```

### Loop Initialization and Validation
```asm
LOOPINIT DS    0H                      halfword boundary alignment
         LFI   R7,15                   load loop count (15, FWORD)
         CFI   R7,1                    is loop count positive?
         BL    ABENDLO                 abend if loop count not positive
         CFI   R7,99                   is loop count too large?
         BH    ABENDHI                 abend if loop count too large
```

### WTO Buffer Definition
```asm
WTOBLOCK EQU   *
         DC    H'80'         * For WTO, length of WTO buffer,
         DC    H'0'                     should be binary zeroes
WTOTEXT  DC    80C' '
WTOMSG1  DC    C'WTOPGM - LOOP:'
```

### Data Formatting
```asm
PACKED   DS    PL16          * 16-digit for register content (LOOPCNT)
ZONED    DS    CL16          * 16-character space
MASK     DC    X'40202020202020202020202020202020'
```

## Setup and Execution

### 1. Project Dataset Allocation

First, allocate the required datasets using the provided JCL:

```jcl
//WTOALLOC JOB (ACCT),'ALLOCATE WTO PDS',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),NOTIFY=&SYSUID
//ALLOC    EXEC PGM=IEFBR14
//JCL      DD  DSN=&SYSUID..WTO.JCL,
//             DISP=(NEW,CATLG,DELETE),
//             UNIT=SYSDA,
//             SPACE=(TRK,(5,5,5)),
//             DCB=(DSORG=PO,RECFM=FB,LRECL=80,BLKSIZE=0)
//SOURCE   DD  DSN=&SYSUID..WTO.SOURCE,
//             DISP=(NEW,CATLG,DELETE),
//             UNIT=SYSDA,
//             SPACE=(TRK,(10,5,5)),
//             DCB=(DSORG=PO,RECFM=FB,LRECL=80,BLKSIZE=0)
```

### 2. Assembling the Source Code

Assemble the program using the ASMACL procedure:

```jcl
//WTOPGASM   JOB 1,NOTIFY=&SYSUID,MSGLEVEL=(1,1)
//ASM      EXEC ASMACL,MBR=WTOPGM
//C.SYSIN  DD  DSN=&SYSUID..WTO.SOURCE(WTOPGM),DISP=SHR
//SYSLMOD  DD  DSN=&SYSUID..LOAD,DISP=SHR
```

### 3. Executing the Binary

Run the program to see WTO messages in JESYSMSG:

```jcl
//WTOPGRUN   JOB 2,NOTIFY=&SYSUID
//GO       EXEC PGM=WTOPGM
//STEPLIB  DD DSN=&SYSUID..LOAD,DISP=SHR
//SYSPRINT DD SYSOUT=*
```

## Return Codes

| Code | Condition | Description |
|------|-----------|-------------|
| 0 | Normal | Successful execution |
| 1 | ABENDLO | Loop count < 1 |
| 2 | ABENDHI | Loop count > 99 |
| 4 | ABEND4 | WTO operation failed |

## Technical Highlights

### WTO Macro Features
- **MF=(E,WTOBLOCK)**: Execute form using pre-built parameter list
- **Dynamic message formatting**: Counter value inserted into messages
- **Error checking**: Return code validation after WTO calls

### Assembly Programming Techniques
- **Subroutine linkage**: BAL (Branch and Link) / BR (Branch Register)
- **BCT instruction**: Efficient loop control with automatic decrement
- **CVD instruction**: Convert binary register to packed decimal
- **ED instruction**: Edit packed decimal with formatting mask
- **LFI/CFI instructions**: Load/Compare Fullword Immediate

### Data Conversion Chain
```
Binary Register (R7) >> CVD >> Packed Decimal >> ED >> Formatted Text
```

## Prerequisites

- IBM z/OS environment
- Access to system macro libraries (SYS1.MACLIB)
- Authority to create datasets and submit jobs

## Usage Notes

- Program only accepts the loop counter through register 7
- Changes to source code require submitting ASM.jcl to take effect
- Edit mask suppresses leading zeros in counter display
- All JCL uses symbolic parameters (&SYSUID) for dataset names

## Sample Output (JESYSMSG)

When executed, the program will display messages like:
```
 WTOPGM - LOOP:15
 WTOPGM - LOOP:14
 WTOPGM - LOOP:13
.
.
.
 WTOPGM - LOOP: 1
 * WTOPGM MLC, is ENDING, CC=0...
```
