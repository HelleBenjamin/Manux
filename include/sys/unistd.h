// SPDX-License-Identifier: GPL-2.0-only
// Copyright (c) 2025 Benjamin Helle

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

#define O_CREAT  0x02
#define O_RDWR   0x04
#define O_RDONLY 0x08
#define O_WRONLY 0x10
#define O_EXCL   0x20

extern void _exit(int code);
extern void _exit_fastcall(int status) __preserves_regs(a,b,c,d,e,h,l) __z88dk_fastcall;

extern int read(int fd, void *buf, int count);

extern int write(int fd, const void *buf, int count);

extern int close(int fd);

extern int execl(const char *path, const char *arg);

extern int open(const char *path, int flags, int mode);

#endif