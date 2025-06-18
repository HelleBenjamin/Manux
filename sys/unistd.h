// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle

#ifndef _UNISTD_H
#define _UNISTD_H

#include "sys/syscall.h"

/*
  Very small POSIX API implementation.
*/

#ifndef NULL
#define NULL (void *)0
#endif
#ifndef pid_t
#define pid_t int
#endif

#ifndef STDIN_FILENO
#define STDIN_FILENO 0
#endif
#ifndef STDOUT_FILENO
#define STDOUT_FILENO 1
#endif
#ifndef STDERR_FILENO
#define STDERR_FILENO 2
#endif

void _exit(short code);
unsigned short read(int fd, void *buf, unsigned short count);
unsigned short write(int fd, const void *buf, unsigned short count);
pid_t fork(void);
pid_t getpid(void);
short close(int fd);

#endif