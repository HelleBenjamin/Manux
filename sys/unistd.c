// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle

#include "unistd.h"
#include "syscall.h"

void _exit(short code) {
  syscall(SYS_EXIT, code, 0, 0);
}

unsigned short read(int fd, void *buf, unsigned short count) {
  if (fd == STDIN_FILENO) {
    syscall(SYS_GETS, (char *)buf, count , 0);
  } else syscall(SYS_READ, (char *)buf, count, fd);
  return count;
}

unsigned short write(int fd, const void *buf, unsigned short count) {
  if (fd == STDOUT_FILENO) {
    syscall(SYS_PUTS, (char *)buf, count, 0);
  } else syscall(SYS_WRITE, (char *)buf, count, fd);
  return count;
}

pid_t fork(void) {
  syscall(SYS_FORK, 0, 0, 0);
  return 0;
}

pid_t getpid(void) {
  return syscall(SYS_GETPID, 0, 0, 0);
}

short close(int fd) {
  return syscall(SYS_CLOSE, fd, 0, 0);
}