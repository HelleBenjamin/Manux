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
  EXTERN INIT_FS

  PUBLIC KERNEL_ENTRY


  ; Kernel flags
  ; bit 0 - echo, should print text on gets
  ; bit 1 - mode, kernelmode (0) or usermode (1)
  ; bit 2 - unused
  ; bit 3 - unused
  ; bit 4 - unused
  ; bit 5 - unused
  ; bit 6 - unused
  ; bit 7 - unused

  ; TODO: Rework the memory
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

  ; Initialize the filesystem
  CALL INIT_FS

  ; Load syscall handler address
  LD HL, SYSCALL_VECTOR
  LD DE, SYSCALL_DISPATCH
  LD (HL), $C3 ; JP
  INC HL
  LD (HL), E
  INC HL
  LD (HL), D ; Now the syscall address is at address defined by SYSCALL_VECTOR

  ; Set syscall count
  LD A, $0C
  LD (SYSCALL_COUNT), A

  ; Load kernel flags
  LD HL, KERNEL_FLAGS
  LD (HL), 0 ; Initialize all to 0
  SET 0, (HL) ; Set echo
  RES 1, (HL) ; Set kernel mode, 0

  ; Create process stack at 0xAF00
  LD HL, PROCESS_STACK
  LD (PROCESS_SP), HL

  ; Create user stack at 0xA500
  LD HL, USER_STACK
  LD (USER_SP), HL

  LD HL, PROC_COUNT
  LD (HL), 0

  ; Load usermode
  PUSH HL
  LD HL, KERNEL_FLAGS
  SET 1, (HL)
  POP HL
  LD SP, (USER_SP)

  ; Create root process
  LD A, 9
  CALL SYSCALL_VECTOR ; Fork

  LD HL, ROOT_PROCESS
  LD A, 5
  CALL SYSCALL_VECTOR  ; Exec

  ; Switch to kernelmode
  LD (USER_SP), SP
  LD SP, (KERNEL_SP)
  PUSH HL
  LD HL, KERNEL_FLAGS
  RES 1, (HL)
  POP HL

  POP HL ; Restore old sp
  LD SP, HL
  POP HL
  RET ; Return back to BASIC

ROOT_PROCESS:

  ; Create OS process
  LD A, 9
  CALL SYSCALL_VECTOR  ; Fork

  LD HL, _main
  LD A, 5
  CALL SYSCALL_VECTOR  ; And execute

  ; Exit
  LD BC, 0
  LD A, 0
  CALL SYSCALL_VECTOR 


INCLUDE "kernel/kernel.inc"