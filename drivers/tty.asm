; SPDX-License-Identifier: GPL-2.0-or-later
; Copyright (c) 2025 Benjamin Helle
;
; tty.asm
; TTY Driver

SECTION code_user

  PUBLIC TRANSMIT_CHAR
  PUBLIC RECEIVE_CHAR
  PUBLIC INIT_TTY

;USE_RST EQU 1 ; Use on debug
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
  OUT ($81), A
  RET

RECEIVE_CHAR:
  ;Args:
  ; none
  ;Returns:
  ; A = char
  IN A, ($81)
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