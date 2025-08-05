// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle

#include "utsname.h"
#include "syscall.h"
#include <string.h>

short uname(struct utsname *buf) __z88dk_fastcall{
  static char nbuf[40]; // name buffer
  syscall(SYS_GETINFO, (char *)nbuf, 40, 0); // Get system information
  for (unsigned char j = 7; j < 40; j += 8) {
    nbuf[j] = '\0';
  }
  memcpy(buf, nbuf, 40);
  return 0;
}
