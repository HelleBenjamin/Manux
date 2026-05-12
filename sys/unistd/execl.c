/* SPDX-License-Identifier: GPL-2.0-only
* Copyright (c) 2025-2026 Benjamin Helle
*/

#include <sys/syscall.h>
#include <sys/unistd.h>

int execl(const char *path, const char *arg) {
  return syscall(SYS_EXEC, (int)path, (int)arg, 0);
}