/* SPDX-License-Identifier: GPL-2.0-only
* Copyright (c) 2026 Benjamin Helle
*/

#include <sys/syscall.h>
#include <sys/unistd.h>

int lseek(int fd, int offset, int whence) {
  return syscall(SYS_SEEK, fd, offset, whence);
}
