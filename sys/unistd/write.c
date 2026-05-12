/* SPDX-License-Identifier: GPL-2.0-only
* Copyright (c) 2025-2026 Benjamin Helle
*/

#include <sys/syscall.h>
#include <sys/unistd.h>

int write(int fd, const void *buf, int count) {
  return syscall(SYS_WRITE, fd, count, (char *)buf);
}
