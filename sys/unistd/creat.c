/* SPDX-License-Identifier: GPL-2.0-only
* Copyright (c) 2025-2026 Benjamin Helle
*/

#include <sys/syscall.h>
#include <sys/fcntl.h>

int creat(const char *path, int mode) {
  return syscall(SYS_OPEN, path, O_CREAT, mode);
}