/* SPDX-License-Identifier: GPL-2.0-only
* Copyright (c) 2025-2026 Benjamin Helle
*/

#include <sys/syscall.h>
#include <sys/fcntl.h>

int open(const char *path, int flags, ...) {
  /* add mode arg?*/
  return syscall(SYS_OPEN, path, flags, 0);
}