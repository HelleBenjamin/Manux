; SPDX-License-Identifier: GPL-2.0-only
; Copyright (c) 2025-2026 Benjamin Helle
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

  EXTERN REG_DUMP
  EXTERN STACKTRACE
  EXTERN _get_file_blockptr

; Important! System calls must be called from user mode
; System Call Argument registers:
; HL - Syscall argument 1
; DE - Syscall argument 2
; BC - Syscall argument 3
; A  - Syscall number
; Syscall return value is in HL
;-------------
; SYSTEM CALLS
;-------------
;
; 0x00 - SYS_EXIT
;   HL = Exit code
;   Description: Exit to shell
;
; 0x01 - SYS_WRITE
;   HL = file descriptor
;   DE - count
;   BC - buffer
;   Description: Write to a file
;
; 0x02 - SYS_READ
;   HL = file descriptor
;   DE - count
;   BC - buffer
;   Description: Read from a file
;
; 0x03 - SYS_GETS
;   HL - buffer
;   DE - length
;   Description: Read string from stdin
; 
; 0x04 - SYS_PUTS
;   HL - buffer
;   DE - length
;   Description: Write string to stdout
;
; 0x05 - SYS_PUTH
;   HL - hex number
;   Description: Print unsigned number as hex
;
; 0x06  SYS_GETINFO
;   HL - pointer to buffer
;   Description: Get system information, the buffer should be at least 32 bytes
;
; 0x07 - SYS_RAND
;   Description: Return a random number in HL
;
; 0x08 - SYS_OPEN
;   HL - filename
;   DE - flags
;   Description: Open a file, returns file descriptor in HL
;
; 0x09 - SYS_CLOSE
;   HL - file descriptor
;   Description: Close a file descriptor
;
; 0x0A - SYS_SEEK
;   HL - file descriptor
;   DE - offset
;   BC - whence
;   Description: Seek in a file
;
; 0x0B - SYS_EXEC
;   HL - filename
;   DE - argument pointer
;   Description: Execute a file with arguments
;
; 0x0C - SYS_LIST
;   HL - buffer
;   Description: List directory, returns number of files in HL
;
; 0x0D - SYS_FILESIZE
;   HL - filename
;   Description: Get file size, returns size in HL
;
; 0x0E - SYS_REMOVE
;   HL - filename
;   Description: Remove a file

  PUBLIC _z80_rst_20h
_z80_rst_20h: ; Set syscall dispatch to rst 0x20
SYSCALL_DISPATCH:
  ; Switch to kernel stack
  LD (SAVED_SP), SP
  LD SP, (KERNEL_SP)

  ; Check if syscall is valid. We always want to check if something is valid with a jump table.
  PUSH HL
  PUSH AF
  LD L, A
  LD A, SYSCALL_COUNT
  CP L
  JP C, INVALID_SYSCALL
  POP AF ; If valid, restore AF and HL
  POP HL

  ; Save all registers, syscalls may alter them
  PUSH AF
  PUSH BC
  PUSH DE
  PUSH HL
  PUSH IX
  PUSH IY
  
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

INVALID_SYSCALL:
  POP AF ; Restore previous registers
  POP HL
  LD HL, 2 ; Set error code, 2 = invalid syscall
  LD SP, (SAVED_SP)
  RET

GET_HL_SYSCALL:
  LD HL, (TMP_REG1)
  RET

SAVE_RET:
  LD (SYSCALL_RET), HL ; Save return value
  RET

SYSCALL_TABLE:
  dw SYS_EXIT     ; 0
  dw SYS_WRITE    ; 1
  dw SYS_READ     ; 2
  dw SYS_GETS     ; 3
  dw SYS_PUTS     ; 4
  dw SYS_PUTH     ; 5
  dw SYS_GETINFO  ; 6
  dw SYS_RAND     ; 7
  dw SYS_OPEN     ; 8
  dw SYS_CLOSE    ; 9
  dw SYS_SEEK     ; 10
  dw SYS_EXECV    ; 11
  dw SYS_LIST     ; 12
  dw SYS_FILESIZE ; 13
  dw SYS_REMOVE   ; 14

SYSCALL_END:
  ; Restore all registers
  POP IY
  POP IX
  POP HL
  POP DE
  POP BC
  POP AF

  LD HL, (SYSCALL_RET) ; Return value
  SYSCALL_END_SKIP: ; Skip popping the registers

  ; Switch to userspace
  LD (KERNEL_SP), SP
  LD SP, (SAVED_SP)

  RET

SYSCALL_END_NO_RET: ; No return value
  ; Restore all registers
  POP IY
  POP IX
  POP HL
  POP DE
  POP BC
  POP AF

  ; Switch to userspace
  LD (KERNEL_SP), SP
  LD SP, (SAVED_SP)

  RET

ECHO_CHAR:
  PUSH HL
  LD HL, KERNEL_FLAGS
  BIT 0, (HL) ; Check if echo is enabled
  POP HL
  JR Z, SKIP_ECHO
  RST 0x08 ; If enabled print
SKIP_ECHO:
  RET


SYS_EXIT:
  ; ARGS:
  ;   HL = code
  ; RETURNS: none
  ; Returns to shell
  LD HL, (SHELL_SP)
  LD (SAVED_SP), HL
  CALL GET_HL_SYSCALL
  CALL SAVE_RET
  JP SYSCALL_END_NO_RET

SYS_WRITE:
  ; ARGS:
  ;   HL = file descriptor
  ;   DE - count
  ;   BC - buffer
  ; RETURNS: code in HL
  EXTERN _sysc_write
  CALL GET_HL_SYSCALL
  ; Push args
  PUSH BC
  PUSH DE
  PUSH HL
  CALL _sysc_write ; Call the C function
  CALL SAVE_RET
  ; Cleanup
  POP HL
  POP DE
  POP BC
  JP SYSCALL_END

SYS_READ:
  ; ARGS:
  ;   HL = file descriptor
  ;   DE - count
  ;   BC - buffer
  ; RETURNS: code in HL
  EXTERN _sysc_read
  CALL GET_HL_SYSCALL
  ; Push args
  PUSH BC
  PUSH DE
  PUSH HL
  CALL _sysc_read ; Call the C function
  CALL SAVE_RET
  ; Cleanup
  POP HL
  POP DE
  POP BC
  JP SYSCALL_END

SYS_GETS: ; Buffer overflow safe get string
  ; ARGS:
  ;   HL = buffer
  ;   DE - length
  ; RETURNS: none
  CALL GET_HL_SYSCALL
  SYS_GETS_LOOP: ; Main loop
    RST 0x10
    CALL ECHO_CHAR
    CP 0x0D ; Check for newline
    JR Z, SYS_GETS_END ; If enter, the string is ready
    CP 0x0A ; Check for another newline format
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
    JP SYSCALL_END_NO_RET


SYS_PUTS:
  ; ARGS:
  ;   HL = buffer
  ;   DE - length
  ; RETURNS: none
  CALL GET_HL_SYSCALL
  SYS_PUTS_LOOP: ; Main loop
    LD A, (HL)
    RST 0x08
    INC HL
    XOR A
    DEC DE
    CP E
    JR Z, SYS_PUTS_END ; Exit when DE is zero
    JR SYS_PUTS_LOOP
  SYS_PUTS_END: ; End loop
    JP SYSCALL_END_NO_RET

SYS_PUTH:
  ; ARGS:
  ;   HL = value
  ; RETURNS: none
  EXTERN _kputh
  CALL GET_HL_SYSCALL
  CALL _kputh
  JP SYSCALL_END_NO_RET

SYS_GETINFO:
  ; ARGS:
  ;   HL = buffer
  ; RETURNS: none
  CALL GET_HL_SYSCALL
  EX DE, HL
  LD HL, SYSINFO
  LD BC, 45 ; correct size?
  LDIR
  JP SYSCALL_END_NO_RET

SYS_RAND:
  ; ARGS:
  ;   none
  ; RETURNS: random number in HL
  LD A, R ; Get the random number from the refresh register
  LD L, A ; Store it in L
  LD A, R
  XOR L ; XOR it with the previous value
  LD H, A ; Store it in H
  CALL SAVE_RET ; Save the return value
  JP SYSCALL_END

SYS_OPEN:
  ; ARGS:
  ;   HL = filename
  ;   DE = flags
  ; RETURNS: file descriptor in HL
  EXTERN _mfs_open
  CALL GET_HL_SYSCALL
  PUSH DE
  PUSH HL
  CALL _mfs_open ; Call C function
  POP DE ; cleanup
  POP DE
  CALL SAVE_RET ; HL = file descriptor number
  JP SYSCALL_END

SYS_CLOSE:
  ; ARGS:
  ;   HL = file descriptor
  ; RETURNS: error code in HL
  EXTERN _fd_close
  CALL GET_HL_SYSCALL
  CALL _fd_close ; Call C function
  CALL SAVE_RET ; HL = error code
  JP SYSCALL_END

SYS_SEEK:
  ; ARGS:
  ;   HL = file descriptor
  ;   DE = offset
  ;   BC = whence
  ; RETURNS: error code in HL
  EXTERN _mfs_seek
  CALL GET_HL_SYSCALL
  PUSH BC
  PUSH DE
  PUSH HL
  CALL _mfs_seek ; Call C function
  POP DE
  POP DE
  POP DE
  CALL SAVE_RET ; HL = error code
  JP SYSCALL_END

SYS_EXECV:
  ; ARGS:
  ;   HL = filename
  ;   DE = argument pointer
  ; RETURNS: error code in HL
  ; Saves the return address(shell)
  EXTERN _execv
  LD HL, (SAVED_SP) ; shell stack pointer
  LD (SHELL_SP), HL
  CALL GET_HL_SYSCALL
  PUSH DE
  PUSH HL
  CALL _execv
  CALL SAVE_RET
  POP DE
  POP DE
  SCF
  CCF ; set carry to 0
  LD DE, 0xFFFF ; check if error(-1)
  SBC HL, DE
  JP Z, SYSCALL_END
  ; replace the return address with 0x4100, and set SP to USER_SP
  LD (TMP_REG1), SP
  LD HL, USER_STACK
  LD SP, HL
  LD HL, 0x4100 ; push the return address
  PUSH HL
  LD (SAVED_SP), SP
  LD SP, (TMP_REG1)
  ; clean stack, no need to reserve registers for the new program
  POP HL
  POP HL
  POP HL
  POP HL
  POP HL
  POP HL
  ; set HL and BC to argv and argc
  LD BC, (0x400A) ; argc, points to PIH_ARGC
  LD HL, 0x400C ; argv, points to PIH_ARGV
  JP SYSCALL_END_SKIP

SYS_LIST:
  ; ARGS:
  ;   HL = buffer
  ; RETURNS: number of files in HL
  EXTERN _mfs_list
  CALL GET_HL_SYSCALL
  CALL _mfs_list
  CALL SAVE_RET
  JP SYSCALL_END

SYS_FILESIZE:
  ; ARGS:
  ;   HL = filename
  ; RETURNS: filesize in HL
  EXTERN _mfs_filesize
  CALL GET_HL_SYSCALL
  CALL _mfs_filesize
  CALL SAVE_RET
  JP SYSCALL_END

SYS_REMOVE:
  ; ARGS:
  ;   HL = filename
  ; RETURNS: code in HL
  EXTERN _mfs_delete
  CALL GET_HL_SYSCALL
  CALL _mfs_delete
  CALL SAVE_RET
  JP SYSCALL_END