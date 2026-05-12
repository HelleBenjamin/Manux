// SPDX-License-Identifier: GPL-2.0-only
// Copyright (c) 2025 Benjamin Helle

#include <sys/utsname.h>
#include <sys/syscall.h>

int uname(struct utsname *buf) __z88dk_fastcall {
  syscall(SYS_GETINFO, (char *)buf, 0, 0); // Get system information
  return 0;
}
