; SPDX-License-Identifier: GPL-2.0-or-later
; Copyright (c) 2025 Benjamin Helle
;
; kernel.inc
; Kernel include file

IFNDEF __KERNEL_INC__
__KERNEL_INC__ EQU 1

; Kernel workspace
; This holds system critical data, so don't mess with this unless you know what you're doing
IFNDEF KERNEL_WORKSPACE
KERNEL_WORKSPACE  EQU 0x9000
ENDIF

KERNEL_SP         EQU KERNEL_WORKSPACE+2
USER_SP           EQU KERNEL_WORKSPACE+4
PROCESS_SP        EQU KERNEL_WORKSPACE+6
SYSCALL_COUNT     EQU KERNEL_WORKSPACE+8
KERNEL_FLAGS      EQU KERNEL_WORKSPACE+10
PROC_COUNT        EQU KERNEL_WORKSPACE+12
TEMP_SP           EQU KERNEL_WORKSPACE+14

; Temporal registers
TMP_REG1          EQU KERNEL_WORKSPACE+16
TMP_REG2          EQU KERNEL_WORKSPACE+18
TMP_REG3          EQU KERNEL_WORKSPACE+20

; File descriptors and device file system
FD_COUNT_ADDR     EQU KERNEL_WORKSPACE+0xFE
FD_BASE_ADDR      EQU KERNEL_WORKSPACE+0x100
DEVFS_COUNT_ADDR  EQU KERNEL_WORKSPACE+0x1FE
DEVFS_BASE_ADDR   EQU KERNEL_WORKSPACE+0x200


; Setup stacks
PROCESS_STACK     EQU STACK_START-0xFF ; 256 bytes
KERNEL_STACK      EQU STACK_START-0x200 ; 256 bytes
USER_STACK        EQU STACK_START-0x300 ; n bytes

IFNDEF SYSCALL_VECTOR
; Define default syscall vector if it isn't defined already
SYSCALL_VECTOR    EQU 0xA000
ENDIF

; Filesystem stuff
FS_BASE           EQU 0xF000
FS_FCOUNT         EQU FS_BASE
FS_FNAMES         EQU FS_BASE+2
FS_BLOCK_START    EQU FS_BASE+0x100

DEVFS_MAX         EQU 8
DEVFS_ENTRY_SIZE  EQU 10

FD_MAX            EQU 8
FD_ENTRY_SIZE     EQU 5

SECTION DATA

SYSINFO:
  db "Manux   Z80-PC   0.2    release  Z80   ", 0
  ;db "Manux   Z80-PC   0.3    dev      Z80   ", 0
MSG: ; Secret message
  db "Hellord", 0DH, 0AH, 0

ENDIF