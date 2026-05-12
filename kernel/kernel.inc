; SPDX-License-Identifier: GPL-2.0-only
; Copyright (c) 2025 Benjamin Helle
;
; kernel.inc
; Kernel include file

IFNDEF __KERNEL_INC__
__KERNEL_INC__ EQU 1

; Kernel workspace
; This holds system critical data, so don't mess with this unless you know what you're doing
IFNDEF KERNEL_WORKSPACE
KERNEL_WORKSPACE  EQU 0x2000
ENDIF

; TODO: rework this

KERNEL_SP         EQU KERNEL_WORKSPACE+2
USER_SP           EQU KERNEL_WORKSPACE+4 ; Top of user area
SHELL_SP          EQU KERNEL_WORKSPACE+6 ; SP for shell
SYSCALL_RET       EQU KERNEL_WORKSPACE+8 ; Syscall return value
KERNEL_FLAGS      EQU KERNEL_WORKSPACE+10
CURRENT_PIH       EQU KERNEL_WORKSPACE+12

; Temporal registers
TMP_REG1          EQU KERNEL_WORKSPACE+14
TMP_REG2          EQU KERNEL_WORKSPACE+16
TMP_REG3          EQU KERNEL_WORKSPACE+18
SAVED_SP          EQU KERNEL_WORKSPACE+20
SHELL_RETURN      EQU KERNEL_WORKSPACE+22 ; Jumped to after exit syscall

CURR_FILE         EQU KERNEL_WORKSPACE+33

; File descriptors and device file system
FD_COUNT_ADDR     EQU KERNEL_WORKSPACE+0xFE
FD_BASE_ADDR      EQU KERNEL_WORKSPACE+0x100
DEVFS_COUNT_ADDR  EQU KERNEL_WORKSPACE+0x1FE
DEVFS_BASE_ADDR   EQU KERNEL_WORKSPACE+0x200
UTSNAME_BUF       EQU KERNEL_WORKSPACE+0x228
TTY_BUF_TAIL      EQU KERNEL_WORKSPACE+0x230
TTY_BUF_HEAD      EQU KERNEL_WORKSPACE+0x232
TTY_BUF_COUNT     EQU KERNEL_WORKSPACE+0x234
TTY_BUF           EQU KERNEL_WORKSPACE+0x333 ; 255 bytes

; Setup stacks
IFNDEF REGISTER_SP
REGISTER_SP       EQU 0xFFFF
ENDIF
KERNEL_STACK      EQU REGISTER_SP ; 1024 bytes
SHELL_STACK       EQU REGISTER_SP-0x400 ; 1024 bytes
USER_STACK        EQU 0xEFFF ; Top of user area, fixed



FD_MAX            EQU 8
FD_ENTRY_SIZE     EQU 5

SYSCALL_COUNT     EQU 13

SECTION DATA

SYSINFO:
  ;db "Manux   Z80-PC   0.2-1  release  Z80   ", 0
 ;db "012345678"
  db "Manux   ",0 ; sysname
  db "Z80-PC  ",0 ; nodename
  db "0.3.0   ",0 ; release
  db "pre     ",0 ; version
  db "Z80     ",0 ; machine
MSG: ; Secret message
  db "Hellord", 0DH, 0AH, 0

KP_MSG:
  db "Kernel Panic!", 0

ENDIF