// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle

#ifndef STDIO_H
#define STDIO_H

#include "sys/syscall.h"

char putchar(char c);
char puts(char *s);
char getchar(void);

#endif