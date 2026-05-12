; SPDX-License-Identifier: GPL-2.0-only
; Copyright (c) 2026 Benjamin Helle
;
; disk.asm
; Floppy driver for bemu80

SECTION code_driver

IF TARGET_BEMU80=1
  PUBLIC WRITE_DISK
  PUBLIC READ_DISK
  ; 1 LBA sector = 512 bytes
WRITE_DISK:
  ; Args:
  ;  A: count
  ;  DE: lba address, destination
  ;  HL: address, source
  ; Returns:
  ;  A: status
  out ($16), a ; Write sector
  ld  a, e
  out ($11), a ; Write lba address
  ld  a, d
  out ($12), a
  ld  a, l
  out ($13), a ; Write dma address
  ld  a, h
  out ($14), a
  ld  a, $02
  out ($10), a ; Write "write"-command
  nop ; Wait
  in a, ($15) ; Status in A
  ret

READ_DISK:
  ; Args:
  ;  A: count
  ;  DE: lba address, source
  ;  HL: address, destination
  ; Returns:
  ;  A: status
  out ($16), a ; Write sector
  ld  a, e
  out ($11), a ; Write lba address
  ld  a, d
  out ($12), a
  ld  a, l
  out ($13), a ; Write dma address
  ld  a, h
  out ($14), a
  ld  a, $01
  out ($10), a ; Write "read"-command
  nop ; Wait
  in a, ($15) ; Status in A
  ret

ENDIF
; Add more tty drivers here