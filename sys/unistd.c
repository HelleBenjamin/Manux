// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle

#include "unistd.h"
#include "syscall.h"

void _exit(short code) {
  sysc_exit(code);
}

ssize_t read(int fd, void *buf, size_t count) {
  if (fd == STDIN_FILENO) {
    sysc_gets(count, (char *)buf);
    return count;
  } else {
    sysc_read(fd, count, buf);
  }
  return count;
}

ssize_t write(int fd, const void *buf, size_t count) {
  if (fd == STDOUT_FILENO) {
    sysc_puts(count, (char *)buf);
    return count;
  } else {
    sysc_write(fd, count, (char *)buf);
  }
  return count;
}

pid_t fork(void) {
  sysc_fork();
  return 0;
}

pid_t getpid(void) {
  char buf = 0;
  sysc_getpid(&buf);
  return buf;
}