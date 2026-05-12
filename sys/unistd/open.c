/* SPDX-License-Identifier: GPL-2.0-only
* Copyright (c) 2025-2026 Benjamin Helle
*/

#include <sys/syscall.h>
#include <sys/unistd.h>

int open(const char *path, int flags, int mode) {
  return syscall(SYS_OPEN, path, flags, mode);
}