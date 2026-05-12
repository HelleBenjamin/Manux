/* SPDX-License-Identifier: GPL-2.0-only
* Copyright (c) 2025-2026 Benjamin Helle
*/

#include <sys/syscall.h>
#include <sys/unistd.h>

int close(int fd) {
  return syscall(SYS_CLOSE, fd, 0, 0);
}