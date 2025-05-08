// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle

#ifndef STDIO_H
#define STDIO_H

#include "sys/syscall.h"

char putchar(char c) __z88dk_fastcall;
char puts(char *s) __z88dk_fastcall;
char getchar(void);

#endif