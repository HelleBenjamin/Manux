; SPDX-License-Identifier: GPL-2.0-or-later
; Copyright (c) 2025 Benjamin Helle
;
; system_call.s
; Assembly system calls

INCLUDE "kernel/kernel.inc"
SECTION CODE
  
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
; 0x0C - SYS_GETSYSMEM
;   HL - pointer to buffer
;   Description: Get whole system memory, like memtest
;
; 0x0D - SYS_GETUSEDMEM
;   HL - pointer to buffer
;   Description: Get used memory(used memory = initial user sp - current user sp)

SYSCALL_DISPATCH:

  LD (USER_SP), SP
  LD SP, (KERNEL_SP)
  PUSH HL
  LD HL, KERNEL_FLAGS
  RES 1, (HL)
  POP HL

  ; Check if syscall is valid. We always want to check if something is valid with a jump table.
  ; Fix this :)
  ;PUSH HL
  ;LD HL, SYSCALL_COUNT
  ;CP (HL)
  ;POP HL
  ;JP C, SYSCALL_END

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

  ; It would be better to use HL instead of IX for speed, will be added later. Or just push the address to the stack and use ret
  JP (IX) ; Execute the syscall


SYSCALL_END:
  ; Restore all registers
  POP IX
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
    CALL RECEIVE_CHAR
    CALL ECHO_CHAR
    CP 0x0D ; Check for enter
    JR Z, L_8 ; If enter, the string is ready
    LD (HL), A
    INC HL
    CP 0x7F
    JR Z, L_7_1 ; Sometimes the terminal emulator is configured to output backspace as 0x7F(DEL in ascii)
    CP 0x08
    JR Z, L_7_1 ; Default backspace
    JR L_6
  L_7: ; Dec D
    DEC D
    JR L_6_1
  L_7_1: ; Handle backspace
    DEC HL
    DEC HL
    LD (HL), 0
    INC DE
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
    CALL TRANSMIT_CHAR
    INC HL
    JR L_9
  L_10: ; Dec D
    DEC D
    JR L_9_1
  L_11: ; End loop
    JP SYSCALL_END

SYS_EXEC: ; Executes the program at the address in HL

  PUSH HL
  LD HL, KERNEL_FLAGS
  SET 1, (HL)
  POP HL
  LD SP, (USER_SP)

  JP (HL)

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

SYS_FORK: ; Clones the process but does not execute
  CALL CREATE_PROCESS
  JP SYSCALL_END

SYS_GETPID:
  CALL GET_PROCESS_ID
  LD (HL), A
  JP SYSCALL_END

SYS_GETPCOUNT:
  LD A, (PROC_COUNT)
  LD (HL), A
  JP SYSCALL_END

SYS_GETMEM:
  JP SYSCALL_END

SYS_GETUSEDMEM:

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