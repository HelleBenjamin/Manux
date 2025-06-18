; SPDX-License-Identifier: GPL-2.0-or-later
; Copyright (c) 2025 Benjamin Helle
;
; kernel_load.asm
; Manux Kernel loader, bootloader

ORG 0x9000

  JP INIT

; Built-in TTY-driver
IF USE_RST ; If using custom RST vectors, should be used on any system that has an ACIA chip

TRANSMIT_CHAR:
  ;Args:
  ; A = char
  ;Returns:
  ; none
  RST 08H
  RET

RECEIVE_CHAR:
  ;Args:
  ; none
  ;Returns:
  ; A = char
  RST 10H
  RET

INIT_TTY:
  ;Args:
  ; none
  ;Returns:
  ; none

  ; Add TTY initialization here

  RET

ELSE ; Default: Use a port defined in Kconfig, reads raw data

TRANSMIT_CHAR:
  ;Args:
  ; A = char
  ;Returns:
  ; none
  OUT (TTY_PORT), A
  RET

RECEIVE_CHAR:
  ;Args:
  ; none
  ;Returns:
  ; A = char
  IN A, (TTY_PORT)
  OR A
  JR Z, RECEIVE_CHAR ; Wait for char
  RET

INIT_TTY:
  ;Args:
  ; none
  ;Returns:
  ; none

  ; Add TTY initialization here

  RET

ENDIF

INIT:
  ;LD SP, 0xF000 ; Load temp stack
  CALL BOOT_MSG
  JP LOAD_LOOP_INIT

MINIMAL_PUTS:
  LD A, (HL)
  OR A
  RET Z
  CALL TRANSMIT_CHAR
  INC HL
  JR MINIMAL_PUTS

LOAD_LOOP_INIT:
  CALL INIT_TTY
  LD HL, CRT_ORG_CODE
LOAD_LOOP:
  CALL RECEIVE_CHAR
  CALL TRANSMIT_CHAR ; Echo back, could be used for validation
  CP 0xAD
  JR Z, EXIT_CODE_CHECK
  CONT:
  LD (HL), A
  INC HL
  JR LOAD_LOOP

EXIT_CODE_CHECK: ; 0xEDAD, magic exit code
  PUSH HL
  PUSH AF
  DEC HL
  LD A, (HL)
  CP 0xED
  JR Z, DONE
  POP AF
  POP HL
  JR CONT
DONE:
  XOR A, A
  LD (HL), A
  INC HL
  LD (HL), A
  CALL DONE_MSG
  JP CRT_ORG_CODE ; Jump to the kernel

BOOT_MSG:
  LD HL, BOOT_MSG_TEXT
  CALL MINIMAL_PUTS
  RET

DONE_MSG:
  LD HL, DONE_MSG_TEXT
  CALL MINIMAL_PUTS
  RET

BOOT_MSG_TEXT:
  db "Manux bootloader. Enter kernel in hex format:", 0x0D, 0x0A, 0

DONE_MSG_TEXT:
  db "Done loading kernel", 0
