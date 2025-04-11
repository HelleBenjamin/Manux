
SECTION CODE

  EXTERN crt0_init_bss
  EXTERN _OS_ENTRY

  ORG 0xB004 ; Kernel Area

; Memory map
; ----------
; | 0xFFFF |
; | 0xF000 |
; | 0xE000 |
; | 0xD000 |
; | 0xC000 | BSS section ^
; | 0xB004 | Kernel ^
; | 0xB000 | Syscall call vector
; | 0xA500 | OS Stack V
; | 0xA000 |
; | 0x9000 |
; | 0x8000 | BASIC WORKSPACE ^
; | 0x0000 | BASIC ROM
; ----------

KERNEL_WORKSPACE EQU $AF00

KERNEL_SP EQU KERNEL_WORKSPACE+2
USER_SP EQU KERNEL_WORKSPACE+4
PROCESS_SP EQU KERNEL_WORKSPACE+6
SYSCALL_COUNT EQU KERNEL_WORKSPACE+8
KERNEL_FLAGS EQU KERNEL_WORKSPACE+10
PROC_COUNT EQU KERNEL_WORKSPACE+12
; Temporal registers
TMP_REG1 EQU KERNEL_WORKSPACE+14
TMP_REG2 EQU KERNEL_WORKSPACE+16
TMP_REG3 EQU KERNEL_WORKSPACE+18

PROCESS_STACK EQU $AF00
KERNEL_STACK EQU $AB00
USER_STACK EQU $A500

  ; Kernel flags
  ; bit 0 - echo, should print text on gets
  ; bit 1 - mode, kernelmode (0) or usermode (1)
  ; bit 2 - unused
  ; bit 3 - unused
  ; bit 4 - unused
  ; bit 5 - unused
  ; bit 6 - unused
  ; bit 7 - unused

  MACRO SWITCH_TO_KERNEL
    LD (USER_SP), SP
    LD SP, (KERNEL_SP)
    PUSH HL
    LD HL, KERNEL_FLAGS
    RES 1, (HL)
    POP HL
  ENDM

  MACRO SWITCH_TO_USER
    PUSH HL
    LD HL, KERNEL_FLAGS
    SET 1, (HL)
    POP HL
    LD SP, (USER_SP)
  ENDM


KERNEL_ENTRY:
  LD HL, 0
  ADD HL, SP
  LD SP, KERNEL_STACK ; Set kernel stack
  PUSH HL ; Save old sp
  LD (KERNEL_SP), SP ; Save kernel sp, this also saves the old sp

  ; Load syscall handler address
  LD HL, $B000
  LD DE, SYSCALL_DISPATCH
  LD (HL), $C3 ; JP
  INC HL
  LD (HL), E
  INC HL
  LD (HL), D ; Now the syscall address is at 0xB000

  ; Set syscall count
  LD A, $08
  LD (SYSCALL_COUNT), A

  ; Load kernel flags
  LD HL, KERNEL_FLAGS
  LD (HL), 0 ; Initialize all to 0
  SET 0, (HL) ; Set echo
  RES 1, (HL) ; Set kernel mode(0)

  ; Create process stack at 0xAB00
  LD HL, PROCESS_STACK
  LD (PROCESS_SP), HL

  ; Create OS stack at 0xA500
  LD HL, USER_STACK
  LD (USER_SP), HL

  SWITCH_TO_USER

  ; Initialize BSS
  CALL crt0_init_bss

  ; Create root process
  LD HL, ROOT_PROCESS
  LD A, 5
  CALL $B000

  SWITCH_TO_KERNEL

  POP HL ; Restore old sp
  LD SP, HL
  RET ; Return back to BASIC

ROOT_PROCESS:

  ; Create OS process
  LD HL, _OS_ENTRY
  LD A, 5
  CALL $B000

  ; Exit
  LD BC, 0
  LD A, 0
  CALL $B000

; Important! System calls must be called from user mode
; System Call Argument registers:
; AF - Syscall number
; BC - Syscall argument 1
; DE - Syscall argument 2 
; HL - Syscall argument 3
;-------------
; SYSTEM CALLS
; ------------
;
; 0x00 - SYS_EXIT
;   BC = Exit code
;   Description: Exit to BASIC
;
; 0x01 - SYS_WRITE
;   BC = port
;   DE - length
;   HL - address
;   Description: Write to port($0-$FFFF)
;
; 0x02 - SYS_READ
;   BC = port
;   DE - length
;   HL - address
;   Description: Read from port($0-$FFFF)
;
; 0x03 - SYS_GETS
;   DE - length
;   HL - address
;   Description: Read string from stdin
; 
; 0x04 - SYS_PUTS
;   DE - length
;   HL - address
;   Description: Write string to stdout
;
; 0x05 - SYS_EXEC
;   HL - address
;   Description: Replace current process with new process
;
; 0x06  SYS_GETINFO
;   HL - pointer to buffer
;   Description: Get system information, the buffer should be at least 32 bytes
;
; 0x07 - SYS_RAND
;   HL - pointer to buffer
;   Description: Get random number
;
; 0x08 - SYS_SLEEP
;   BC - sleep time
;   Description: Sleep for BC ms
;
; 0x09 - SYS_FORK
;   HL - pointer to buffer
;   Description: Create a new process
SYSCALL_DISPATCH:

  SWITCH_TO_KERNEL

  ; Check if syscall is valid. We always want to check if something is valid with a jump table.
  PUSH HL
  LD HL, SYSCALL_COUNT
  CP (HL)
  POP HL
  JP NC, SYSCALL_END

  ; Save all registers, syscalls may alter them
  PUSH AF
  PUSH BC
  PUSH DE
  PUSH HL
  PUSH IX
  
  ; Calculate address
  PUSH DE
  PUSH HL
  LD IX, SYSCALL_TABLE
  SLA A ; Multiply by 2
  LD D, 0
  LD E, A
  ADD IX, DE ; Calculated address in IX
  PUSH IX
  POP HL ; IX -> HL
  LD E, (HL) ; Get the syscall address from HL pointer
  INC HL
  LD D, (HL) ; Now the address is in DE
  POP HL
  LD IX, 0
  ADD IX, DE ; IX = syscall address
  POP DE

  JP (IX) ; Execute the syscall


SYSCALL_END:
  ; Restore all registers
  POP IX
  POP HL
  POP DE
  POP BC
  POP AF

  SWITCH_TO_USER

  RET


ECHO_CHAR:
  PUSH HL
  LD HL, KERNEL_FLAGS
  BIT 0, (HL) ; Check if echo is enabled
  POP HL
  CALL NZ, PRINTC ; If enabled print
  RET

SYS_EXIT:
  CALL EXIT_PROCESS
  JP SYSCALL_END

SYS_WRITE:
  L_0: ; Main loop
    XOR A
    CP D
    JR Z, L_1 ; While D > 0, decrement D
    DEC E
    JR Z, L_2 ; Loop ends when length = 0
    L_0_1:
    LD A, (HL)
    OUT (C), A
    INC HL
    JR L_0
  L_1: ; Dec D
    DEC D
    JR L_0_1
  L_2: ; End loop
    JP SYSCALL_END

SYS_READ:
  L_3: ; Main loop
    XOR A
    CP D
    JR Z, L_4 ; While D > 0, decrement D
    DEC E
    JR Z, L_5 ; Loop ends when length = 0
    L_3_1:
    IN A, (C)
    LD (HL), A
    INC HL
    JR L_3
  L_4: ; Dec D
    DEC D
    JR L_3_1
  L_5: ; End loop
    JP SYSCALL_END

SYS_GETS:
  L_6: ; Main loop
    XOR A
    CP D
    JR Z, L_7 ; While D > 0, decrement D
    DEC E
    JR Z, L_8 ; Loop ends when length = 0
    L_6_1:
    CALL READC
    CALL ECHO_CHAR
    CP 0x0D ; Check for enter
    JR Z, L_8 ; If enter, the string is ready
    LD (HL), A
    INC HL
    CP 0x08
    JR Z, L_7_1 ; If backspace, handle it
    JR L_6
  L_7: ; Dec D
    DEC D
    JR L_6_1
  L_7_1: ; Handle backspace
    DEC HL
    CALL PRINTC
    LD (HL), 0
    JR L_6
  L_8: ; End loop
    JP SYSCALL_END


SYS_PUTS:
  L_9: ; Main loop
    XOR A
    CP D
    JR Z, L_10 ; While D > 0, decrement D
    DEC E
    JR Z, L_11 ; Loop ends when length = 0
    L_9_1:
    LD A, (HL)
    CALL PRINTC
    INC HL
    JR L_9
  L_10: ; Dec D
    DEC D
    JR L_9_1
  L_11: ; End loop
    JP SYSCALL_END

SYS_EXEC:
  PUSH HL
  CALL CREATE_PROCESS
  POP HL
  JP (HL) ; Then jump to the entrypoint

SYS_GETINFO:
  EX DE, HL
  LD HL, SYSINFO
  LD BC, 40
  LDIR
  JP SYSCALL_END

SYS_RAND:
  LD A, R ; Get the random number from the refresh register
  LD (HL), A
  JP SYSCALL_END

SYS_SLEEP:
  JP SYSCALL_END


CREATE_PROCESS:
  PUSH AF
  LD A, (PROC_COUNT)
  INC A
  LD (PROC_COUNT), A ; Increment the process count
  POP AF
  CALL PUSH_PROCESS

  SWITCH_TO_USER

  LD HL, (TMP_REG1)
  JP (HL)
  

EXIT_PROCESS:
  LD A, (PROC_COUNT)
  DEC A
  LD (PROC_COUNT), A ; Decrement the process count

  CALL POP_PROCESS ; Pop the process from process stack

  SWITCH_TO_USER

  LD IX, (TMP_REG3) ; Load the return address
  JP (IX) ; Return to the caller

PUSH_PROCESS:

  LD (TMP_REG1), HL ; Save current HL
  LD HL, 0
  ADD HL, SP
  LD (TMP_REG2), HL ; Save current SP

  LD SP, (PROCESS_SP) ; Load process stack pointer

  LD HL, (TMP_REG1) ; Restore HL

  ; Reserve old process registers
  PUSH AF
  PUSH BC
  PUSH DE
  PUSH HL


  LD HL, (USER_SP) ; Get the stack pointer before creating the new process
  LD E, (HL)
  INC HL
  LD D, (HL)
  PUSH DE ; Save the return address
  PUSH HL ; Save the old stack pointer

  LD A, R
  PUSH AF ; Save the PID, exit code is defined on exit

  LD (PROCESS_SP), SP ; Save SP

  ; So the stack looks like this:
  ; | old AF | old BC | old DE | old HL | return address | old SP | PID | exit code |
  
  LD SP, (TMP_REG2) ; Restore the old stack pointer
  RET


POP_PROCESS: ; Returns: AF, BC, DE, HL, SP, TMP3(Return address)
  LD HL, 0
  ADD HL, SP
  LD (TMP_REG1), HL ; Save kernel SP

  LD SP, (PROCESS_SP) ; Load process stack pointer

  POP AF ; Clear stack

  POP HL ; Now the old stack pointer is in HL
  LD (USER_SP), HL ; Set the user stack pointer to the just popped one

  POP HL ; Return address in HL
  LD (TMP_REG3), HL

  ; Pop the registers
  POP HL
  POP DE
  POP BC
  POP AF

  LD (PROCESS_SP), SP ; Save SP

  LD SP, (TMP_REG1) ; Restore the kernel sp
  RET


; Import from drivers

  EXTERN READC
  EXTERN PRINTC

SECTION DATA
SYSCALL_TABLE:

  dw SYS_EXIT
  dw SYS_WRITE
  dw SYS_READ
  dw SYS_GETS
  dw SYS_PUTS
  dw SYS_EXEC
  dw SYS_GETINFO
  dw SYS_RAND
  dw SYS_SLEEP


SYSINFO:
  db "Manux    Z80-PC   0.1      alpha    Z80     ", 0

MSG:
  db "Hellord", 0DH, 0AH, 0
