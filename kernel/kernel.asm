
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

KERNEL_WORKSPACE EQU $B000

KERNEL_SP EQU KERNEL_WORKSPACE+2
USER_SP EQU KERNEL_WORKSPACE+4
SYSCALL_COUNT EQU KERNEL_WORKSPACE+6
KERNEL_FLAGS EQU KERNEL_WORKSPACE+8
PROCESS_COUNT EQU KERNEL_WORKSPACE+10
MAX_PROCESS_COUNT EQU 5
CURRENT_PROCESS EQU KERNEL_WORKSPACE+14
PROCESS_LIST EQU KERNEL_WORKSPACE+54 ; Reserve space for process list

; Process offsets
PROC_RETLO EQU 0 ; Return address
PROC_RETHI EQU 1
PROC_STATE EQU 2
PROC_ID EQU 3
PROC_EXIT_CODE EQU 4
PROC_PARENT EQU 5 ; Parent process
PROC_ADDR_LO EQU 6 ; Where the process code starts
PROC_ADDR_HI EQU 7

; Process states
STATE_STOPPED EQU 0
STATE_RUNNING EQU 1
STATE_ERROR EQU 2
STATE_EXITED EQU 3

KERNEL_STACK EQU $AF00
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
  LD A, $0A
  LD (SYSCALL_COUNT), A

  ; Load kernel flags
  LD HL, KERNEL_FLAGS
  LD (HL), 0 ; Initialize all to 0
  SET 0, (HL) ; Set echo
  RES 1, (HL) ; Set kernel mode(0)

  ; Set process count
  LD HL, PROCESS_COUNT
  LD (HL), 0

  ; Set max process count
  LD HL, MAX_PROCESS_COUNT
  LD (HL), 5 ; Maximum of 5 processes

  ; Create OS stack at 0xA500
  LD SP, USER_STACK
  LD (USER_SP), SP
  LD SP, (KERNEL_SP)

  CALL CREATE_ROOT_PROCESS

  POP HL ; Restore old sp
  LD SP, HL
  RET ; Return back to BASIC

ROOT_PROCESS:
  SWITCH_TO_USER
  CALL crt0_init_bss

  LD HL, _OS_ENTRY
  LD A, 0x05
  CALL $B000 ; Create process
  SWITCH_TO_KERNEL
  RET


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
;   Description: Execute program at address HL
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
; 0x09 - SYS_GETPID
;   HL - pointer to buffer
;   Description: Get current process id
;
; 0x0A - SYS_FORK
;   none
;   Description: Create a new process from the current process


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
  CALL CREATE_PROCESS

  JP (HL) ; Then jump to the entrypoint

SYS_GETINFO:
  EX DE, HL
  LD HL, SYSINFO
  LD BC, 40
  LDIR
  JP SYSCALL_END

SYS_RAND:
  LD A, R ; Get the random number from refresh register
  LD (HL), A
  JP SYSCALL_END

SYS_SLEEP:
  JP SYSCALL_END

SYS_GETPID:
  LD A, (CURRENT_PROCESS)
  LD (HL), A
  JP SYSCALL_END

SYS_FORK:
  ; Create new process cloned from current process
  CALL FIND_FREE_PROCESS_SLOT
  CP 1
  JP Z, SYSCALL_END ; If no free process slot, return

  LD (HL), E
  INC HL
  LD (HL), D ; Now the process return address is saved in the process table

  INC A
  LD (PROCESS_COUNT), A

  INC HL
  LD A, STATE_RUNNING
  LD (HL), A ; Now the process state is set to running

  LD A, R ; Get new unique pid
  INC HL
  LD (HL), A ; Now the process pid is saved in the process table

  ADD HL, 2
  LD A, (CURRENT_PROCESS)
  LD (HL), A ; Now the parent pid is saved

  LD (CURRENT_PROCESS), A ; Set current process

  JP SYSCALL_END

FIND_FREE_PROCESS_SLOT:
  LD HL, PROCESS_LIST ; Get the base
  LD A, (MAX_PROCESS_COUNT)
  LD C, A
  LOOP_F:
    DEC C
    JR Z, END_F
    LD A, (HL)
    CP STATE_EXITED
    JZ FOUND_FREE_PROCESS
    ADD HL, 8
    JR LOOP_F
  FOUND_FREE_PROCESS:
    LD A, 0 ; Success
    RET ; HL = free process slot
  END_F:
    LD A, 1 ; Failure
    RET

FIND_PROCESS: ; Find a process, B = pid, HL = return address
  LD HL, PROCESS_LIST ; Get the base
  LD A, (MAX_PROCESS_COUNT)
  LD C, A
  LOOP_P:
    DEC C
    JR Z, END_P
    ADD HL, PROC_ID
    LD A, (HL)
    CP B
    JR Z, FOUND_PROCESS
    ADD HL, 8
    JR LOOP_P
  FOUND_PROCESS:
    LD A, 0 ; Success
    RET ; HL = process slot
  END_P:
    LD A, 1 ; Failure
    RET

CREATE_PROCESS:
  PUSH HL ; Save entrypoint
  CALL FIND_FREE_PROCESS_SLOT
  CP 1
  JP Z, CREATE_PROCESS_END_FAIL ; If no free process slot, return
  PUSH HL ; Save process slot

  LD HL, (USER_SP) ; Get the return address from user stack
  LD E, (HL) ; Get low byte
  INC HL
  LD D, (HL) ; Get high byte
  ; Now the process return address is in DE

  POP HL
  LD (HL), E
  INC HL
  LD (HL), D ; Now the process return address is saved in the process table

  LD A, (PROCESS_COUNT)
  INC A
  LD (PROCESS_COUNT), A ; Increment process count

  INC HL
  LD A, STATE_RUNNING
  LD (HL), A ; Now the process state is set to running

  LD A, R ; Get new unique pid
  INC HL
  LD (HL), A ; Now the process pid is saved in the process table

  ADD HL, 2
  LD A, (CURRENT_PROCESS)
  LD (HL), A ; Now the parent pid is saved

  LD (CURRENT_PROCESS), A ; Set current process

  POP BC
  INC HL
  LD (HL), C
  INC HL
  LD (HL), B ; Now the process entrypoint is saved in the process table

  PUSH BC
  POP HL ; HL = entrypoint

  CREATE_PROCESS_END_SUCCESS:
    LD A, 0 ; Success
    RET

  CREATE_PROCESS_END_FAIL:
    LD A, 1 ; Failure
    ADD SP, 2 ; Stack cleanup
    RET

CREATE_ROOT_PROCESS:
  CALL FIND_FREE_PROCESS_SLOT
  CP 1
  JP Z, CREATE_ROOT_PROCESS_END_FAIL ; If no free process slot, return
  PUSH HL ; Save process slot

  LD HL, 4 ; Get the return address
  ADD HL, SP
  LD E, (HL) ; Get low byte
  INC HL
  LD D, (HL) ; Get high byte
  ; Now the process return address is in DE

  POP HL
  LD (HL), E
  INC HL
  LD (HL), D ; Now the process return address is saved in the process table

  LD A, (PROCESS_COUNT)
  INC A
  LD (PROCESS_COUNT), A ; Increment process count

  INC HL
  LD A, STATE_RUNNING
  LD (HL), A ; Now the process state is set to running

  LD A, 0 ; Set root pid
  INC HL
  LD (HL), A ; Now the process pid is saved in the process table

  ADD HL, 2
  LD A, (CURRENT_PROCESS)
  LD (HL), A ; Now the parent pid is saved

  LD (CURRENT_PROCESS), A ; Set current process

  LD BC, ROOT_PROCESS
  INC HL
  LD (HL), C
  INC HL
  LD (HL), B ; Now the root entrypoint is saved in the process table

  PUSH BC
  POP HL ; HL = entrypoint

  CREATE_ROOT_PROCESS_END_SUCCESS:
    JP ROOT_PROCESS
    RET

  CREATE_ROOT_PROCESS_END_FAIL:
    LD A, 1 ; Failure
    ADD SP, 2 ; Stack cleanup
    RET

EXIT_PROCESS: ; Exit current process
  LD A, (CURRENT_PROCESS)
  CALL FIND_PROCESS ; Get current process

  LD E, (HL)
  INC HL
  LD D, (HL) ; Get the return address

  INC HL
  LD A, STATE_EXITED
  LD (HL), A ; Now the process state is set to exited
  INC HL
  LD A, (HL) ; Get parent pid

  CALL SET_CURRENT_PROCESS_BY_PID

  SWITCH_TO_USER

  PUSH DE 
  RET ; Return to the parent

SET_CURRENT_PROCESS_BY_PID: ; Set current process by pid, B = pid
  PUSH AF
  PUSH BC
  LD A, (CURRENT_PROCESS)
  LD B, A
  CALL FIND_PROCESS ; Get current process

  ADD HL, 3
  LD A, STATE_STOPPED
  LD (HL), A ; Now the process state is set to stopped

  POP BC
  CALL FIND_PROCESS
  CP 0
  JR Z, SET_CURRENT_PROCESS_BY_PID_END

  LD A, B
  LD (CURRENT_PROCESS), A

  SET_CURRENT_PROCESS_BY_PID_END:
    POP AF
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
  dw SYS_GETPID
  dw SYS_FORK

SYSINFO:
  db "Manux    Z80-PC   0.1      alpha    Z80     ", 0

MSG:
  db "Hello from the kernel", 0DH, 0AH, 0

