; SPDX-License-Identifier: GPL-2.0-or-later
; Copyright (c) 2025 Benjamin Helle
;
; kmain.asm
; Assembly kernel for Manux

SECTION code_home ; Home section is only used for the kernel

  EXTERN crt0_init_bss
  EXTERN _main
  EXTERN SYSCALL_DISPATCH
  EXTERN INIT_TTY

  PUBLIC KERNEL_ENTRY
  PUBLIC REG_DUMP


  ; Kernel flags
  ; bit 0 - echo, should print text on gets
  ; bit 1 - unused
  ; bit 2 - unused
  ; bit 3 - unused
  ; bit 4 - unused
  ; bit 5 - unused
  ; bit 6 - unused
  ; bit 7 - unused

  ; TODO: Rework the memory, i'll do it later
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

KERNEL_ENTRY:
  PUSH HL
  LD HL, 0
  ADD HL, SP
  LD SP, KERNEL_STACK ; Set kernel stack
  PUSH HL ; Save old sp
  LD (KERNEL_SP), SP ; Save kernel sp, this also saves the old sp

  ; Initialize drivers
  CALL INIT_TTY

  ; Load syscall handler address
  LD HL, SYSCALL_VECTOR
  LD DE, SYSCALL_DISPATCH
  LD (HL), $C3 ; JP
  INC HL
  LD (HL), E
  INC HL
  LD (HL), D ; Now the syscall address is at address defined by SYSCALL_VECTOR

  ; Set syscall count
  LD A, $0E
  LD (SYSCALL_COUNT), A

  ; Load kernel flags
  LD HL, KERNEL_FLAGS
  LD (HL), 0 ; Initialize all to 0
  SET 0, (HL) ; Set echo

  ; Create process stack at 0xAF00
  LD HL, PROCESS_STACK
  LD (PROCESS_SP), HL

  ; Create user stack at 0xA500
  LD HL, USER_STACK
  LD (USER_SP), HL

  LD HL, PROC_COUNT ; Zero the process count
  LD (HL), 0

  ; Load userspace
  LD SP, (USER_SP)

  ; Create root process(main)
  LD A, 9
  CALL SYSCALL_VECTOR ; Fork

  LD HL, _main ; Load address of main
  LD A, 5
  CALL SYSCALL_VECTOR  ; Exec

  ; Switch to kernelspace
  LD (USER_SP), SP
  LD SP, (KERNEL_SP)

  POP HL ; Restore old sp
  LD SP, HL
  POP HL
  RET ; Return back to BASIC or whatever called KERNEL_ENTRY


; Debugging, feel free to remove, this is just for testing 
MINIMAL_PUTS:
  EXTERN TRANSMIT_CHAR
  LD A, (HL)
  OR A
  RET Z
  CALL TRANSMIT_CHAR
  INC HL
  JP MINIMAL_PUTS
REG_DUMP:
  EXTERN _puth
  PUSH IY
  PUSH IX
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF
  LD HL, REG_AF
  CALL MINIMAL_PUTS
  POP HL
  CALL _puth
  LD HL, REG_BC
  CALL MINIMAL_PUTS
  POP HL
  CALL _puth
  LD HL, REG_DE
  CALL MINIMAL_PUTS
  POP HL
  CALL _puth
  LD HL, REG_HL
  CALL MINIMAL_PUTS
  POP HL
  CALL _puth
  LD HL, REG_IX
  CALL MINIMAL_PUTS
  POP HL
  CALL _puth
  LD HL, REG_IY
  CALL MINIMAL_PUTS
  POP HL
  CALL _puth
  RET

; Don't remove this
INCLUDE "kernel/kernel.inc"

; Debugging, feel free to remove, this is just for testing
SECTION data_home
REG_AF:
  db "AF: ", 0
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