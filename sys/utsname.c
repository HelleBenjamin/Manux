// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle

#include "utsname.h"
#include "syscall.h"
#include <string.h>

short uname(struct utsname *buf) {
  char nbuf[40];
  sysc_getinfo(nbuf);
  memcpy(buf, nbuf, 40);
  return 0;
}
