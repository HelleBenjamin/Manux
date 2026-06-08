; SPDX-License-Identifier: GPL-2.0-only
; Copyright (c) 2025-2026 Benjamin Helle
;
; kmain.asm
; Assembly kernel functions

SECTION code_home ; Home section is only used for the kernel

  EXTERN crt0_init_bss
  EXTERN _main
  EXTERN SYSCALL_DISPATCH
  EXTERN INIT_TTY

  PUBLIC KERNEL_ENTRY
  PUBLIC REG_DUMP
  PUBLIC MINIMAL_PUTS
  PUBLIC STACKTRACE


  ; Kernel flags
  ; bit 0 - echo, should echo the character received
  ; bit 1 - unused
  ; bit 2 - unused
  ; bit 3 - unused
  ; bit 4 - unused
  ; bit 5 - unused
  ; bit 6 - unused
  ; bit 7 - unused

  ; Memory map
  ; 0x0000 - 0x1FFF Kernel ROM
  ; 0x2000 - 0x2FFF Kernel Workspace(fd table, etc)
  ; 0x3000 - 0x3FFF Init/Shell area(loaded by the kernel)
  ; 0x4000 - 0xEFFF User program area
  ; 0xF000 - 0xFFFF Stack, buffers, etc

  PUBLIC _main
_main:
KERNEL_ENTRY:
  ; assumes that SP already set

  XOR A ; Clear A

  ; Load kernel flags
  LD HL, KERNEL_FLAGS
  LD (HL), A ; Initialize all to 0
  SET 0, (HL) ; Set echo

  ld (KERNEL_SP), sp

  extern _kernel_main
  JP _kernel_main ; Jump to kernel main

  JR _kernel_panic ; Kernel should never return

  PUBLIC _kernel_panic
_kernel_panic:
  LD HL, KP_MSG
  CALL MINIMAL_PUTS
  CALL REG_DUMP

KP_LOOP:
  JR KP_LOOP


  PUBLIC exec_init_jump
exec_init_jump:
  ld sp, SHELL_STACK
  jp 0x3000

MINIMAL_PUTS: ; like kputs
  LD A, (HL)
  OR A
  RET Z
  OUT ($81), A ; doesn't work with other ports
  INC HL
  JR MINIMAL_PUTS
REG_DUMP:
  EXTERN _kputh
  ; Save the registers
  PUSH AF
  PUSH BC
  PUSH DE
  PUSH HL
  PUSH IX
  PUSH IY

  ; Push the registers that we want to print
  PUSH IY
  PUSH IX
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF
  LD HL, REG_AF
  CALL MINIMAL_PUTS
  POP HL
  CALL _kputh
  LD HL, REG_BC
  CALL MINIMAL_PUTS
  POP HL
  CALL _kputh
  LD HL, REG_DE
  CALL MINIMAL_PUTS
  POP HL
  CALL _kputh
  LD HL, REG_HL
  CALL MINIMAL_PUTS
  POP HL
  CALL _kputh
  LD HL, REG_IX
  CALL MINIMAL_PUTS
  POP HL
  CALL _kputh
  LD HL, REG_IY
  CALL MINIMAL_PUTS
  POP HL
  CALL _kputh
  LD HL, REG_SP
  CALL MINIMAL_PUTS
  LD HL, 0
  ADD HL, SP ; Get current stack pointer
  CALL _kputh ; Print the stack pointer
  ; Restore the registers
  POP IY
  POP IX
  POP HL
  POP DE
  POP BC
  POP AF
  RET

STACKTRACE: ; C = depth
  PUSH BC ; Save depth
  PUSH HL ; Save HL
  LD HL, STACKTRACE_MSG
  EXTERN TRANSMIT_CHAR
  CALL MINIMAL_PUTS ; Print the stacktrace message
  LD HL, 0
  ADD HL, SP ; Get current stack pointer
  ST_LOOP:
    LD E, (HL) ; Get low byte
    INC HL
    LD D, (HL) ; Get high byte
    INC HL
    EX DE, HL ; HL = value
    PUSH BC ; Save depth
    PUSH HL ; Save HL
    CALL _kputh ; Print the hex value
    EX DE, HL ; Restore HL
    LD A, ' '
    RST 0x08
    POP HL
    POP BC ; Restore depth
    DEC C ; Decrease depth
    JR NZ, ST_LOOP ; If depth is not zero, loop
    POP HL
    POP BC
    RET

; Don't remove this
INCLUDE "kernel/kernel.inc"

STACKTRACE_MSG:
  db "Stacktrace: ", 0
REG_AF:
  db " AF: ", 0
REG_BC:
  db " BC: ", 0
REG_DE:
  db " DE: ", 0
REG_HL:
  db " HL: ", 0
REG_IX:
  db " IX: ", 0
REG_IY:
  db " IY: ", 0
REG_SP:
  db " SP: ", 0