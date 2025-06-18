; SPDX-License-Identifier: GPL-2.0-or-later
; Copyright (c) 2025 Benjamin Helle
;
; fs.asm
; Filesystem for Manux

; Here's a (very) basic description of the file system:
; FIFS (Flat Index Filesystem)
; 8 byte filenames
; 64 byte blocks
;
; File structure:
; 1 byte reserved
; 8 byte name
; 2 byte size
; 1 byte block size
; data

  INCLUDE "kernel.inc"
SECTION code_home
  PUBLIC INIT_FS
  PUBLIC FIND_FILE
  PUBLIC READ_FILE
  PUBLIC WRITE_FILE

; TODO: Replace EX DE, HL with right code, add better error handling

INIT_FS:
  ;Args:
  ; none
  ;Returns:
  ; none
  LD A, 0
  LD (FS_FCOUNT), A
  RET

FIND_FREE_BLOCK:
  ;Args:
  ; none
  ;Returns:
  ; HL - pointer to free block
  LD DE, 64
  LD HL, FS_BASE+1
  
  FIND_FREE_BLOCK_LOOP: ; Search for a free block
    LD A, (HL)
    OR A ; 0 if free
    JR Z, FOUND_FREE_BLOCK
    ADD HL, DE ; If not, move to the next block and repeat
    JR FIND_FREE_BLOCK_LOOP
  FOUND_FREE_BLOCK:
    RET
 
FIND_FILE:
  ;Args:
  ; HL - pointer to filename
  ;Returns:
  ; HL - pointer to file

  PUSH DE ; Save regs
  PUSH BC
  LD A, (FS_FCOUNT) ; Load file count
  LD C, A
  LD DE, FS_BASE+2
  FIND_FILE_LOOP:
    PUSH BC ; Save the fc(file count)
    LD BC, 8
    JR STRCMP_LOOP
    POP BC
    DEC C ; Decrement file count
    JR NZ, FIND_FILE_LOOP ; When all files have been checked, exit
    JR NOT_FOUND_RET
  STRCMP_LOOP: ; Compare strings. Note: This may have a bug that does something strange if a filename is similar to another, eg. test and test2
    LD A, (DE)
    CPI
    JR NZ, NOT_FOUND
    INC DE
    OR A ; Check for null
    JR NZ, STRCMP_LOOP
  FOUND: ; Found the file, return it
    LD HL, 3 ; A
    ADD HL, DE ; HL holds the pointer to the data
    NOT_FOUND_RET:
    POP BC ; Pop temp and restore regs
    POP BC
    POP DE
    RET
  NOT_FOUND:
    JR FIND_FILE_LOOP ; Try again


READ_FILE:
  ;Args:
  ; BC = filename
  ; DE - count
  ; HL - buffer
  ;Returns:
  ; HL - pointer to file

  PUSH HL ; Save buffer
  PUSH DE ; Save count

  PUSH BC
  POP HL ; Move filename to HL

  CALL FIND_FILE
  XOR A
  OR L ; Check if the file was found
  JR Z, READ_FILE_END; Exit if the file was not found

  POP BC ; Move count to BC

  POP DE ; Restore destination, HL is already pointing to the file

  LDIR ; Just a single instruction can do all the magic!

  READ_FILE_END:
    RET

GET_FILE_BLOCKS:
  ;Args:
  ; HL - count
  ;Returns:
  ; A - block count

  ; This basically translates the count to blocks

  PUSH DE ; Save regs
  PUSH HL

  LD DE, 64
  LD A, 0

  GET_FILE_BLOCKS_LOOP:
    INC A
    SBC HL, DE
    JP P, GET_FILE_BLOCKS_LOOP

  POP HL ; Restore regs
  POP DE

  RET

WRITE_FILE:
  ;Args:
  ; BC = filename pointer
  ; DE - count
  ; HL - buffer
  ;Returns:
  ; none

  PUSH HL ; Save buffer
  PUSH DE ; Save count
  CALL FIND_FREE_BLOCK ; Free block is in HL
  LD (HL), 1 ; Mark the block as in use
  INC HL

  PUSH BC
  POP DE ; Move filename to DE
  LD BC, 8
  EX DE, HL
  LDIR ; Just a single instruction can do all the magic!

  EX DE, HL
  POP DE ; Restore count
  LD (HL), E
  INC HL
  LD (HL), D
  INC HL ; Save size

  EX DE, HL ; HL = count
  CALL GET_FILE_BLOCKS
  EX DE, HL ; HL = pointer
  LD (HL), A
  INC HL ; Save block count

  PUSH DE
  POP BC ; Move count to BC

  POP DE ; Restore source, HL is already pointing to the file

  EX DE, HL ; Swap

  LDIR ; Copy the data

  LD HL, FS_FCOUNT
  INC (HL) ; Increment file count

  RET
