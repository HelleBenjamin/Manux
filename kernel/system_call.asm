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
  EXTERN _create_process
  EXTERN WRITE_FILE
  EXTERN READ_FILE

  EXTERN TRANSMIT_CHAR
  EXTERN RECEIVE_CHAR

  EXTERN REG_DUMP
  EXTERN STACKTRACE
  EXTERN _get_file_blockptr

; Important! System calls must be called from user mode
; System Call Argument registers:
; AF - Syscall number
; BC - Syscall argument 3
; DE - Syscall argument 2 
; HL - Syscall argument 1
; -- Syscall return value is in HL
;-------------
; SYSTEM CALLS
; ------------
;
; 0x00 - SYS_EXIT
;   HL = Exit code
;   Description: Exit current process
;
; 0x01 - SYS_WRITE
;   BC = file descriptor
;   DE - count
;   HL - buffer
;   Description: Write to a file
;
; 0x02 - SYS_READ
;   BC = file descriptor
;   DE - count
;   HL - buffer
;   Description: Read from a file
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
;   Description: Return a random number in HL
;
; 0x08 - SYS_SLEEP
;   HL - sleep time
;   Description: Sleep for HL ms
;
; 0x09 - SYS_FORK
;   Description: Clone current process to new process
;
; 0x0A - SYS_GETPID
;   Description: Get current process id, returns in HL
;
; 0x0B - SYS_GETPCOUNT
;   Description: Get process count, returns in HL
;
; 0x0C - SYS_OPEN
;   DE - filename
;   Description: Open a file, returns file descriptor in HL
;
; 0x0D - SYS_CLOSE
;   HL - file descriptor
;   Description: Close a file descriptor
;
; 0x0E - SYS_CREATE
;   HL - filename
;   Description: Create a file
;
; 0x0F - SYS_EXECS
;   DE - filename
;   HL - argument pointer
;   Description: Execute a file with single argument

SYSCALL_DISPATCH:
  ; Switch to kernelspace
  LD (USER_SP), SP
  LD SP, (KERNEL_SP)

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
  PUSH DE ; Save DE
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
  POP DE ; Restore DE
  
  JP (HL) ; Execute the syscall

GET_HL_SYSCALL:
  LD HL, (TMP_REG1)
  RET

SAVE_RET:
  LD (TMP_REG2), HL ; Save return value
  RET

SYSCALL_END:
  ; Restore all registers
  POP HL
  POP DE
  POP BC
  POP AF

  LD HL, (TMP_REG2) ; Return value
  SYSCALL_END_SKIP: ; Skip popping the registers

  ; Switch to userspace
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
  CALL GET_HL_SYSCALL ; Get exit code
  LD (EXIT_CODE), HL ; Save exit code
  CALL EXIT_PROCESS
  JP SYSCALL_END_SKIP

SYS_WRITE:
  EXTERN _sysc_write
  CALL GET_HL_SYSCALL
  PUSH BC ; Push args
  PUSH DE
  PUSH HL
  CALL _sysc_write ; Call C function
  POP HL ; Cleanup
  POP DE
  POP BC
  SYS_WRITE_END: ; End loop
    JP SYSCALL_END

SYS_READ:
  EXTERN _sysc_read
  CALL GET_HL_SYSCALL
  PUSH BC ; Push args
  PUSH DE
  PUSH HL
  CALL _sysc_read ; Call C function
  POP HL ; Cleanup
  POP DE
  POP BC
  SYS_READ_END: ; End loop
    JP SYSCALL_END

SYS_GETS: ; Buffer overflow safe gets
  CALL GET_HL_SYSCALL
  SYS_GETS_LOOP: ; Main loop
    CALL RECEIVE_CHAR
    CALL ECHO_CHAR
    CP 0x0D ; Check for enter
    JR Z, SYS_GETS_END ; If enter, the string is ready
    CP 0x0A ; Check for enter 2
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
  CALL GET_HL_SYSCALL ; Get HL
  LD (TMP_REG3), SP ; Save current SP
  LD SP, (USER_SP)
  POP BC ; Pop old return address
  PUSH HL ; Push new return address
  LD SP, (TMP_REG3) ; Restore old SP so we can restore registers
  JP SYSCALL_END

SYS_GETINFO:
  CALL GET_HL_SYSCALL
  EX DE, HL
  LD HL, SYSINFO
  LD BC, 40
  LDIR
  JP SYSCALL_END

SYS_RAND:
  LD A, R ; Get the random number from the refresh register
  LD L, A ; Store it in L
  LD A, R
  XOR L ; XOR it with the previous value
  LD H, A ; Store it in H
  CALL SAVE_RET ; Save the return value
  JP SYSCALL_END

SYS_SLEEP:
  SYS_SLEEP_LOOP:

  SYS_SLEEP_END:
    JP SYSCALL_END

SYS_FORK: ; Clones the process but does not execute
  CALL GET_HL_SYSCALL ; Get HL for saving its state in the process stack
  CALL CREATE_PROCESS
  JP SYSCALL_END

SYS_GETPID:
  CALL GET_HL_SYSCALL
  CALL GET_PROCESS_ID ; Get the process ID
  LD L, A ; Store it in L
  LD H, 0 ; Set high byte to 0
  CALL SAVE_RET
  JP SYSCALL_END

SYS_GETPCOUNT:
  CALL GET_HL_SYSCALL
  LD HL, (PROC_COUNT)
  CALL SAVE_RET
  JP SYSCALL_END

SYS_OPEN:
  EXTERN _fd_create
  CALL GET_HL_SYSCALL
  CALL _fd_create ; Call C function
  LD H, 0
  CALL SAVE_RET ; (H)L = file descriptor number
  JP SYSCALL_END

SYS_CLOSE:
  EXTERN _fd_close
  CALL GET_HL_SYSCALL
  CALL _fd_close ; Call C function
  LD H, 0
  CALL SAVE_RET ; (H)L = error code
  JP SYSCALL_END

SYS_CREATE:
  EXTERN _fd_create
  CALL GET_HL_SYSCALL
  CALL _fd_create ; Call C function
  LD H, 0
  CALL SAVE_RET ; (H)L = error code
  JP SYSCALL_END

SYS_EXECS:
  ; Needs to be tested
  CALL GET_HL_SYSCALL ; Get HL
  EX HL, DE ; Get the filename pointer in HL, HL = filename, DE = argument pointer
  CALL _get_file_blockptr ; Get the file block pointer, should return address in HL
  LD A, H ; Check if null
  OR L
  JP Z, SYS_EXECS_FAIL ; If not found, return
  LD (TMP_REG3), SP ; Save current SP
  LD SP, (USER_SP)
  LD BC, 4 ; Skip the first 4 bytes of the file block(header)
  ADD HL, BC ; HL = new return address
  POP BC ; Pop old return address
  PUSH DE ; Push the argument
  PUSH HL ; Push new return address
  LD (USER_SP), SP ; Save new SP
  LD SP, (TMP_REG3) ; Restore old SP so we can restore registers
  JP SYSCALL_END
SYS_EXECS_FAIL:
  LD HL, 0x0001 ; Set error
  CALL SAVE_RET ; Save return value
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
  dw SYS_OPEN
  dw SYS_CLOSE
  dw SYS_CREATE
  dw SYS_EXECS