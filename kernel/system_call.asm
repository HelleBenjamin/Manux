; SPDX-License-Identifier: GPL-2.0-or-later
; Copyright (c) 2025 Benjamin Helle
;
; system_call.asm
; Assembly system calls

INCLUDE "kernel/kernel.inc"
SECTION code_home
  
  PUBLIC SYSCALL_DISPATCH

  EXTERN EXIT_PROCESS
  EXTERN CREATE_PROCESS
  EXTERN GET_PROCESS_ID
  EXTERN PUSH_PROCESS
  EXTERN POP_PROCESS

  EXTERN TRANSMIT_CHAR
  EXTERN RECEIVE_CHAR

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
;   Description: Exit current process
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
;   Description: Clone current process to new process
;
; 0x0A - SYS_GETPID
;   HL - pointer to buffer
;   Description: Get current process id
;
; 0x0B - SYS_GETPCOUNT
;   HL - pointer to buffer
;   Description: Get process count
;

SYSCALL_DISPATCH:

  LD (USER_SP), SP
  LD SP, (KERNEL_SP)
  PUSH HL
  LD HL, KERNEL_FLAGS
  RES 1, (HL)
  POP HL

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
  
  ; Calculate address
  LD (TMP_REG1), HL ; Save HL
  PUSH DE
  LD HL, SYSCALL_TABLE
  SLA A ; Multiply by 2
  LD D, 0
  LD E, A
  ADD HL, DE ; Calculated address in HL
  LD E, (HL) ; Get the syscall address from HL pointer
  INC HL
  LD D, (HL) ; Now the address is in DE
  LD HL, 0
  ADD HL, DE ; HL = syscall address
  POP DE
  
  JP (HL) ; Execute the syscall

GET_HL_SYSCALL:
  LD HL, (TMP_REG1)
  RET

SYSCALL_END:
  ; Restore all registers
  POP HL
  POP DE
  POP BC
  POP AF

  ; Switch to usermode
  PUSH HL
  LD HL, KERNEL_FLAGS
  SET 1, (HL)
  POP HL
  LD SP, (USER_SP)

  RET


ECHO_CHAR:
  PUSH HL
  LD HL, KERNEL_FLAGS
  BIT 0, (HL) ; Check if echo is enabled
  POP HL
  CALL NZ, TRANSMIT_CHAR ; If enabled print
  RET

SYS_EXIT:
  CALL EXIT_PROCESS
  JP SYSCALL_END

SYS_WRITE:
  CALL GET_HL_SYSCALL
  SYS_WRITE_LOOP: ; Main loop
    LD A, (HL)
    OUT (C), A
    INC HL
    XOR A
    DEC DE
    CP E
    JR Z, SYS_WRITE_END ; Loop ends when length = 0
    JR SYS_WRITE_LOOP
  SYS_WRITE_END: ; End loop
    JP SYSCALL_END

SYS_READ:
  CALL GET_HL_SYSCALL
  SYS_READ_LOOP: ; Main loop
    IN A, (C)
    LD (HL), A
    INC HL
    XOR A
    DEC DE
    CP E
    JR Z, SYS_READ_END ; Loop ends when length = 0
    JR SYS_READ_LOOP
  SYS_READ_END: ; End loop
    JP SYSCALL_END

SYS_GETS:
  CALL GET_HL_SYSCALL
  SYS_GETS_LOOP: ; Main loop
    CALL RECEIVE_CHAR
    CALL ECHO_CHAR
    CP 0x0D ; Check for enter
    JR Z, SYS_GETS_END ; If enter, the string is ready
    LD (HL), A
    INC HL
    CP 0x7F
    JR Z, SYS_GETS_BCKSP ; Sometimes the terminal emulator is configured to output backspace as 0x7F(DEL in ascii)
    CP 0x08
    JR Z, SYS_GETS_BCKSP ; Default backspace
    XOR A
    DEC DE
    CP E
    JR Z, SYS_GETS_END ; Exit when DE is zero
    JR SYS_GETS_LOOP
  SYS_GETS_BCKSP: ; Handle backspace
    DEC HL
    DEC HL
    LD (HL), 0
    INC DE
    JR SYS_GETS_LOOP
  SYS_GETS_END: ; End loop
    JP SYSCALL_END


SYS_PUTS:
  CALL GET_HL_SYSCALL
  SYS_PUTS_LOOP: ; Main loop
    LD A, (HL)
    CALL TRANSMIT_CHAR
    INC HL
    XOR A
    DEC DE
    CP E
    JR Z, SYS_PUTS_END ; Exit when DE is zero
    JR SYS_PUTS_LOOP
  SYS_PUTS_END: ; End loop
    JP SYSCALL_END

SYS_EXEC: ; Executes the program at the address in HL

  LD HL, KERNEL_FLAGS
  SET 1, (HL)
  LD SP, (USER_SP)

  CALL GET_HL_SYSCALL

  JP (HL)

SYS_GETINFO:
  CALL GET_HL_SYSCALL
  EX DE, HL
  LD HL, SYSINFO
  LD BC, 40
  LDIR
  JP SYSCALL_END

SYS_RAND:
  CALL GET_HL_SYSCALL
  LD A, R ; Get the random number from the refresh register
  LD (HL), A
  JP SYSCALL_END

SYS_SLEEP:
  SYS_SLEEP_LOOP:

  SYS_SLEEP_END:
    JP SYSCALL_END

SYS_FORK: ; Clones the process but does not execute
  CALL GET_HL_SYSCALL
  CALL CREATE_PROCESS
  JP SYSCALL_END

SYS_GETPID:
  CALL GET_HL_SYSCALL
  CALL GET_PROCESS_ID
  LD (HL), A
  JP SYSCALL_END

SYS_GETPCOUNT:
  CALL GET_HL_SYSCALL
  LD A, (PROC_COUNT)
  LD (HL), A
  JP SYSCALL_END


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
  dw SYS_FORK
  dw SYS_GETPID
  dw SYS_GETPCOUNT