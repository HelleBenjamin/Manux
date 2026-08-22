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
SHELL_SP          EQU KERNEL_WORKSPACE+4
SYSCALL_RET       EQU KERNEL_WORKSPACE+6 ; Syscall return value
KERNEL_FLAGS      EQU KERNEL_WORKSPACE+8

; Temporal registers
TMP_REG1          EQU KERNEL_WORKSPACE+10
TMP_REG2          EQU KERNEL_WORKSPACE+12
TMP_REG3          EQU KERNEL_WORKSPACE+14
SAVED_SP          EQU KERNEL_WORKSPACE+16

; TTY
TTY_BUF_TAIL      EQU KERNEL_WORKSPACE+0x100
TTY_BUF_HEAD      EQU KERNEL_WORKSPACE+0x102
TTY_BUF_COUNT     EQU KERNEL_WORKSPACE+0x104
TTY_BUF           EQU KERNEL_WORKSPACE+0x106 ; 250 bytes

; Setup stacks
IFNDEF STACK_BASE
STACK_BASE        EQU 0x3000 ; common stack space
ENDIF
KERNEL_STACK      EQU STACK_BASE+0x7FF ; 2048 bytes


IFNDEF SHELL_AREA
SHELL_AREA        EQU 0x3800
ENDIF

SHELL_STACK       EQU SHELL_AREA+0x1000+0x3FF ; 1024 bytes in size

; Userland
IFNDEF USER_STACK
USER_STACK        EQU 0xFFFF ; Top of user area, fixed
ENDIF
IFNDEF PIH_AREA
PIH_AREA          EQU 0x4F00
ENDIF
IFNDEF USER_AREA   
USER_AREA         EQU 0x5000 ; User area start, actual code at 0x4100
ENDIF


SYSCALL_COUNT     EQU 14

SECTION DATA

SYSINFO:
  ;db "Manux   Z80-PC   0.2-1  release  Z80   ", 0
 ;db "012345678"
  db "Manux   ",0 ; sysname
  db "Z80-PC  ",0 ; nodename
  db "0.3.0   ",0 ; release
  db "pre     ",0 ; version
  db "Z80     ",0 ; machine

KP_MSG:
  db "Kernel Panic!", 0

ENDIF