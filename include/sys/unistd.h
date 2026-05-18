// SPDX-License-Identifier: GPL-2.0-only
// Copyright (c) 2025-2026 Benjamin Helle

#ifndef __UNISTD_H__
#define __UNISTD_H__

#include <sys/syscall.h>

/*
  Very small POSIX API implementation for Manux userland applications.
*/

#ifndef NULL
#define NULL (void *)0
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

extern void _exit(int code);
extern void _exit_fastcall(int status) __preserves_regs(a,b,c,d,e,h,l) __z88dk_fastcall;

extern int read(int fd, void *buf, int count);

extern int write(int fd, const void *buf, int count);

extern int close(int fd);

extern int execv(const char *path, const char *argv[]);

#endif