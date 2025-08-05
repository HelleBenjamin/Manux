; SPDX-License-Identifier: GPL-2.0-or-later
; Copyright (c) 2025 Benjamin Helle

  INCLUDE "kernel.inc"
SECTION code_home

  PUBLIC CREATE_PROCESS
  PUBLIC EXIT_PROCESS
  PUBLIC GET_PROCESS_ID
  PUBLIC PUSH_PROCESS
  PUBLIC POP_PROCESS
  
CREATE_PROCESS:
  PUSH HL ; Save HL
  PUSH AF ; Save AF
  LD HL, PROC_COUNT
  LD A, MAX_PROCESSES
  CP (HL)
  JR Z, CREATE_PROCESS_END ; If process count is at max, return
  INC (HL) ; Else increment
  CREATE_PROCESS_END:
  POP AF ; Restore AF
  POP HL ; Restore HL

  CALL NZ, PUSH_PROCESS

  RET

EXIT_PROCESS:
  ; No need to save registers, they are restored in POP_PROCESS
  LD HL, PROC_COUNT
  OR A, A
  CP (HL)
  RET Z ; If no processes, return
  DEC (HL) ; Else decrement

  CALL POP_PROCESS ; Pop the process from process stack

  RET

GET_PROCESS_ID:
  PUSH HL
  LD HL, (PROCESS_SP) ; Load process stack pointer
  INC HL
  LD A, (HL) ; Load it to A
  POP HL
  RET

PUSH_PROCESS:

  LD (TMP_REG1), HL ; Save current HL
  LD (TMP_REG2), SP ; Save current SP

  LD SP, (PROCESS_SP) ; Load process stack pointer

  LD HL, (TMP_REG1) ; Restore HL

  ; Save old process registers
  PUSH AF
  PUSH BC
  PUSH DE
  PUSH HL

  LD HL, (USER_SP) ; Get the stack pointer before creating the new process
  PUSH HL ; Save the old stack pointer
  LD E, (HL)
  INC HL
  LD D, (HL)
  PUSH DE ; Save the return address

  LD A, R
  LD B, A
  LD C, 0 ; BC = PID and exit code
  PUSH BC ; Save the PID, exit code is defaulted to 0

  LD (PROCESS_SP), SP ; Save SP

  ; So the stack looks like this:
  ; AF (2 bytes), BC (2 bytes), DE (2 bytes), HL (2 bytes), SP (2 bytes), return address (2 bytes), PID (1 byte), exit code (1 byte)
  ; Size: 14 bytes
  
  LD SP, (TMP_REG2) ; Restore the old stack pointer
  RET


POP_PROCESS: ; Returns: AF, BC, DE, HL, SP, TMP3(Return address)
  LD (TMP_REG1), SP ; Save kernel SP

  LD SP, (PROCESS_SP) ; Load process stack pointer

  POP HL ; Pop the pid and exit code

  POP HL ; Return address in HL
  ;LD (TMP_REG3), HL ; Save it for later

  POP HL ; Now the old stack pointer is in HL
  LD (USER_SP), HL ; Set the user stack pointer to the just popped one

  ; Pop the registers
  POP HL
  POP DE
  POP BC
  POP AF

  LD (PROCESS_SP), SP ; Save SP

  LD SP, (TMP_REG1) ; Restore the kernel sp
  RET