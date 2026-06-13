/* SPDX-License-Identifier: GPL-2.0-only
* Copyright (c) 2025-2026 Benjamin Helle
*/

#ifndef TTY_H
#define TTY_H

#include <kernel/kernel.h>

/* mirror from kernel.inc */
#define TTY_BUF_TAIL  KERNEL_WORKSPACE+0x100
#define TTY_BUF_HEAD  KERNEL_WORKSPACE+0x102
#define TTY_BUF_COUNT KERNEL_WORKSPACE+0x104
#define TTY_BUF       KERNEL_WORKSPACE+0x106
#define TTY_BUF_SIZE  255

int tty_init(void);
int tty_getchar(void);
int tty_putchar(char c) __z88dk_fastcall;


#endif