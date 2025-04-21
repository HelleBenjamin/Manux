; SPDX-License-Identifier: GPL-2.0-or-later
; Copyright (c) 2025 Benjamin Helle
SECTION CODE
  PUBLIC READC
  PUBLIC PRINTC
  PUBLIC INP
  PUBLIC OUTP

; Input/Output driver

READC:
  ;Args:
  ; none
  ;Returns:
  ; A = char
  RST 10H
  RET

PRINTC:
  ;Args:
  ; A = char
  ;Returns:
  ; none
  RST 08H
  RET

INP:
  ;Args:
  ; BC = port
  ;Returns:
  ; A = value
  IN A, (C)
  RET

OUTP:
  ;Args:
  ; BC = port
  ; A = value
  ;Returns:
  ; none
  OUT (C), A
  RET