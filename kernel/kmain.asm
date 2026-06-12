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
  EXTERN _kputs ; from kstdio.c
_kernel_panic:
  ; preserve the exact state, helpful for debugging
  PUSH AF
  PUSH BC
  PUSH DE
  PUSH HL
  PUSH IX
  PUSH IY
  LD HL, KP_MSG
  CALL _kputs ; alters registers
  ; restore them
  POP IY
  POP IX
  POP HL
  POP DE
  POP BC
  POP AF
  CALL REG_DUMP

KP_LOOP:
  HLT
  JR KP_LOOP


  PUBLIC exec_init_jump
exec_init_jump:
  ld sp, SHELL_STACK
  jp 0x3000

REG_DUMP:
  EXTERN _kputh
  ; maybe add PC printing?

  LD (TMP_REG1), HL ; temporaly save

  LD HL, 0
  ADD HL, SP ; get current stack pointer
  LD (TMP_REG2), HL ; save it in TMP_REG2

  ; Save the registers
  PUSH AF
  PUSH BC
  PUSH DE
  PUSH HL
  PUSH IX
  PUSH IY
  
  LD HL, (TMP_REG2) ; push SP
  PUSH HL

  LD HL, (TMP_REG1) ; restore HL

  ; Push the registers that we want to print
  PUSH IY
  PUSH IX
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF


  LD HL, REGISTERS ; message
  LD DE, 5 ; size of each register message(including null)
  LD C, 7 ; number of registers to print

  REG_DUMP_LOOP:
    ; save regs
    POP IY ; IY = register value from stack

    PUSH BC
    PUSH DE
    PUSH HL

    CALL _kputs ; fastcall, so HL is the arg
    PUSH IY ; theres no ld hl, iy instruction, need to do this simple "trick"
    POP HL ; HL = register value
    CALL _kputh ; also fastcall

    ; restore regs
    POP HL
    POP DE
    POP BC

    ; decrement and advance msg pointer
    DEC C
    JR Z, REG_DUMP_END
    ADD HL, DE ; next register message
    JR REG_DUMP_LOOP

  REG_DUMP_END:

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
  CALL _kputs ; Print the stacktrace message
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


; much better now
REGISTERS:
  db " AF:", 0, " BC:", 0, " DE:", 0, " HL:", 0, " IX:", 0, " IY:", 0, " SP:", 0